import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/app/models/order_model.dart';
import 'package:admin_app/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersView extends StatelessWidget {
  OrdersView({Key? key}) : super(key: key);

  final OrderController orderController = Get.find();

  // CORRECT: List of Maps, not List of Strings
  final List<Map<String, dynamic>> statusFilters = [
    {'value': 'all', 'label': 'All Orders', 'color': Colors.grey},
    {'value': 'pending', 'label': 'Pending', 'color': Colors.orange},
    {'value': 'Scheduled', 'label': 'In Progress', 'color': Colors.blue},
    {'value': 'completed', 'label': 'Completed', 'color': Colors.green},
    {'value': 'cancelled', 'label': 'Cancelled', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Management'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Filter Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Filter by Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Obx(() {
                      // Safe access to selectedStatus
                      final selectedStatus =
                          orderController.selectedStatus.value;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: statusFilters.length,
                        itemBuilder: (context, index) {
                          final filter = statusFilters[index];
                          final isSelected = selectedStatus == filter['value'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                filter['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                orderController.selectedStatus.value =
                                    filter['value'] as String;
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: filter['color'] as Color,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),

            // Orders Count Summary
            Obx(() {
              try {
                final pendingCount = orderController.orders
                    .where((o) => o.status == 1)
                    .length;
                final inProgressCount = orderController.orders
                    .where((o) => o.status == 4)
                    .length;
                final completedCount = orderController.orders
                    .where((o) => o.status == 2)
                    .length;
                final cancelledCount = orderController.orders
                    .where((o) => o.status == 3)
                    .length;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusCount('Pending', pendingCount, Colors.orange),
                      _buildStatusCount(
                        'Scheduled',
                        inProgressCount,
                        Colors.blue,
                      ),
                      _buildStatusCount(
                        'Completed',
                        completedCount,
                        Colors.green,
                      ),
                      _buildStatusCount(
                        'Cancelled',
                        cancelledCount,
                        Colors.red,
                      ),
                    ],
                  ),
                );
              } catch (e) {
                print('Error in status count: $e');
                return SizedBox(height: 60);
              }
            }),

            Expanded(
              child: Obx(() {
                if (orderController.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading orders...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                try {
                  // Get filtered orders
                  final orders = _getFilteredOrders();

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            orderController.selectedStatus.value == 'all'
                                ? 'Start by creating your first order'
                                : 'No ${orderController.selectedStatus.value} orders',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 16),
                          if (orderController.selectedStatus.value != 'all')
                            ElevatedButton(
                              onPressed: () {
                                orderController.selectedStatus.value = 'all';
                              },
                              child: Text('View All Orders'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await orderController.fetchOrders();
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return InkWell(
                          onTap: () => Get.toNamed('/order/${order.id}'),
                          borderRadius: BorderRadius.circular(12),
                          child: OrderCard(order: order),
                        );
                      },
                    ),
                  );
                } catch (e) {
                  print('Error loading orders: $e');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => orderController.fetchOrders(),
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => orderController.fetchOrders(),
        child: Icon(Icons.refresh, color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
    );
  }

  // Helper method to filter orders
  List<Order> _getFilteredOrders() {
    try {
      final selectedStatus = orderController.selectedStatus.value;

      if (selectedStatus == 'all') {
        return orderController.orders;
      }

      // Map status names to codes (1=Pending, 2=Completed, 3=Cancelled, 4=In Progress)
      final statusMap = {
        'pending': 1,
        'completed': 2,
        'cancelled': 3,
        'Scheduled': 4,
      };

      final statusCode = statusMap[selectedStatus];
      if (statusCode == null) return orderController.orders;

      return orderController.orders
          .where((order) => order.status == statusCode)
          .toList();
    } catch (e) {
      print('Error filtering orders: $e');
      return orderController.orders;
    }
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
