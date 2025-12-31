import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/widgets/charts/revenue_chart.dart';
import 'package:admin_app/widgets/order_card.dart';
import 'package:admin_app/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DashboardView extends StatelessWidget {
  final OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              orderController.fetchOrders();
              orderController.fetchStats();
              orderController.fetchTotalRevenue();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Obx(() => GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  title: 'Total Revenue',
                  value: '\$${orderController.totalRevenue.value.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'Total Orders',
                  value: orderController.orderStats['totalOrders']?.toString() ?? '0',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Pending',
                  value: orderController.orderStats['pending']?.toString() ?? '0',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Completed',
                  value: orderController.orderStats['completed']?.toString() ?? '0',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            )),

            SizedBox(height: 24),

            // Revenue Chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: RevenueChart(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/orders'),
                  child: Text('View All'),
                ),
              ],
            ),

            Obx(() => orderController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: orderController.orders
                        .take(5)
                        .map((order) => OrderCard(order: order))
                        .toList(),
                  )),
          ],
        ),
      ),
    );
  }
}