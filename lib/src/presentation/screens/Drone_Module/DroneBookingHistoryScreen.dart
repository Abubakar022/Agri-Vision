import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';

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
          errorMessage = 'یوزر آئی ڈی نہیں ملی۔ دوبارہ لاگ ان کریں۔';
          isLoading = false;
        });
        return;
      }

      // 🔹 Step 2: API call with userId
      final url = Uri.parse('http://10.0.2.2:3000/getOrderData?userId=$uid');
      final response = await http.get(url);

      // 🔹 Step 3: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            allOrders = data['success'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'ڈیٹا حاصل کرنے میں مسئلہ۔';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'سرور نے ${response.statusCode} کا error واپس کیا۔';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'مسئلہ پیش آیا: $e';
        isLoading = false;
      });
    }
  }

  // 🔹 Convert numeric status → readable Urdu label
  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'منتظر'; // waiting
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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF02a96c),
          title: const Text(
            'آرڈر کی تاریخ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF02a96c)))
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: fetchOrders,
                            icon: const Icon(Icons.refresh),
                            label: const Text('دوبارہ کوشش کریں'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02a96c),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : buildOrderList(),
      ),
    );
  }

  // 🔹 Orders List UI
  Widget buildOrderList() {
    return Column(
      children: [
        // 🔹 Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                buildFilterChip('تمام', Icons.list),
                const SizedBox(width: 8),
                buildFilterChip('منتظر', Icons.hourglass_bottom),
                const SizedBox(width: 8),
                buildFilterChip('شیڈول', Icons.schedule_outlined),
                const SizedBox(width: 8),
                buildFilterChip('منسوخ', Icons.cancel_outlined),
                const SizedBox(width: 8),
                buildFilterChip('مکمل', Icons.check_circle_outline),
              ],
            ),
          ),
        ),

        // 🔹 Orders List
        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(
                  child: Text(
                    'کوئی آرڈر دستیاب نہیں۔',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final statusText = getStatusText(order['status']);
                    final isCancelled = order['status'] == 3;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF02a96c),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          order['Username'] ?? 'نامعلوم صارف',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'علاقہ: ${order['district'] ?? ''}, ${order['tehsil'] ?? ''}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'رقبہ: ${order['acres']} ایکڑ',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'قیمت: ${order['price']} روپے',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (isCancelled &&
                                order['cancellationReason'] != null)
                              Text(
                                'وجہ: ${order['cancellationReason']}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: order['status'] == 4
                                ? Colors.green[100]
                                : order['status'] == 3
                                    ? Colors.red[100]
                                    : order['status'] == 2
                                        ? Colors.orange[100]
                                        : Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: order['status'] == 4
                                  ? Colors.green[800]
                                  : order['status'] == 3
                                      ? Colors.red[800]
                                      : order['status'] == 2
                                          ? Colors.orange[800]
                                          : Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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

  // 🔹 Filter Button Widget
  Widget buildFilterChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02a96c) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF02a96c) : Colors.grey.shade300,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF02a96c).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : const Color(0xFF02a96c),
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
