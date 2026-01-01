import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


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
  
  // 🔹 Status Enum Constants (مطابق MongoDB Schema)
  static const int STATUS_PENDING = 1;        // Pending
  static const int STATUS_SCHEDULED = 2;      // Scheduled
  static const int STATUS_CANCELLED = 3;      // Cancelled
  static const int STATUS_COMPLETED = 4;      // Completed
  
  // 🔹 بیک اینڈ URL
  static const String baseUrl = 'https://agrivision-backend-1075549714370.us-central1.run.app';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchOrders();
    });
  }

  // 🔹 MongoDB API سے ڈیٹا حاصل کریں (userId کے مطابق فلٹر کریں)
  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
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
          // آرڈرز کو تاریخ کے لحاظ سے ترتیب دیں (تازہ ترین پہلے)
          List<dynamic> orders = List.from(data['success']);
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
        String errorDetail = 'سرور نے ${response.statusCode} کا جواب دیا۔';
        if (response.statusCode == 404) {
          errorDetail = 'سرور URL غلط ہے۔';
        } else if (response.statusCode == 500) {
          errorDetail = 'سرور میں اندرونی خرابی۔';
        } else if (response.statusCode == 401) {
          errorDetail = 'آپ کا سیشن ختم ہو گیا ہے۔ براہ کرم دوبارہ لاگ ان کریں۔';
        }
        
        setState(() {
          errorMessage = errorDetail;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup')) {
          errorMessage = 'نیٹ ورک کنکشن نہیں ہے۔ براہ کرم انٹرنیٹ چیک کریں۔';
        } else if (e.toString().contains('FormatException')) {
          errorMessage = 'سرور سے غلط ڈیٹا موصول ہوا۔';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'سرور سے جواب کا انتظار بہت دیر ہو گیا۔';
        } else {
          errorMessage = 'ایک غیر متوقع خرابی پیش آئی: ${e.toString().split('\n').first}';
        }
        isLoading = false;
      });
    }
  }

  // 🔹 آرڈر منسوخ کرنے سے پہلے تصدیقی ڈائیلاگ دکھائیں
  Future<void> _showCancelConfirmation(String orderId, String userName) async {
    final bool? result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // انتباہی آئیکن
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // عنوان
              const Text(
                'آرڈر منسوخ کریں',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // پیغام
              Text(
                'کیا آپ واقعی آرڈر منسوخ کرنا چاہتے ہیں؟',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'یہ عمل واپس نہیں لیا جا سکتا۔',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // بٹنوں کی قطار
              Row(
                children: [
                  // نہیں بٹن
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'نہیں',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // ہاں بٹن (گرین تھیم)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02A96C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ہاں، منسوخ کریں',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // 🔹 آرڈر منسوخ کرنے کی فنکشن
  Future<void> cancelOrder(String orderId, String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');

      if (uid == null || uid.isEmpty) {
        Get.snackbar(
          'خرابی', 
          'یوزر آئی ڈی نہیں ملی۔ براہ کرم دوبارہ لاگ ان کریں۔',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final url = Uri.parse('$baseUrl/user/order/$orderId/cancel/$uid');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Get.snackbar(
            'کامیابی',
            'آرڈر کامیابی سے منسوخ ہو گیا',
            backgroundColor: const Color(0xFF02A96C),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          
          // آرڈر کی اسٹیٹس اپڈیٹ کریں
          setState(() {
            final index = allOrders.indexWhere((order) => order['_id'] == orderId);
            if (index != -1) {
              allOrders[index]['status'] = STATUS_CANCELLED;
              allOrders[index]['cancellationReason'] = data['cancellationReason'] ?? 'صارف کی جانب سے منسوخ';
            }
          });
          
          // مختصر تاخیر کے بعد ریفریش کریں
          Future.delayed(const Duration(milliseconds: 500), fetchOrders);
        } else {
          Get.snackbar(
            'خرابی',
            data['message'] ?? 'آرڈر منسوخ کرنے میں مسئلہ',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'خرابی',
          'آرڈر نہیں ملا۔',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 403) {
        Get.snackbar(
          'خرابی',
          'آپ کے پاس اس آرڈر کو منسوخ کرنے کی اجازت نہیں ہے۔',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خرابی',
          'سرور نے ${response.statusCode} کا ایرر واپس کیا۔',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خرابی',
        'کنکشن میں مسئلہ: ${e.toString().split('\n').first}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🔹 نمبری اسٹیٹس کو پڑھنے والے اردو لیبل میں تبدیل کریں
  String getStatusText(int status) {
    switch (status) {
      case STATUS_PENDING:
        return 'منتظر';
      case STATUS_SCHEDULED:
        return 'شیڈول';
      case STATUS_CANCELLED:
        return 'منسوخ';
      case STATUS_COMPLETED:
        return 'مکمل';
      default:
        return 'نامعلوم';
    }
  }

  // 🔹 اسٹیٹس آئیکن حاصل کریں
  IconData getStatusIcon(int status) {
    switch (status) {
      case STATUS_PENDING:
        return Icons.hourglass_bottom;
      case STATUS_SCHEDULED:
        return Icons.calendar_today;
      case STATUS_CANCELLED:
        return Icons.cancel;
      case STATUS_COMPLETED:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // 🔹 اسٹیٹس کا رنگ حاصل کریں
  Color getStatusColor(int status) {
    switch (status) {
      case STATUS_PENDING:
        return Colors.blue;
      case STATUS_SCHEDULED:
        return Colors.orange;
      case STATUS_CANCELLED:
        return Colors.red;
      case STATUS_COMPLETED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 🔹 تاریخ فارمیٹ کرنے کی فنکشن
  String formatDate(String? dateString) {
    if (dateString == null) return 'تاریخ دستیاب نہیں';
    
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('dd-MMM-yyyy hh:mm a', 'ur');
      return format.format(date);
    } catch (e) {
      return 'غلط تاریخ';
    }
  }

  // 🔹 شیڈول تاریخ فارمیٹ کرنے کی فنکشن
  String formatScheduleDate(String? dateString) {
    if (dateString == null) return 'شیڈول نہیں';
    
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('dd-MMM-yyyy', 'ur');
      return format.format(date);
    } catch (e) {
      return 'غلط تاریخ';
    }
  }

  // 🔹 چیک کریں کہ کیا منسوخ کا آپشن دکھانا چاہیے (صرف منتظر آرڈرز)
  bool shouldShowCancelOption(dynamic order) {
    final status = order['status'];
    // صرف منتظر آرڈرز منسوخ کیے جا سکتے ہیں
    return status == STATUS_PENDING && 
           (selectedFilter == 'تمام' || selectedFilter == 'منتظر');
  }

  // 🔹 منتخب فلٹر کے مطابق فلٹرڈ لسٹ
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
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'آرڈر ہسٹری',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchOrders,
              tooltip: 'تازہ کریں',
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

  // 🔹 لوڈنگ اسٹیٹ
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF02A96C),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'آرڈرز لوڈ ہو رہے ہیں...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'براہ کرم انتظار کریں',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 خرابی اسٹیٹ
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'خرابی',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: fetchOrders,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'دوبارہ کوشش کریں',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02A96C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text(
                    'واپس جائیں',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 آرڈرز لسٹ UI
  Widget _buildOrderList() {
    return Column(
      children: [
        // 🔹 فلٹر چپس سیکشن
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فلٹر کریں:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
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

        // 🔹 آرڈرز کا شمار
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'کل آرڈرز: ${allOrders.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'دکھائے جا رہے ہیں: ${filteredOrders.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🔹 منسوخ کے آپشن کے لیے ہدایات
        if (selectedFilter == 'تمام' || selectedFilter == 'منتظر')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'صرف "منتظر" والے آرڈرز منسوخ کیے جا سکتے ہیں',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // 🔹 آرڈرز لسٹ
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
                      final isScheduled = status == STATUS_SCHEDULED;
                      final isCancelled = status == STATUS_CANCELLED;
                      final showCancelOption = shouldShowCancelOption(order);
                      final userName = order['Username'] ?? 'نامعلوم صارف';
                      final scheduleDate = order['scheduleDate'];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // آرڈر آئی ڈی اور تاریخ
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'آرڈر #${order['_id']?.substring(0, 8) ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    formatDate(order['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // اسٹیٹس اور منسوخ بٹن کے ساتھ ہیڈر قطار
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // اسٹیٹس بیج
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: statusColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // منسوخ بٹن (صرف منتظر آرڈرز کے لیے)
                                  if (showCancelOption)
                                    ElevatedButton.icon(
                                      onPressed: () => _showCancelConfirmation(order['_id'], userName),
                                      icon: const Icon(Icons.cancel, size: 16),
                                      label: const Text('منسوخ کریں'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // صارف کی معلومات
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // آرڈر کی تفصیلات
                              _buildOrderDetail('📍', '${order['district'] ?? ''}, ${order['tehsil'] ?? ''}'),
                              _buildOrderDetail('📏', '${order['acres']} ایکڑ'),
                              _buildOrderDetail('💰', '${order['price']} روپے'),
                              
                              // شیڈول تاریخ (اگر موجود ہو)
                              if (isScheduled && scheduleDate != null)
                                _buildOrderDetail(
                                  '📅',
                                  'شیڈول تاریخ: ${formatScheduleDate(scheduleDate)}'
                                ),
                              
                              // منسوخ ہونے کی وجہ
                              if (isCancelled && order['cancellationReason'] != null)
                                _buildOrderDetail('❌', 'وجہ منسوخی: ${order['cancellationReason']}'),
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

  // 🔹 آرڈر کی تفصیل قطار
  Widget _buildOrderDetail(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 خالی اسٹیٹ
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey[400],
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'کوئی آرڈر دستیاب نہیں',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'تمام'
                  ? 'آپ کے پاس ابھی تک کوئی آرڈر نہیں ہے۔'
                  : 'اس فلٹر کے تحت کوئی آرڈر نہیں ہے۔',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('تازہ کریں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02A96C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 فلٹر چپ ویجٹ
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
          border: Border.all(
            color: isSelected ? const Color(0xFF02A96C) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF02A96C).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF02A96C),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF02A96C),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}