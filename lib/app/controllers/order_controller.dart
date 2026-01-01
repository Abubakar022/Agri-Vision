import 'package:admin_app/app/models/order_model.dart';
import 'package:admin_app/app/services/api_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find();
  
  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var selectedStatus = 'all'.obs;
  var orderStats = {}.obs;
  var totalRevenue = 0.0.obs;
  
  // Add this for monthly revenue
  var monthlyRevenue = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchStats();
    fetchTotalRevenue();
  }

  Future<void> fetchOrders({String? status}) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('/admin/orders', params: status != null ? {'status': status} : null);
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];
        orders.value = data.map((json) => Order.fromJson(json)).toList();
        _calculateMonthlyRevenue(); // Calculate monthly revenue after fetching orders
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate monthly revenue from orders
  void _calculateMonthlyRevenue() {
    final Map<String, double> revenueMap = {};
    
    for (var order in orders) {
      try {
        // Only count completed orders (status 2) for revenue
        if (order.status == 2) { // Completed orders
          final month = DateFormat('MMM').format(order.createdAt);
          final price = double.tryParse(order.price) ?? 0;
          revenueMap[month] = (revenueMap[month] ?? 0) + price;
        }
      } catch (e) {
        print('Error calculating revenue for order ${order.id}: $e');
      }
    }
    
    monthlyRevenue.value = revenueMap;
  }

  // Get monthly revenue for chart (last 6 months)
  List<double> getLast6MonthsRevenue() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Get current month index
    final now = DateTime.now();
    final currentMonthIndex = now.month - 1;
    
    // Create list for last 6 months
    final List<double> last6Months = [];
    
    for (int i = 5; i >= 0; i--) {
      final monthIndex = (currentMonthIndex - i) % 12;
      final monthName = months[monthIndex];
      final revenue = monthlyRevenue[monthName] ?? 0.0;
      last6Months.add(revenue);
    }
    
    return last6Months;
  }

  // Get month names for the last 6 months
  List<String> getLast6MonthNames() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final now = DateTime.now();
    final currentMonthIndex = now.month - 1;
    
    final List<String> monthNames = [];
    
    for (int i = 5; i >= 0; i--) {
      final monthIndex = (currentMonthIndex - i) % 12;
      monthNames.add(months[monthIndex]);
    }
    
    return monthNames;
  }

  Future<void> fetchStats() async {
    try {
      final response = await _apiService.get('/admin/orders/stats');
      if (response['status'] == 'success') {
        orderStats.value = response['stats'];
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> fetchTotalRevenue() async {
    try {
      final response = await _apiService.get('/totalRevenue');
      if (response['status'] == 'success') {
        totalRevenue.value = (response['totalRevenue'] as num).toDouble();
      }
    } catch (e) {
      print('Error fetching revenue: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, int status, {String? reason}) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      
      // FIXED: reason is a String, not an int
      if (reason != null && reason.trim().isNotEmpty) {
        data['cancellationReason'] = reason; // Just assign the string directly
      }
      
      await _apiService.put('/admin/order/$orderId/status', data);
      await fetchOrders();
      Get.back();
      Get.snackbar('Success', 'Order status updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Future<void> scheduleOrder(String orderId, DateTime scheduleDate) async {
    try {
      await _apiService.put('/admin/order/$orderId/schedule', {
        'scheduleDate': scheduleDate.toIso8601String(),
      });
      await fetchOrders();
      Get.back();
      Get.snackbar('Success', 'Order scheduled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _apiService.delete('/admin/order/$orderId');
      await fetchOrders();
      Get.snackbar('Success', 'Order deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete order: $e');
    }
  }

  // Get user's previous orders
  Future<List<Order>> getUserPreviousOrders(String userId, String excludeOrderId) async {
    try {
      final response = await _apiService.get('/admin/order/$excludeOrderId/previous');
      if (response['status'] == 'success') {
        final List<dynamic> data = response['previousOrders'];
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user previous orders: $e');
      return [];
    }
  }

  // Cancel order by user
  Future<void> userCancelOrder(String orderId, String userId) async {
    try {
      await _apiService.delete('/user/order/$orderId/cancel/$userId');
      await fetchOrders();
      Get.snackbar('Success', 'Order cancelled successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order: $e');
    }
  }

  List<Order> get filteredOrders {
    if (selectedStatus.value == 'all') return orders;
    final statusMap = {'pending': 1, 'completed': 2, 'cancelled': 3, 'in-progress': 4};
    return orders.where((order) => order.status == statusMap[selectedStatus.value]).toList();
  }

  // Helper method to get completed orders count
  int get completedOrdersCount {
    return orders.where((order) => order.status == 2).length;
  }

  // Helper method to get average order value
  double get averageOrderValue {
    final completedOrders = orders.where((order) => order.status == 2);
    if (completedOrders.isEmpty) return 0;
    
    double total = 0;
    for (var order in completedOrders) {
      total += double.tryParse(order.price) ?? 0;
    }
    return total / completedOrders.length;
  }

  // Get order by ID
  Order? getOrderById(String id) {
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get revenue by status
  Map<String, double> getRevenueByStatus() {
    final revenueByStatus = <String, double>{};
    
    for (var order in orders) {
      final status = order.statusText;
      final price = double.tryParse(order.price) ?? 0;
      revenueByStatus[status] = (revenueByStatus[status] ?? 0) + price;
    }
    
    return revenueByStatus;
  }
}