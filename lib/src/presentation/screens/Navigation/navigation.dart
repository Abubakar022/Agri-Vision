import 'package:agri_vision/src/presentation/screens/ChatBot_Module/chatbot.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneDashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_vision/src/presentation/screens/Detection_Module/CropScanScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingScreen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CropScanScreen(),      // 🌾 Home (Disease Detection)
    Chatbot(),       // 💬 Chatbot
    DroneServiceScreen(),  // 🚁 Drone Spray Booking
  ];

  final Color primaryGreen = const Color(0xFF02A96C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            backgroundColor: Colors.white,
            color: Colors.black54,
            activeColor: Colors.white,
            tabBackgroundColor: primaryGreen,
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            selectedIndex: _selectedIndex,
            onTabChange: (index) => setState(() => _selectedIndex = index),
            tabs: const [
              GButton(
                icon: Icons.home_rounded,
                text: "گھر", // Urdu: Home
              ),
              GButton(
                icon: Icons.chat_bubble_rounded,
                text: "زرعی مددگار", // Urdu: Chatbot (Agricultural Helper)
              ),
              GButton(
                icon: Icons.airplanemode_active_rounded,
                text: "ڈرون سروس", // Urdu: Drone Service
              ),
            ],
          ),
        ),
      ),
    );
  }
}
