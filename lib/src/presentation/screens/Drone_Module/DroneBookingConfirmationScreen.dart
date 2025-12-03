import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneDashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DroneBookingScreen.dart';

class OrderFinalPage extends StatelessWidget {
  const OrderFinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow the back gesture to work normally
      canPop: true,
      // This function is called AFTER the navigation attempt is completed
      onPopInvoked: (bool didPop) {
        // Use Get.offAll to navigate to DroneBookingScreen and clear the stack
        // The 'didPop' parameter is true if the route was popped.
        // Since we want to navigate regardless, we call Get.offAll.
        Get.offAll(() => const DroneBookingScreen());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF02a96c),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'آرڈر کامیابی سے مکمل ہوگیا!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'ہماری ٹیم جلد ہی آپ سے رابطہ کرے گی۔',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF02a96c),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to DroneBookingScreen and remove all previous routes
                      Get.offAll(() => const DroneServiceScreen());
                    },
                    child: const Text(
                      'واپس جائیں',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}