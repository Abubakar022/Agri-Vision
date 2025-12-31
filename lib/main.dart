// main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/dashboard_screen.dart';


void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Order Management Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: AppBindings(),
      home: const AuthWrapper(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      defaultTransition: Transition.fade,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.isLoggedIn.value) {
        return DashboardScreen();
      }
      return LoginScreen();
    });
  }
}