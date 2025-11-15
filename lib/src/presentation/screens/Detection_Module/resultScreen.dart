import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_vision/src/presentation/screens/ChatBot_Module/chatbot.dart';

class DetectionResultScreen extends StatelessWidget {
  final File imageFile; // Changed from String to File
  final String diseaseName;
  final String description;
  final String recommendation;

  const DetectionResultScreen({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.description,
    required this.recommendation,
  });

  // Disease to Urdu prompt mapping
  String _getDiseasePrompt(String diseaseName) {
    final promptMap = {
      'ایفڈ': 'ایفڈ (Aphids) کے بارے میں مزید معلومات درکار ہیں',
      'کالی زنگ': 'کالی زنگ (Black Rust) کی بیماری کے بارے میں رہنمائی چاہیے',
      'بلاسٹ': 'بلاسٹ بیماری کی علامات اور علاج بتائیں',
      'بھوری زنگ': 'بھوری زنگ (Brown Rust) کے تدارک کے طریقے',
      'فیوزیریم ہیڈ بلائٹ': 'فیوزیریم ہیڈ بلائٹ کی تشخیص اور کنٹرول',
      'پتوں کا بلائٹ': 'پتوں کے بلائٹ کی وجوہات اور علاج',
      'پھپھوندی (ملڈیو)': 'پھپھوندی یا ملڈیو کے مسائل اور حل',
      'مائٹ': 'مائٹ کے حملے اور ان کا تدارک',
      'سیپٹوریا': 'سیپٹوریا بیماری کی تفصیلات',
      'کھنڈ بیماری (سماٹ)': 'کھنڈ بیماری یا سماٹ کے بارے میں معلومات',
      'تنا مکھی': 'تنا مکھی کے حملے اور روک تھام',
      'ٹین اسپاٹ': 'ٹین اسپاٹ کی بیماری کی علامات',
      'پیلی زنگ': 'پیلی زنگ (Yellow Rust) کا علاج اور بچاؤ',
    };
    
    return promptMap[diseaseName] ?? '$diseaseName کے بارے میں مزید معلومات درکار ہیں';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3), // soft wheat background
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF8E3),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF02A96C),
            ),
            onPressed: () => Get.back(), // Using Get.back() instead of Navigator.pop
          ),
          title: const Text(
            "نتیجہ تشخیص",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02A96C),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // 🌾 Results Title
                  const Text(
                    "نتائج تشخیص",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02A96C),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🌾 Image + Result Card
                  Container(
                    width: double.infinity,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Updated Image display for File
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "تصویر لوڈ نہیں ہو سکی",
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: const Text("واپس جائیں"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🌾 Disease Name
                        Text(
                          diseaseName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF02A96C),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 🌾 Description
                        Text(
                          description,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 🌾 Recommendation
                        Text(
                          "تجویز: $recommendation",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🟢 Ask AI Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to chatbot with auto-prompt using GetX
                        Get.to(
                          () => Chatbot(
                            initialMessage: _getDiseasePrompt(diseaseName),
                          ),
                          transition: Transition.rightToLeft, // Smooth transition
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble, color: Colors.white),
                      label: const Text(
                       "مزید معلومات حاصل کریں",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02A96C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
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