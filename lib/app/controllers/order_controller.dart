import 'package:get/get.dart';
import 'package:admin_dashboard/app/models/order_model.dart';
import 'package:admin_dashboard/app/services/api_service.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find();
  
  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var selectedStatus = 'all'.obs;
  var orderStats = {}.obs;
  var totalRevenue = 0.0.obs;

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
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
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
      final data = {'status': status};
      if (reason != null) data['cancellationReason'] = reason;
      
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

  List<Order> get filteredOrders {
    if (selectedStatus.value == 'all') return orders;
    final statusMap = {'pending': 1, 'completed': 2, 'cancelled': 3, 'in-progress': 4};
    return orders.where((order) => order.status == statusMap[selectedStatus.value]).toList();
  }
}