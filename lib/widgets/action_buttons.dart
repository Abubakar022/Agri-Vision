import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class ActionButtons extends StatelessWidget {
  final Order order;
  final OrderController orderController = Get.find();

  ActionButtons({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order.status == 1)
                  _btn(Icons.check, 'Accept', Colors.green, _acceptOrder),

                if (order.status == 4)
                  _btn(Icons.done_all, 'Complete', Colors.blue,
                      () => orderController.updateOrderStatus(order.id, 2)),

                if (order.status == 1 || order.status == 4)
                  _btn(Icons.cancel, 'Cancel', Colors.red,
                      () => _showCancelDialog(context)),

                _btn(Icons.schedule, 'Schedule', null,
                    () => _showScheduleDialog(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(
      IconData icon, String label, Color? color, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 40),
      ),
    );
  }

  void _acceptOrder() {
    orderController.updateOrderStatus(order.id, 4);
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide cancellation reason'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reasonController.text.isEmpty) {
                Get.snackbar('Error', 'Reason required');
                return;
              }
              orderController.updateOrderStatus(
                order.id,
                3,
                reason: reasonController.text,
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Select Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) date = picked;
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Select Time'),
                subtitle: Text(time.format(context)),
                onTap: () async {
                  final picked =
                      await showTimePicker(context: context, initialTime: time);
                  if (picked != null) time = picked;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final scheduled = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              orderController.scheduleOrder(order.id, scheduled);
              Get.back();
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}
