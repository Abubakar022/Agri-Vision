import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
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

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // 🔹 Fetch data from MongoDB API (filtered by userId)
  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 🔹 Step 1: Get Firebase UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null || uid.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        uid = prefs.getString('userId');
      }

      if (uid == null || uid.isEmpty) {
        setState(() {
          errorMessage = 'یوزر آئی ڈی نہیں ملی۔ براہ کرم دوبارہ لاگ ان کریں۔';
          isLoading = false;
        });
        _showErrorSnackbar('یوزر آئی ڈی نہیں ملی۔ براہ کرم دوبارہ لاگ ان کریں۔');
        return;
      }

      // 🔹 Step 2: API call with userId
      final url = Uri.parse('https://agri-node-backend-1075549714370.us-central1.run.app/getOrderData?userId=$uid');
      final response = await http.get(url);

      // 🔹 Step 3: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            allOrders = data['success'];
            isLoading = false;
          });
          _showSuccessSnackbar('آرڈرز کی معلومات کامیابی سے لوڈ ہو گئیں');
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'ڈیٹا حاصل کرنے میں مسئلہ پیش آیا۔';
            isLoading = false;
          });
          _showErrorSnackbar(data['message'] ?? 'ڈیٹا حاصل کرنے میں مسئلہ پیش آیا۔');
        }
      } else {
        setState(() {
          errorMessage = 'سرور نے ${response.statusCode} کا ایرر واپس کیا۔';
          isLoading = false;
        });
        _showErrorSnackbar('سرور نے ${response.statusCode} کا ایرر واپس کیا۔');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'نیٹ ورک کنکشن میں مسئلہ: $e';
        isLoading = false;
      });
      _showErrorSnackbar('نیٹ ورک کنکشن میں مسئلہ۔ براہ کرم چیک کریں۔');
    }
  }

  // 🔹 Show error snackbar with RTL support
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'خرابی',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      titleText: Directionality(
        textDirection: TextDirection.rtl,
        child: const Text(
          'خرابی',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔹 Show success snackbar with RTL support
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'کامیابی',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF02A96C),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      titleText: Directionality(
        textDirection: TextDirection.rtl,
        child: const Text(
          'کامیابی',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔹 Convert numeric status → readable Urdu label
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

  // 🔹 Get status icon
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

  // 🔹 Get status color
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

  // 🔹 Filtered list according to selected filter
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
        backgroundColor: const Color(0xFFFDF8E3), // Same as previous screens
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

  // 🔹 Loading State
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

  // 🔹 Error State
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
            Text(
              'خرابی',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
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

  // 🔹 Orders List UI
  Widget _buildOrderList() {
    return Column(
      children: [
        // 🔹 Filter Chips Section
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
                'فلٹرز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02A96C),
                ),
              ),
              const SizedBox(height: 12),
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

        // 🔹 Orders Count
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

        // 🔹 Orders List
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final statusText = getStatusText(order['status']);
                    final statusIcon = getStatusIcon(order['status']);
                    final statusColor = getStatusColor(order['status']);
                    final isCancelled = order['status'] == 3;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF02A96C).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: const Color(0xFF02A96C),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          order['Username'] ?? 'نامعلوم صارف',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            _buildOrderDetail('📍', '${order['district'] ?? ''}, ${order['tehsil'] ?? ''}'),
                            _buildOrderDetail('📏', '${order['acres']} ایکڑ'),
                            _buildOrderDetail('💰', '${order['price']} روپے'),
                            if (isCancelled && order['cancellationReason'] != null)
                              _buildOrderDetail('❌', 'وجہ: ${order['cancellationReason']}'),
                          ],
                        ),
                        trailing: Container(
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 🔹 Order Detail Row
  Widget _buildOrderDetail(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Empty State
  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  // 🔹 Filter Chip Widget
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