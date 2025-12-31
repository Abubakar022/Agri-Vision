import 'package:admin_app/modules/dashboard/dashboard_view.dart';
import 'package:admin_app/modules/order_detail/order_detail_view.dart';
import 'package:admin_app/modules/orders/orders_view.dart';
import 'package:admin_app/modules/statistics/statistics_view.dart';
import 'package:get/get.dart';


class AppPages {
  static const INITIAL = '/dashboard';

  static final routes = [
    GetPage(
      name: '/dashboard',
      page: () => DashboardView(),
    ),
    GetPage(
      name: '/orders',
      page: () => OrdersView(),
    ),
    GetPage(
      name: '/order/:id',
      page: () => OrderDetailView(),
    ),
    GetPage(
      name: '/statistics',
      page: () => StatisticsView(),
    ),
  ];
}