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
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // 🔹 Check Firebase current user (already logged in?)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // ✅ User already logged in
      UserSession.uid = currentUser.uid;
      await prefs.setString('userId', currentUser.uid);
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeNavigation()),
      );
      return;
    }

    // 🔹 User not logged in
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    if (hasSeenOnboarding) {
      // ✅ Onboarding done → Go to login (UserInformation)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserInformation()),
      );
    } else {
      // 🚀 First time → Show onboarding only once
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onFinish: () async {
              await prefs.setBool('hasSeenOnboarding', true);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const UserInformation()),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
