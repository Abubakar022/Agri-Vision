import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StatelessWidget {
  final OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Obx(() {
        final stats = orderController.orderStats;
        
        if (stats.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Order Status Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status Distribution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: (stats['pending'] ?? 0).toDouble(),
                                color: Colors.orange,
                                title: 'Pending',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: (stats['completed'] ?? 0).toDouble(),
                                color: Colors.green,
                                title: 'Completed',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: (stats['cancelled'] ?? 0).toDouble(),
                                color: Colors.red,
                                title: 'Cancelled',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: (stats['inProgress'] ?? 0).toDouble(),
                                color: Colors.blue,
                                title: 'In Progress',
                                radius: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Detailed Stats
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 3,
                children: [
                  _buildStatItem('Total Orders', stats['totalOrders']?.toString() ?? '0', Icons.shopping_cart),
                  _buildStatItem('Pending Orders', stats['pending']?.toString() ?? '0', Icons.pending),
                  _buildStatItem('Completed Orders', stats['completed']?.toString() ?? '0', Icons.check_circle),
                  _buildStatItem('Cancelled Orders', stats['cancelled']?.toString() ?? '0', Icons.cancel),
                  _buildStatItem('In Progress', stats['inProgress']?.toString() ?? '0', Icons.schedule),
                  _buildStatItem('Total Revenue', '\$${orderController.totalRevenue.value.toStringAsFixed(2)}', Icons.attach_money),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}