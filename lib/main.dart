import 'package:admin_app/app/controllers/order_controller.dart';
import 'package:admin_app/app/services/api_service.dart';
import 'package:admin_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize all dependencies here
    Get.put(ApiService(), permanent: true);
    Get.put(OrderController(), permanent: true);
    
    return GetMaterialApp(
      title: 'AgriVision Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Remove dotenv for now to avoid issues
    );
  }
}