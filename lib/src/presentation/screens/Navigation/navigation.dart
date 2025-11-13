import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/ChatBot_Module/chatbot.dart';
// میں نے فرض کیا ہے کہ آپ کے پاس یہ اسکرین ہے، اگر نہیں تو DroneBookingScreen استعمال کریں
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneDashboardScreen.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_vision/src/presentation/screens/Detection_Module/CropScanScreen.dart';
// اگر DroneServiceScreen موجود نہیں ہے تو اس لائن کو ان کمنٹ کریں
// import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingScreen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  // یہ یقینی بنائیں کہ یہ لسٹ آپ کے GNav ٹیبز کی ترتیب سے ملتی ہے
  final List<Widget> _pages = const [
    CropScanScreen(),       // 0. تشخیص (Diagnosis)
    Chatbot(),              // 1. مشاورت (Consultation)
    DroneServiceScreen(),   // 2. ڈرون سروس (Drone Service)
  ];

  // آپ یہ رنگ Appcolor.primaryGreen سے بھی لے سکتے ہیں
  final Color primaryGreen = const Color(0xFF02A96C); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Appcolor.cream,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(21),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GNav(
            backgroundColor: Appcolor.cream,
            color: Colors.black54,       // غیر منتخب آئیکن کا رنگ
            activeColor: Colors.white,   // منتخب آئیکن اور ٹیکسٹ کا رنگ
            tabBackgroundColor: primaryGreen, // منتخب ٹیب کا بیک گراؤنڈ
            gap: 8, // آئیکن اور ٹیکسٹ کے درمیان فاصلہ
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            selectedIndex: _selectedIndex,
            onTabChange: (index) => setState(() => _selectedIndex = index),
            
            // ================== ⭐ تبدیلیاں یہاں کی گئی ہیں ==================
            tabs: const [
              GButton(
                icon: Icons.camera_alt_rounded, // <-- آئیکن تبدیل کیا گیا
                text: "تشخیص", // <-- نام تبدیل کیا گیا (Diagnosis)
              ),
              GButton(
                icon: Icons.chat_bubble_rounded, // <-- یہ بہترین آئیکن ہے
                text: "مشاورت", // <-- نام تبدیل کیا گیا (Consultation)
              ),
              GButton(
                icon: Icons.flight_takeoff_rounded, // <-- یہ آئیکن بھی ٹھیک ہے
                text: "ڈرون سروس", // <-- یہ نام پہلے ہی بہترین تھا
              ),
            ],
            // ==========================================================
          ),
        ),
      ),
    );
  }
}