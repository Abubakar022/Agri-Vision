import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/controllers/onBoarding_Controller.dart';
import 'package:agri_vision/src/presentation/screens/OnBoarding_Pages/page1.dart';
import 'package:agri_vision/src/presentation/screens/OnBoarding_Pages/page2.dart';
import 'package:agri_vision/src/presentation/screens/OnBoarding_Pages/page3.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    // Set the finish callback
    controller.setOnFinishCallback(onFinish);

    var size = MediaQuery.of(context).size;
    var width = size.width;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              page1(),
              page2(),
              page3(),
            ],
          ),

          // Skip Button
          Positioned(
            top: 20,
            right: 8,
            child: TextButton(
              onPressed: () => controller.skipPage(),
              child: Text(
                'چھوڑیں',
                style: GoogleFonts.vazirmatn(
                  color: Appcolor.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),

          // Page Indicator
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => SmoothPageIndicator(
                    controller: controller.pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Appcolor.green,
                      dotHeight: 10,
                    ),
                    onDotClicked: controller.dotNavigation,
                  )),
            ),
          ),

          // Next Button
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() {
                final isLastPage = controller.currentPageIndex.value == 2;

                return ElevatedButton.icon(
                  onPressed: () => controller.nextPage(),
                  icon: const Icon(Icons.arrow_left, color: Colors.white),
                  label: Text(
                    isLastPage ? 'ختم کریں' : 'آگے بڑھیں',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: width * 0.05,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolor.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Appcolor.green.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
