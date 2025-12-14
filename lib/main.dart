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

  // ✅ Initialize SharedPreferences once
  final prefs = await SharedPreferences.getInstance();

  // ✅ Restore user session if exists
  UserSession.uid = prefs.getString('userId');

  // ✅ Initialize controllers
  Get.put(HistoryController());

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AgriVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // ✅ Pass prefs to SplashController
      home: SplashController(prefs: prefs),
    );
  }
}
