import 'dart:async';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/Detection_Module/CropScanScreen.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:agri_vision/src/presentation/screens/flow/on_Boarding.dart';
import 'package:agri_vision/src/presentation/screens/flow/splash_Screen.dart';
import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends StatefulWidget {
  const SplashController({super.key});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // 🔹 Check Firebase current user
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // ✅ User already logged in via Firebase
      await UserSession.saveLogin(currentUser.uid, currentUser.email ?? '');
      
      if (!mounted) return;
      Get.offAll(() => const HomeNavigation());
      return;
    }

    // 🔹 Check saved session
    final isLoggedIn = await UserSession.isLoggedIn();
    
    if (isLoggedIn) {
      // ✅ User logged in via saved session
      if (!mounted) return;
      Get.offAll(() => const HomeNavigation());
      return;
    }

    // 🔹 User not logged in
    await prefs.setBool('isLoggedIn', false);

    if (!hasSeenOnboarding) {
      // 🚀 First time → Show onboarding
      Get.offAll(() => OnboardingScreen(
        onFinish: () async {
          await prefs.setBool('hasSeenOnboarding', true);
          Get.offAll(() => const UserInformation());
        },
      ));
    } else {
      // ✅ Onboarding done → Go to login
      Get.offAll(() => const UserInformation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}