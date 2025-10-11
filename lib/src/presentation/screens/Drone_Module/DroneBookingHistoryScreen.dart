import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedFilter = 'تمام';

  // Mock data — replace later with Firebase or API
  final List<Map<String, String>> orders = [
    {
      'id': '001',
      'status': 'مکمل',
      'service': 'ڈرون اسپرے',
      'date': '2025-10-08',
    },
    {
      'id': '002',
      'status': 'منسوخ',
      'service': 'کھاد سپلائی',
      'date': '2025-10-09',
      'reason': 'گاہک نے آرڈر منسوخ کر دیا۔',
    },
    {
      'id': '003',
      'status': 'شیڈول',
      'service': 'زرعی مشاورت',
      'date': '2025-10-11',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data according to user selection
    final filteredOrders = selectedFilter == 'تمام'
        ? orders
        : orders.where((o) => o['status'] == selectedFilter).toList();

    return Directionality( // Makes all text right-to-left
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
        body: Column(
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
                    buildFilterChip('مکمل', Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    buildFilterChip('منسوخ', Icons.cancel_outlined),
                    const SizedBox(width: 8),
                    buildFilterChip('شیڈول', Icons.schedule_outlined),
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
                        final isCancelled = order['status'] == 'منسوخ';

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
                                order['id']!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              order['service']!,
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
                                  'تاریخ: ${order['date']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (isCancelled && order['reason'] != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'وجہ: ${order['reason']}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: order['status'] == 'مکمل'
                                    ? Colors.green[100]
                                    : order['status'] == 'منسوخ'
                                        ? Colors.red[100]
                                        : Colors.orange[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order['status']!,
                                style: TextStyle(
                                  color: order['status'] == 'مکمل'
                                      ? Colors.green[800]
                                      : order['status'] == 'منسوخ'
                                          ? Colors.red[800]
                                          : Colors.orange[800],
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
        ),
      ),
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
