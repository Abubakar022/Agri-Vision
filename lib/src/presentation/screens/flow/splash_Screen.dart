import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/space.dart';
import 'package:agri_vision/src/presentation/widgets/nimated_gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/wheatBg.jpeg',
            fit: BoxFit.cover,
          ),
          // Centered drone image, responsive top position
          Positioned(
            top: height * 0.25, // 18% from top
            left: (width - width * 1.1) / 2,
            child: Image.asset(
              'assets/images/drone.png',
              width: width * 1.2,
            ),
          ),
          // Centered text, responsive top position and full width
          Positioned(
            top: height * 0.45, // 48% from top
            left: 0,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Agri",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.1,
                        ),
                      ),
                      Aspace.spaceHorizontal(8),
                       AnimatedGradientText(
      text: 'Vision',
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.bold,
        fontSize: width * 0.1,
      ),
      colors: [
        Appcolor.visionG,
        Appcolor.SplashScreenColor,
      ],
      glowRadius: 10,
    ),
                    ],
                  ),
                  Text(
                    "Smart Solution for Modern Farming",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
