import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

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
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            allOrders = data['success'];
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
          errorMessage = 'سرور نے ${response.statusCode} کا ایرر واپس کیا۔';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'نیٹ ورک کنکشن میں مسئلہ: $e';
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

      // Postman کی طرح URL بنائیں: /user/order/:id/cancel/:userId
      final url = Uri.parse('$baseUrl/user/order/$orderId/cancel/$uid');

      // DELETE درخواست بھیجیں (صرف URL)
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
          );
          fetchOrders(); // لسٹ ریفریش کریں
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
        'کنکشن میں مسئلہ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🔹 نمبری اسٹیٹس کو پڑھنے والے اردو لیبل میں تبدیل کریں
  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'منتظر';
      case 2:
        return 'شیڈول';
      case 3:
        return 'منسوخ';
      case 4:
        return 'مکمل';
      default:
        return 'نامعلوم';
    }
  }

  // 🔹 اسٹیٹس آئیکن حاصل کریں
  IconData getStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.hourglass_bottom;
      case 2:
        return Icons.schedule;
      case 3:
        return Icons.cancel;
      case 4:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // 🔹 اسٹیٹس کا رنگ حاصل کریں
  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 🔹 چیک کریں کہ کیا منسوخ کا آپشن دکھانا چاہیے (صرف منتظر آرڈرز)
  bool shouldShowCancelOption(dynamic order) {
    final status = order['status'];
    // منسوخ صرف "تمام" یا "منتظر" فلٹر میں دکھائیں
    if (selectedFilter == 'تمام' || selectedFilter == 'منتظر') {
      // صرف منتظر آرڈرز منسوخ کیے جا سکتے ہیں (اسٹیٹس 1)
      return status == 1;
    }
    return false;
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
      textDirection: TextDirection.rtl,
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
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'خرابی',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchOrders,
              icon: const Icon(Icons.refresh),
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
            
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('تمام', Icons.list_alt),
                    const SizedBox(width: 8),
                    _buildFilterChip('منتظر', Icons.hourglass_bottom),
                    const SizedBox(width: 8),
                    _buildFilterChip('شیڈول', Icons.schedule),
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
       

        const SizedBox(height: 12),

        // 🔹 آرڈرز لسٹ
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final statusText = getStatusText(order['status']);
                    final statusIcon = getStatusIcon(order['status']);
                    final statusColor = getStatusColor(order['status']);
                    final isCancelled = order['status'] == 3;
                    final showCancelOption = shouldShowCancelOption(order);
                    final userName = order['Username'] ?? 'نامعلوم صارف';

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
                                      backgroundColor: const Color(0xFF02A96C),
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
                            
                            const SizedBox(height: 8),
                            
                            // آرڈر کی تفصیلات
                            _buildOrderDetail('📍', '${order['district'] ?? ''}, ${order['tehsil'] ?? ''}'),
                            _buildOrderDetail('📏', '${order['acres']} ایکڑ'),
                            _buildOrderDetail('💰', '${order['price']} روپے'),
                            
                            if (isCancelled && order['cancellationReason'] != null)
                              _buildOrderDetail('❌', 'وجہ: ${order['cancellationReason']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 🔹 آرڈر کی تفصیل قطار
  Widget _buildOrderDetail(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
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
      )
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
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.grey[400],
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'کوئی آرڈر دستیاب نہیں',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'آپ کے پاس ابھی تک کوئی آرڈر نہیں ہے۔',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('تازہ کریں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02A96C),
                foregroundColor: Colors.white,
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