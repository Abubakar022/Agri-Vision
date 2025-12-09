import 'dart:io';

import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/controllers/history_controller.dart';
import 'package:agri_vision/src/presentation/screens/Detection_Module/CropScanScreen.dart';
import 'package:agri_vision/src/presentation/screens/Detection_Module/resultScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingConfirmationScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingHistoryScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneDashboardScreen.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/app_Entry.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:agri_vision/src/presentation/screens/flow/on_Boarding.dart';
import 'package:agri_vision/src/presentation/screens/flow/otp_verify_page.dart';
import 'package:agri_vision/src/presentation/screens/flow/splash_Screen.dart';
import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();
  String? savedUid = prefs.getString('userId');
Get.put(HistoryController());
  if (savedUid != null) {
    UserSession.uid = savedUid; // ✅ globally save
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    File? _selectedImage;
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserInformation(),
    //   home: DetectionResultScreen(
    //   imageFile: File('assets/images/scan.jpeg'),
    //   diseaseName: "پتوں کا زنگ",
    //   description: "یہ بیماری عام طور پر گندم کے پتوں پر زرد دھبے پیدا کرتی ہے۔",
    //   recommendation: "زرعی ماہر سے مشورہ کریں اور تجویز کردہ اسپرے استعمال کریں۔",
    // ),

    );
  }
}
