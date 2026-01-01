import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class OrderDetailView extends StatelessWidget {
  final OrderController orderController = Get.find();
  
  @override
  Widget build(BuildContext context) {
    // SAFE way to get orderId from parameters
    final orderId = Get.parameters['id'];
    
    // If no orderId is provided, show error
    if (orderId == null || orderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Order ID is missing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please go back and select an order',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      // Find the order in the controller
      final order = orderController.orders.firstWhereOrNull((o) => o.id == orderId);

      if (order == null) {
        // If order not found in controller, show loading or not found
        if (orderController.isLoading.value) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Order Not Found'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Order not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Order ID: $orderId'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    orderController.fetchOrders();
                    Get.back();
                  },
                  child: Text('Refresh & Go Back'),
                ),
              ],
            ),
          ),
        );
      }

      return _buildOrderDetail(order);
    });
  }

  Widget _buildOrderDetail(Order order) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_all),
            onPressed: () => _copyAllDetails(order),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(order.id),
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
                    IconButton(
                      icon: Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: order.id));
                        Get.snackbar(
                          'Copied!',
                          'Order ID copied to clipboard',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      tooltip: 'Copy Order ID',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
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
                _buildInfoRowWithCopy('Name', order.username),
                _buildInfoRowWithCopy('Phone', order.phone, isPhone: true),
                _buildInfoRowWithCopy('User ID', order.userId),
              ],
            ),

            SizedBox(height: 20),

            // Order Information
            _buildSection(
              title: 'Order Information',
              icon: Icons.shopping_cart,
              children: [
                _buildInfoRowWithCopy('Acres', '${order.acres} acres'),
                _buildInfoRowWithCopy('Price', '\$${order.price}'),
                _buildInfoRow('Address', '${order.address}, ${order.city}', showCopy: true),
                _buildInfoRowWithCopy('District', order.district),
                _buildInfoRowWithCopy('Tehsil', order.tehsil),
                _buildInfoRowWithCopy('City', order.city),
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
                    showCopy: true,
                  ),
                  _buildInfoRow(
                    'Time',
                    DateFormat('hh:mm a').format(order.scheduleDate!),
                    showCopy: true,
                  ),
                  if (order.scheduleDate!.isBefore(DateTime.now()))
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Schedule date has passed',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                  showCopy: true,
                ),
                _buildInfoRow(
                  'Last Updated',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.updatedAt),
                  showCopy: true,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.cancellationReason!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 18, color: Colors.red),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: order.cancellationReason!));
                          Get.snackbar(
                            'Copied!',
                            'Cancellation reason copied',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        },
                        tooltip: 'Copy cancellation reason',
                        padding: EdgeInsets.only(left: 8),
                      ),
                    ],
                  ),
                ],
              ),

            SizedBox(height: 30),

            // Quick Copy Actions Card
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.copy_all, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Quick Copy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: Icon(Icons.phone, size: 16),
                          label: Text('Copy Phone'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: order.phone));
                            Get.snackbar(
                              'Copied!',
                              'Phone number copied',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                        ActionChip(
                          avatar: Icon(Icons.person, size: 16),
                          label: Text('Copy Name'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: order.username));
                            Get.snackbar(
                              'Copied!',
                              'Customer name copied',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                        ActionChip(
                          avatar: Icon(Icons.location_on, size: 16),
                          label: Text('Copy Address'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${order.address}, ${order.city}'));
                            Get.snackbar(
                              'Copied!',
                              'Address copied',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                        ActionChip(
                          avatar: Icon(Icons.agriculture, size: 16),
                          label: Text('Copy Acres'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${order.acres} acres'));
                            Get.snackbar(
                              'Copied!',
                              'Acres copied',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                        ActionChip(
                          avatar: Icon(Icons.attach_money, size: 16),
                          label: Text('Copy Price'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '\$${order.price}'));
                            Get.snackbar(
                              'Copied!',
                              'Price copied',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(order),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopy = false}) {
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (showCopy && value.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      _showCopySuccess(label);
                    },
                    tooltip: 'Copy $label',
                    padding: EdgeInsets.only(left: 8),
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithCopy(String label, String value, {bool isPhone = false}) {
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isPhone ? Colors.blue : null,
                    ),
                  ),
                ),
                if (value.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: isPhone ? Colors.blue : null),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      _showCopySuccess(label, isPhone: isPhone);
                    },
                    tooltip: 'Copy $label',
                    padding: EdgeInsets.only(left: 8),
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCopySuccess(String label, {bool isPhone = false}) {
    String message = isPhone 
      ? 'Phone number copied to clipboard'
      : '$label copied to clipboard';
    
    Get.snackbar(
      'Copied!',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 1),
    );
  }

  void _copyAllDetails(Order order) {
    final details = '''
Order Details:
---------------
Customer: ${order.username}
Phone: ${order.phone}
User ID: ${order.userId}

Order Information:
------------------
Acres: ${order.acres}
Price: \$${order.price}
Address: ${order.address}, ${order.city}
District: ${order.district}
Tehsil: ${order.tehsil}
City: ${order.city}

Status: ${order.statusText}

Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt)}
Updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.updatedAt)}
${order.scheduleDate != null ? 'Scheduled: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.scheduleDate!)}' : ''}
${order.cancellationReason != null ? 'Cancellation Reason: ${order.cancellationReason}' : ''}
''';

    Clipboard.setData(ClipboardData(text: details));
    Get.snackbar(
      'Copied!',
      'All order details copied to clipboard',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
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

Widget _buildActionButtons(Order order) {
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
            
            // PENDING ORDERS (status 1)
            if (order.status == 1)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showScheduleDialog(order.id),
                    icon: Icon(Icons.schedule),
                    label: Text('Schedule Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showCancelDialog(order.id),
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            
            // IN PROGRESS ORDERS (status 4) - Already scheduled
            if (order.status == 4)
              Column(
                children: [
                  if (order.scheduleDate != null)
                    Column(
                      children: [
                        // Only show Complete button if scheduled date has passed
                        if (order.scheduleDate!.isBefore(DateTime.now()))
                          ElevatedButton.icon(
                            onPressed: () => _completeOrder(order.id),
                            icon: Icon(Icons.check_circle),
                            label: Text('Mark as Completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        
                        if (order.scheduleDate!.isBefore(DateTime.now()))
                          SizedBox(height: 12),
                        
                        // Reschedule option
                        ElevatedButton.icon(
                          onPressed: () => _showScheduleDialog(order.id),
                          icon: Icon(Icons.calendar_today),
                          label: Text('Reschedule'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showCancelDialog(order.id),
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            
            // COMPLETED ORDERS (status 2) - Show completed message only
            if (order.status == 2)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order has been completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // CANCELLED ORDERS (status 3) - Show cancelled message only, NO buttons
            if (order.status == 3)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order has been cancelled',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (order.cancellationReason != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Reason: ${order.cancellationReason}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // If order is scheduled but schedule date is in future (info only)
            if (order.status == 4 && 
                order.scheduleDate != null && 
                order.scheduleDate!.isAfter(DateTime.now()))
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Order is scheduled',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This order can only be completed after the scheduled date (${DateFormat('MMM dd, yyyy').format(order.scheduleDate!)})',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
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

  void _showDeleteDialog(String orderId) {
    showDialog(
      context: Get.context!,
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

  void _showCancelDialog(String orderId) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: Get.context!,
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
              if (reasonController.text.trim().isNotEmpty) {
                orderController.updateOrderStatus(orderId, 3, reason: reasonController.text);
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

  void _showScheduleDialog(String orderId) {
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);

    void updateSchedule() {
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      
      if (scheduledDateTime.isBefore(DateTime.now())) {
        Get.snackbar('Error', 'Schedule date must be in the future');
        return;
      }
      
      orderController.scheduleOrder(orderId, scheduledDateTime);
    }

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
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
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Scheduled for: ${DateFormat('MMM dd, yyyy - hh:mm a').format(
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      )
                    )}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
          );
        },
      ),
    );
  }

  void _completeOrder(String orderId) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Complete Order'),
        content: Text('Are you sure you want to mark this order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              orderController.updateOrderStatus(orderId, 2);
              Get.back();
            },
            child: Text('Complete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}