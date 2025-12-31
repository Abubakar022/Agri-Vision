import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrdersView extends StatelessWidget {
  final OrderController orderController = Get.find();
  final List<String> statusFilters = ['all', 'pending', 'in-progress', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: statusFilters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter.capitalizeFirst!),
                      selected: orderController.selectedStatus.value == filter,
                      onSelected: (selected) {
                        orderController.selectedStatus.value = filter;
                      },
                    ),
                  );
                }).toList(),
              )),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              final orders = orderController.filteredOrders;
              
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/order/${order.id}'),
                      child: OrderCard(order: order),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => orderController.fetchOrders(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}