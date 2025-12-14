import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;
  
  // ✅ ADD THIS - Callback for when onboarding finishes
  VoidCallback? onFinishCallback;

  // ✅ ADD THIS - Method to set the callback
  void setOnFinishCallback(VoidCallback callback) {
    onFinishCallback = callback;
  }

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigation(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentPageIndex.value >= 2) {
      // ✅ USE THE CALLBACK instead of direct navigation
      if (onFinishCallback != null) {
        onFinishCallback!();
      } else {
        // Fallback if callback not set
        Get.offAll(() => const UserInformation());
      }
    } else {
      var page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    // ✅ USE THE CALLBACK instead of direct navigation
    if (onFinishCallback != null) {
      onFinishCallback!();
    } else {
      // Fallback if callback not set
      Get.offAll(() => const UserInformation());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}