import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
class OrderDetailView extends StatelessWidget {
  final OrderController orderController = Get.find();
  final String orderId = Get.parameters['id']!;

  @override
  Widget build(BuildContext context) {
    final order = orderController.orders.firstWhereOrNull((o) => o.id == orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Not Found'),
        ),
        body: Center(
          child: Text('Order not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: order.statusColor),
                      ),
                      child: Row(
                        children: [
                          Icon(order.statusIcon, color: order.statusColor, size: 16),
                          SizedBox(width: 8),
                          Text(
                            order.statusText,
                            style: TextStyle(
                              color: order.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Customer Information
            _buildSection(
              title: 'Customer Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Name', order.username),
                _buildInfoRow('Phone', order.phone),
                _buildInfoRow('User ID', order.userId),
              ],
            ),

            SizedBox(height: 20),

            // Order Information
            _buildSection(
              title: 'Order Information',
              icon: Icons.shopping_cart,
              children: [
                _buildInfoRow('Acres', '${order.acres} acres'),
                _buildInfoRow('Price', '\$${order.price}'),
                _buildInfoRow('Address', '${order.address}, ${order.city}'),
                _buildInfoRow('District', order.district),
                _buildInfoRow('Tehsil', order.tehsil),
              ],
            ),

            SizedBox(height: 20),

            // Schedule Information
            if (order.scheduleDate != null)
              _buildSection(
                title: 'Scheduled For',
                icon: Icons.calendar_today,
                children: [
                  _buildInfoRow(
                    'Date',
                    DateFormat('MMM dd, yyyy').format(order.scheduleDate!),
                  ),
                  _buildInfoRow(
                    'Time',
                    DateFormat('hh:mm a').format(order.scheduleDate!),
                  ),
                ],
              ),

            SizedBox(height: 20),

            // Timestamps
            _buildSection(
              title: 'Timestamps',
              icon: Icons.access_time,
              children: [
                _buildInfoRow(
                  'Created',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                ),
                _buildInfoRow(
                  'Last Updated',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.updatedAt),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Cancellation Reason
            if (order.cancellationReason != null)
              _buildSection(
                title: 'Cancellation Reason',
                icon: Icons.cancel,
                children: [
                  Text(
                    order.cancellationReason!,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),

            SizedBox(height: 30),

            // Action Buttons
            ActionButtons(order: order),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order'),
        content: Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              orderController.deleteOrder(orderId);
              Get.back();
              Get.back();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}