import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DroneDashboardScreen extends StatelessWidget {
  const DroneDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔹 Drone Animation
            Expanded(
              flex: 4,
              child: Center(
                child: Lottie.asset(
                  "assets/animations/drone.json", // Add your drone Lottie file here
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 🔹 Urdu Title & Description
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ڈرون اسپرے سروس",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "NotoNastaliqUrdu",
                      color: Colors.teal.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "اپنی فصل کے لیے صرف ایک کلک پر ڈرون اسپرے سروس بُک کریں۔",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "NotoNastaliqUrdu",
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 🔹 Urdu Booking Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to booking screen
                    Navigator.pushNamed(context, "/droneBooking");
                  },
                  child: const Text(
                    "ابھی بُک کریں",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "NotoNastaliqUrdu",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
