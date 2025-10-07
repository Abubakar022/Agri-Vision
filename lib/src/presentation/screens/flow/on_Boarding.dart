import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/controllers/onBoarding_Controller.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
            
            ],
          ),
          Positioned(
            top: 20,
            right: 8,
            child: TextButton(
                onPressed: () {
                  controller.skipPage();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                )),
          ),
          Positioned(
              bottom: 40,
              left: 15,
              child: SmoothPageIndicator(
                  controller: controller.pageController,
                  onDotClicked: controller.dotNavigation,
                  count: 3,
                  effect: ExpandingDotsEffect(
                      activeDotColor: Appcolor.blue, dotHeight: 10))),
          Positioned(
              bottom: 25,
              right: 8,
              child: ElevatedButton(
                  onPressed: () {
                    controller.nextPage();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(17),
                  //  backgroundColor: Appcolor.blue,
                    iconColor: Colors.white,
                  ), 
                  child:null
                 //child: Icon(Iconsax.arrow_right_3)
                 
                 ))
        ],
      ),
    );
  }
}
