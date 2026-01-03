import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderFinalPage extends StatelessWidget {
  const OrderFinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        _showSuccessSnackbar();
        Get.offAll(() => const HomeNavigation());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF02A96C),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'آرڈر کامیابی سے مکمل ہوگیا!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'ہماری ٹیم جلد ہی آپ سے رابطہ کرے گی۔',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'آرڈر کی تفصیلات "آرڈر ہسٹری" میں دیکھی جا سکتی ہیں۔',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF02A96C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    onPressed: () {
                      _showSuccessSnackbar();
                      Get.offAll(() => const HomeNavigation());
                    },
                    child: const Text(
                      'واپس جائیں',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 SUCCESS SNACKBAR (RTL FIXED)
  void _showSuccessSnackbar() {
    Get.snackbar(
      '✅ کامیابی!',
      'آرڈر کامیابی سے جمع کرایا گیا',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      backgroundColor: const Color(0xFF02A96C),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 3),
        ),
      ],
      overlayBlur: 0.5,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 500),
      titleText: const Text(
        '✅ کامیابی!',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: const Text(
        'آرڈر کامیابی سے جمع کرایا گیا',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  // 🔹 ORDER PLACED SNACKBAR (RTL FIXED)
  void _showOrderPlacedSnackbar() {
    Get.snackbar(
      '🚀 آرڈر پلیسڈ',
      'نیا آرڈر کامیابی سے شامل ہوگیا',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
      shouldIconPulse: true,
      snackStyle: SnackStyle.FLOATING,
      titleText: const Text(
        '🚀 آرڈر پلیسڈ',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: const Text(
        'نیا آرڈر کامیابی سے شامل ہوگیا',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white24,
      progressIndicatorValueColor:
          const AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  // 🔹 ERROR SNACKBAR (RTL FIXED)
  void _showErrorSnackbar() {
    Get.snackbar(
      '❌ خرابی',
      'آرڈر جمع کرانے میں مسئلہ پیش آیا',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 30),
      shouldIconPulse: true,
      snackStyle: SnackStyle.FLOATING,
      titleText: const Text(
        '❌ خرابی',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: const Text(
        'آرڈر جمع کرانے میں مسئلہ پیش آیا',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  // 🔹 INFO SNACKBAR (RTL FIXED)
  void _showInfoSnackbar() {
    Get.snackbar(
      'ℹ️ معلومات',
      'براہ کرم کچھ دیر انتظار کریں',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white, size: 28),
      snackStyle: SnackStyle.FLOATING,
      titleText: const Text(
        'ℹ️ معلومات',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: const Text(
        'براہ کرم کچھ دیر انتظار کریں',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
