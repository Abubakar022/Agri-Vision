import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // 🟢 REQUIRED IMPORT FOR URDU DATES

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedFilter = 'تمام';
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> allOrders = [];
   
  // 🔹 Status Constants
  static const int STATUS_PENDING = 1;        // Pending
  static const int STATUS_COMPLETED = 2;      // Completed
  static const int STATUS_CANCELLED = 3;      // Cancelled
  static const int STATUS_IN_PROGRESS = 4;    // In Progress = شیڈول
   
  // 🔹 Backend URL
  static const String baseUrl = 'https://agrivision-backend-1075549714370.us-central1.run.app';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchOrders();
    });
  }

  // 🔹 Fetch Data from MongoDB API
  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 🟢 Initialize Urdu Locale Data
      await initializeDateFormatting('ur_PK', null);

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');

      if (uid == null || uid.isEmpty) {
        setState(() {
          errorMessage = 'یوزر آئی ڈی نہیں ملی۔ براہ کرم دوبارہ لاگ ان کریں۔';
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$baseUrl/getOrderData?userId=$uid');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          List<dynamic> orders = List.from(data['success']);
          
          // Sort orders by date
          orders.sort((a, b) {
            final dateA = DateTime.tryParse(a['createdAt'] ?? '');
            final dateB = DateTime.tryParse(b['createdAt'] ?? '');
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          });
          
          setState(() {
            allOrders = orders;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'ڈیٹا حاصل کرنے میں مسئلہ پیش آیا۔';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'سرور ایرر: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'انٹرنیٹ کنکشن چیک کریں';
        isLoading = false;
      });
    }
  }

  // 🔹 FIX 1: Force LTR for Time so PM shows on Right
  String formatDate(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().isEmpty) {
      return 'تاریخ دستیاب نہیں';
    }
      
    try {
      DateTime? date;
      if (dateInput is DateTime) {
        date = dateInput;
      } else {
        date = DateTime.tryParse(dateInput.toString().trim());
      }
      
      if (date != null) {
        final localDate = date.toLocal();
        
        // اردو تاریخ
        final datePart = DateFormat('dd MMM yyyy', 'ur_PK').format(localDate);
        
        // انگلش وقت (Force LTR using \u202A and \u202C)
        // اس سے PM ہمیشہ دائیں طرف (Right Side) نظر آئے گا
        final rawTime = DateFormat('hh:mm a', 'en_US').format(localDate);
        final timePart = '\u202A$rawTime\u202C'; 
        
        return '$datePart - $timePart';
      }
      
      return dateInput.toString();
      
    } catch (e) {
      return dateInput.toString();
    }
  }

  // 🔹 FIX 2: Force LTR for Schedule Time as well
  String? formatScheduleDate(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().isEmpty || dateInput.toString() == 'null') {
      return null;
    }
      
    try {
      DateTime? date;
      if (dateInput is DateTime) {
        date = dateInput;
      } else {
        date = DateTime.tryParse(dateInput.toString().trim());
      }
      
      if (date != null) {
        final localDate = date.toLocal();

        final datePart = DateFormat('dd MMMM yyyy', 'ur_PK').format(localDate);
        
        // Force LTR for Time (PM on Right)
        final rawTime = DateFormat('hh:mm a', 'en_US').format(localDate);
        final timePart = '\u202A$rawTime\u202C';

        return '$datePart\n$timePart';
      }
      
      return null;
      
    } catch (e) {
      return null;
    }
  }

  Future<void> _showCancelConfirmation(String orderId, String userName) async {
    final bool? result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('آرڈر منسوخ کریں', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              const Text('کیا آپ واقعی آرڈر منسوخ کرنا چاہتے ہیں؟', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('نہیں', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02A96C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('ہاں، منسوخ کریں', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await cancelOrder(orderId, userName);
    }
  }

  Future<void> cancelOrder(String orderId, String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');
      if (uid == null) return;

      final url = Uri.parse('$baseUrl/user/order/$orderId/cancel/$uid');
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Get.snackbar('کامیابی', 'آرڈر منسوخ ہو گیا', backgroundColor: const Color(0xFF02A96C), colorText: Colors.white);
          setState(() {
            final index = allOrders.indexWhere((order) => order['_id'] == orderId);
            if (index != -1) {
              allOrders[index]['status'] = STATUS_CANCELLED;
              allOrders[index]['cancellationReason'] = data['cancellationReason'] ?? 'صارف کی جانب سے منسوخ';
            }
          });
        }
      }
    } catch (e) {
      Get.snackbar('خرابی', 'مسئلہ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case STATUS_PENDING: return 'منتظر';
      case STATUS_COMPLETED: return 'مکمل';
      case STATUS_CANCELLED: return 'منسوخ';
      case STATUS_IN_PROGRESS: return 'شیڈول';
      default: return 'نامعلوم';
    }
  }

  IconData getStatusIcon(int status) {
    switch (status) {
      case STATUS_PENDING: return Icons.hourglass_bottom;
      case STATUS_COMPLETED: return Icons.check_circle;
      case STATUS_CANCELLED: return Icons.cancel;
      case STATUS_IN_PROGRESS: return Icons.calendar_today;
      default: return Icons.help;
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case STATUS_PENDING: return Colors.blue;
      case STATUS_COMPLETED: return Colors.green;
      case STATUS_CANCELLED: return Colors.red;
      case STATUS_IN_PROGRESS: return Colors.orange;
      default: return Colors.grey;
    }
  }

  bool shouldShowCancelOption(dynamic order) {
    final status = order['status'];
    return status == STATUS_PENDING && 
           (selectedFilter == 'تمام' || selectedFilter == 'منتظر');
  }

  List<dynamic> get filteredOrders {
    if (selectedFilter == 'تمام') return allOrders;
      
    return allOrders.where((order) {
      final label = getStatusText(order['status']);
      return label == selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3),
        appBar: AppBar(
          backgroundColor: const Color(0xFF02A96C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'آرڈر ہسٹری',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchOrders,
            ),
          ],
        ),
        body: isLoading
            ? _buildLoadingState()
            : errorMessage != null
                ? _buildErrorState()
                : _buildOrderList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF02A96C)),
          SizedBox(height: 20),
          Text('آرڈرز لوڈ ہو رہے ہیں...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(errorMessage!, style: const TextStyle(color: Colors.grey)),
          ElevatedButton(onPressed: fetchOrders, child: const Text('دوبارہ کوشش کریں')),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فلٹر کریں:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('تمام', Icons.list_alt),
                    const SizedBox(width: 8),
                    _buildFilterChip('منتظر', Icons.hourglass_bottom),
                    const SizedBox(width: 8),
                    _buildFilterChip('شیڈول', Icons.calendar_today),
                    const SizedBox(width: 8),
                    _buildFilterChip('منسوخ', Icons.cancel),
                    const SizedBox(width: 8),
                    _buildFilterChip('مکمل', Icons.check_circle),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Section
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF02A96C),
                  onRefresh: fetchOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final status = order['status'];
                      final statusText = getStatusText(status);
                      final statusIcon = getStatusIcon(status);
                      final statusColor = getStatusColor(status);
                      final isInProgress = status == STATUS_IN_PROGRESS;
                      final isCancelled = status == STATUS_CANCELLED;
                      final showCancelOption = shouldShowCancelOption(order);
                      final userName = order['Username'] ?? 'نامعلوم صارف';
                        
                      // Safe access to scheduleDate
                      final scheduleDate = order['scheduleDate'];
                      final formattedScheduleDate = formatScheduleDate(scheduleDate);
                      final hasScheduleDate = formattedScheduleDate != null;
                        
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('آرڈر #${order['_id']?.substring(0, 8) ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('تاریخ جمع کرائی', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      // Corrected formatDate usage
                                      Text(formatDate(order['createdAt']), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                                
                              const SizedBox(height: 12),
                                
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.3))),
                                    child: Row(
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  if (showCancelOption)
                                    ElevatedButton.icon(
                                      onPressed: () => _showCancelConfirmation(order['_id'], userName),
                                      icon: const Icon(Icons.cancel, size: 16),
                                      label: const Text('منسوخ کریں'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    ),
                                ],
                              ),
                                
                              const SizedBox(height: 12),
                              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                                
                              _buildOrderDetail('📍', '${order['district'] ?? ''}, ${order['tehsil'] ?? ''}'),
                              _buildOrderDetail('📏', '${order['acres']} ایکڑ'),
                              _buildOrderDetail('💰', '${order['price']} روپے'),
                                
                              // 🔹 Schedule Date - Orange Box
                              if (isInProgress && hasScheduleDate)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange, width: 2)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.orange[700], size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('🗓️ شیڈول تاریخ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                                            const SizedBox(height: 6),
                                            Text(formattedScheduleDate!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                              // 🔹 Schedule Date - Green Box
                              if (!isInProgress && hasScheduleDate)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.green[700], size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('منصوبہ بندی', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[800])),
                                            const SizedBox(height: 4),
                                            Text(formattedScheduleDate!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                              if (isInProgress && !hasScheduleDate)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text('شیڈول تاریخ ابھی طے نہیں کی گئی', style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ),
                                
                              if (isCancelled && order['cancellationReason'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.red[700], size: 18),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('منسوخ ہونے کی وجہ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800])),
                                            Text(order['cancellationReason'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderDetail(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 60),
          const SizedBox(height: 20),
          const Text('کوئی آرڈر دستیاب نہیں', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ElevatedButton(onPressed: fetchOrders, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02A96C)), child: const Text('تازہ کریں', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02A96C) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? const Color(0xFF02A96C) : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF02A96C), size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF02A96C), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}