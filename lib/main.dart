import 'dart:io';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/controllers/history_controller.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/app_Entry.dart';
import 'package:agri_vision/src/presentation/screens/flow/splash_Screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Restore user session if exists
  String? savedUid = prefs.getString('userId');
  if (savedUid != null) {
    UserSession.uid = savedUid; // ✅ globally save
  }
  
  // Initialize HistoryController
  Get.put(HistoryController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AgriVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashController(),
      // Remove unnecessary imports at the top to clean up
    );
  }
}