import 'dart:ffi';

import 'package:agri_vision/src/presentation/screens/flow/user_Information.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigation(index) {
    currentPageIndex.value = index;
    //   pageController.animateToPage(index,
    //       duration: const Duration(milliseconds: 500), curve: Curves.linear);
    // }
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentPageIndex.value >= 2) {
      // Remove all previous routes to prevent going back
      Get.offAll(() => UserInformation());
    } else {
      var page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
   Get.offAll(() => UserInformation());
  }
}