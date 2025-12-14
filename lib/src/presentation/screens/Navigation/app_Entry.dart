import 'dart:async';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:agri_vision/src/presentation/screens/flow/on_Boarding.dart';
import 'package:agri_vision/src/presentation/screens/flow/splash_Screen.dart';
import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    
    // Always check onboarding status first
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    // Check login status
    final isLoggedIn = await UserSession.isLoggedIn();
    final isOtpVerified = prefs.getBool('otpVerified') ?? false;

    print('DEBUG: hasSeenOnboarding = $hasSeenOnboarding');
    print('DEBUG: isLoggedIn = $isLoggedIn');
    print('DEBUG: isOtpVerified = $isOtpVerified');

    if (isLoggedIn && isOtpVerified) {
      // ✅ User is properly logged in and verified
      print('DEBUG: Redirecting to HomeNavigation');
      if (!mounted) return;
      Get.offAll(() => const HomeNavigation());
      return;
    }

    // 🔹 User not logged in or not verified
    if (!hasSeenOnboarding) {
      // 🚀 First time → Show onboarding
      print('DEBUG: Redirecting to OnboardingScreen');
      Get.offAll(() => OnboardingScreen(
        onFinish: () async {
          // Save the flag before navigating
          await prefs.setBool('hasSeenOnboarding', true);
          Get.offAll(() => const UserInformation());
        },
      ));
    } else {
      // ✅ Onboarding already seen → Go to login
      print('DEBUG: Redirecting to UserInformation');
      Get.offAll(() => const UserInformation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}