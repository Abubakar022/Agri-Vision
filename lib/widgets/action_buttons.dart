import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ActionButtons extends StatelessWidget {
  final Order order;
  final OrderController orderController = Get.find();

  ActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (order.status == 1) // Pending
                  ElevatedButton.icon(
                    onPressed: () => _acceptOrder(),
                    icon: Icon(Icons.check),
                    label: Text('Accept'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                if (order.status == 4) // In Progress
                  ElevatedButton.icon(
                    onPressed: () => orderController.updateOrderStatus(order.id, 2),
                    icon: Icon(Icons.done_all),
                    label: Text('Mark Complete'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                if (order.status == 1 || order.status == 4)
                  ElevatedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _showScheduleDialog(context),
                  icon: Icon(Icons.schedule),
                  label: Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptOrder() {
    orderController.updateOrderStatus(order.id, 4);
  }

  void _showCancelDialog(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please provide a reason for cancellation:'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                orderController.updateOrderStatus(order.id, 3, reason: reasonController.text);
              } else {
                Get.snackbar('Error', 'Please provide a reason');
              }
            },
            child: Text('Confirm'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    void updateSchedule() {
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      orderController.scheduleOrder(order.id, scheduledDateTime);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Select Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) selectedDate = date;
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Select Time'),
              subtitle: Text(selectedTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) selectedTime = time;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: updateSchedule,
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }
}