// lib/src/presentation/screens/Support_Module/support_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchEmail() async {
    try {
      final String email = 'agrivision.team@gmail.com';
      final String subject = Uri.encodeComponent('زرعی ویژن سپورٹ');
      final String body = Uri.encodeComponent('براہ کرم اپنا مسئلہ درج کریں...');
      
      final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');
      
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      
    } catch (e) {
      print('Email launch error: $e');
      _showCustomSnackbar(
        'ای میل ایپ نہیں کھل سکی',
        'براہ کرم اپنے فون میں ای میل ایپ انسٹال کریں',
        Icons.email,
        Colors.orange,
      );
    }
  }

  void _showCustomSnackbar(String title, String message, IconData icon, Color color) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        icon: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8E3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF02A96C),
          ),
          onPressed: () => Get.back(),
        ),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "مدد اور سپورٹ",
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF02A96C),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF02A96C).withAlpha(26),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withAlpha(26),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contact Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF02A96C), Color(0xFF00C853)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "ہم سے رابطہ کریں",
                          style: GoogleFonts.vazirmatn(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ہم آپ کی مدد کے لیے یہاں موجود ہیں",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Single Email Button
                        _GradientButton(
                          icon: Icons.email,
                          text: "ای میل کے ذریعے رابطہ کریں",
                          onTap: _launchEmail,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF02A96C), Color(0xFF00C853)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FAQ Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF02A96C).withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                color: Color(0xFF02A96C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "اکثر پوچھے گئے سوالات",
                              style: GoogleFonts.vazirmatn(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF02A96C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _FAQItem(
                          question: "پلانٹ اسکین کیسے کام کرتی ہے؟",
                          answer:
                              "اپنے پودے کی تصویر اپ لوڈ کریں اور ہماری AI بیماری کی تشخیص کرے گی۔",
                        ),
                        _FAQItem(
                          question: "کیا میں اپنی گیلری سے تصویر منتخب کر سکتا ہوں؟",
                          answer:
                              "جی ہاں، آپ کیمرے یا گیلری دونوں سے تصویر منتخب کر سکتے ہیں۔",
                        ),
                        _FAQItem(
                          question: "تشخیص کی درستگی کتنی ہے؟",
                          answer:
                              "ہماری AI 85-90% درستگی کے ساتھ بیماریوں کی تشخیص کرتی ہے۔",
                        ),
                        _FAQItem(
                          question: "ڈرون سپرے سروس کیسے حاصل کریں؟",
                          answer:
                              "ایپ کے ذریعے درخواست جمع کروائیں اور ہماری ٹیم آپ سے رابطہ کرے گی۔",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Gradient Button Widget
class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Gradient gradient;

  const _GradientButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02A96C).withAlpha(75),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

// FAQ Item Widget
class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8E3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02A96C).withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF02A96C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02A96C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              answer,
              style: GoogleFonts.vazirmatn(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}