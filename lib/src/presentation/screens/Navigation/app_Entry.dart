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
  final SharedPreferences prefs;
  const SplashController({super.key, required this.prefs});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 1)); // splash visible

    final hasSeenOnboarding =
        widget.prefs.getBool('hasSeenOnboarding') ?? false;
    final isLoggedIn = widget.prefs.getBool('isLoggedIn') ?? false;
    final isOtpVerified = widget.prefs.getBool('otpVerified') ?? false;

    if (!mounted) return;

    if (isLoggedIn && isOtpVerified) {
      Get.offAll(() => const HomeNavigation());
    } else if (!hasSeenOnboarding) {
      Get.offAll(() => OnboardingScreen(
            onFinish: () async {
              await widget.prefs.setBool('hasSeenOnboarding', true);
              if (!mounted) return;
              Get.offAll(() => const UserInformation());
            },
          ));
    } else {
      Get.offAll(() => const UserInformation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
