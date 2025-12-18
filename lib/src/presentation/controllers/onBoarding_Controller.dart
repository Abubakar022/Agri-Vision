import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigation(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() async {
    if (currentPageIndex.value >= 2) {
      // Save that user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      
      // Navigate to UserInformation screen
      Get.offAll(() => const UserInformation());
    } else {
      var page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() async {
    // Save that user has seen onboarding (even if skipped)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    // Navigate to UserInformation screen
    Get.offAll(() => const UserInformation());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}