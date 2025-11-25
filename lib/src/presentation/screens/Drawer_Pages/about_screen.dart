// lib/src/presentation/screens/About_Module/about_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            "ایپ کے بارے میں",
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
                  // App Info Card
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
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF02A96C), Color(0xFF00C853)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "زرعی ویژن",
                          style: GoogleFonts.vazirmatn(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ورژن 1.0.0",
                          style: GoogleFonts.vazirmatn(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "پاکستانی کسانوں کے لیے مکمل ڈیجیٹل حل",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "یہ پروجیکٹ پاکستانی گندم کسانوں کو مصنوعی ذہانت، موبائل ٹیکنالوجی، اور پرسیشن ایگریکلچر سروسز کو ایک اردو پلیٹ فارم میں یکجا کر کے مکمل ڈیجیٹل حل فراہم کرتا ہے۔ سسٹم کسانوں کو امیج بیسڈ مشین لرننگ ماڈل کے ذریعے گندم کی بیماریوں کی تشخیص کرنے، ٹیکسٹ یا وائس کمانڈز کا استعمال کرتے ہوئے اردو چیٹ بوٹ کے ساتھ بات چیت کرنے، اور بہتر رسائی کے لیے بوٹ کے جوابات بولے ہوئے اردو میں سننے کی سہولت فراہم کرتا ہے۔ ایپ ایک پارٹنرڈ کمپنی کے ذریعے ڈرون سپرے سروس بھی پیش کرتی ہے، جو کسانوں کو براہ راست اپنے موبائل ڈیوائسز سے درست اور پیشہ ورانہ سپرےنگ کی درخواست دینے کے قابل بناتی ہے۔ ایڈمن ایپلیکیشن بیک اینڈ آپریشنز کو منظم کرکے بیک اپ فراہم کرتی ہے، صارف کی درخواستوں، ڈرون سروس آرڈرز، اور مجموعی ورک فلو کو مینج کرتی ہے۔ اپنے مکمل اردو انٹرفیس اور کسان دوست ڈیزائن کے ساتھ، یہ پروجیکٹ جدید زرعی ٹیکنالوجیز کو زیادہ قابل رسائی بنانے، فیصلہ سازی کو بہتر بنانے، اور پورے پاکستان میں گندم کی پیداوار بڑھانے میں مدد فراہم کرنے کا ارادہ رکھتا ہے۔",
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.vazirmatn(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features Card
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
                        Text(
                          "خصوصیات",
                          style: GoogleFonts.vazirmatn(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FeatureItem(
                          icon: Icons.psychology,
                          title: "AI ڈایاگنوسس",
                          description: "مصنوعی ذہانت کے ذریعے درست بیماری کی تشخیص",
                        ),
                        _FeatureItem(
                          icon: Icons.chat,
                          title: "اردو چیٹ بوٹ",
                          description: "ٹیکسٹ اور وائس کے ذریعے بات چیت",
                        ),
                        _FeatureItem(
                          icon: Icons.voice_chat,
                          title: "آواز میں جوابات",
                          description: "بولے ہوئے اردو میں جوابات",
                        ),
                        _FeatureItem(
                          icon: Icons.flight_takeoff_rounded,
                          title: "ڈرون سپرے سروس",
                          description: "پیشہ ورانہ سپرےنگ سروس",
                        ),
                        _FeatureItem(
                          icon: Icons.language,
                          title: "مکمل اردو انٹرفیس",
                          description: "کسان دوست اردو انٹرفیس",
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8E3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02A96C).withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF02A96C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02A96C),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}