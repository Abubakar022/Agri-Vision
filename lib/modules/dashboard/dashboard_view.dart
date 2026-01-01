import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/widgets/order_card.dart';
import 'package:admin_app/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              orderController.fetchOrders();
              orderController.fetchStats();
              orderController.fetchTotalRevenue();
            },
          ),
        ],
      ),
      body: Obx(() {
        /// ---- REAL COUNTS ----
        final pendingCount =
            orderController.orders.where((o) => o.status == 1).length;
        final completedCount =
            orderController.orders.where((o) => o.status == 2).length;
        final cancelledCount =
            orderController.orders.where((o) => o.status == 3).length;
        final inProgressCount =
            orderController.orders.where((o) => o.status == 4).length;
        final totalOrders = orderController.orders.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= STATS =================
              GridView.count(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  StatCard(
                    title: 'Total Revenue',
                    value:
                        '\$${orderController.totalRevenue.value.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Total Orders',
                    value: totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: 'Pending',
                    value: pendingCount.toString(),
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Completed',
                    value: completedCount.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'In Progress',
                    value: inProgressCount.toString(),
                    icon: Icons.schedule,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: 'Cancelled',
                    value: cancelledCount.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ================= ORDER SUMMARY =================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatusBar(
                          'Pending', pendingCount, totalOrders, Colors.orange),
                      const SizedBox(height: 12),
                      _buildStatusBar('Completed', completedCount, totalOrders,
                          Colors.green),
                      const SizedBox(height: 12),
                      _buildStatusBar('In Progress', inProgressCount,
                          totalOrders, Colors.blue),
                      const SizedBox(height: 12),
                      _buildStatusBar('Cancelled', cancelledCount, totalOrders,
                          Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ================= RECENT ORDERS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/orders'),
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// ================= ORDERS LIST =================
              if (orderController.isLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (orderController.orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: orderController.orders.take(5).map((order) {
                    return OrderCard(
                      order: order,
                      onTap: () {
                        // FIXED: Use route parameter with the order ID
                        Get.toNamed('/order/${order.id}');
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// ================= STATUS BAR =================
  Widget _buildStatusBar(
      String status, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(status,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: total > 0 ? count / total : 0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}