import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_vision/src/presentation/screens/ChatBot_Module/chatbot.dart';

class DetectionResultScreen extends StatelessWidget {
  final File imageFile;
  final String diseaseName;
  final String description;
  final String recommendation;
  final String confidence;
  final String status;
  final String colorCode;

  const DetectionResultScreen({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.description,
    required this.recommendation,
    this.confidence = '0%',
    this.status = 'success',
    this.colorCode = '#008000',
  });

  Color _getStatusColor() {
    switch (status) {
      case 'success':
        return const Color(0xFF02A96C);
      case 'unsure':
        return const Color(0xFFFFA726);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF02A96C);
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'success':
        return "تشخیص مکمل ہو گئی";
      case 'unsure':
        return "تصویر واضح نہیں";
      case 'rejected':
        return "انتباہ";
      default:
        return "تشخیص مکمل ہو گئی";
    }
  }

  String _getStatusSubtitle() {
    switch (status) {
      case 'success':
        return "آپ کے پودے کی مکمل تشخیص کی گئی ہے";
      case 'unsure':
        return "تصویر کی وضاحت درکار ہے";
      case 'rejected':
        return "براہ کرم مناسب تصویر اپلوڈ کریں";
      default:
        return "آپ کے پودے کی مکمل تشخیص کی گئی ہے";
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'success':
        return Icons.verified;
      case 'unsure':
        return Icons.image_rounded;
      case 'rejected':
        return Icons.warning_amber;
      default:
        return Icons.verified;
    }
  }

  void _showCustomSnackbar(String title, String message, Color color, IconData icon) {
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

  // Disease to Urdu prompt mapping
  String _getDiseasePrompt(String diseaseName) {
    final promptMap = {
      'سست تیلہ (Aphid)': 'ایفڈ (Aphids) کے بارے میں مزید معلومات درکار ہیں',
      'کالی کنگی (Stem Rust)': 'کالی زنگ (Black Rust) کی بیماری کے بارے میں رہنمائی چاہیے',
      'گندم کا بلاسٹ (Wheat Blast)': 'بلاسٹ بیماری کی علامات اور علاج بتائیں',
      'بھوری کنگی (Leaf Rust)': 'بھوری زنگ (Brown Rust) کے تدارک کے طریقے',
      'سٹے کا جھلسنا (Fusarium)': 'فیوزیریم ہیڈ بلائٹ کی تشخیص اور کنٹرول',
      'صحت مند (Healthy)': 'صحت مند فصل کی دیکھ بھال کے بارے میں رہنمائی',
      'پتوں کا جھلسنا (Leaf Blight)': 'پتوں کے بلائٹ کی وجوہات اور علاج',
      'سفوفی پھپھوندی (Powdery Mildew)': 'پھپھوندی یا ملڈیو کے مسائل اور حل',
      'جوئیں (Wheat Mite)': 'مائٹ کے حملے اور ان کا تدارک',
      'سپٹوریا (Leaf Blotch)': 'سیپٹوریا بیماری کی تفصیلات',
      'کانگیاری (Loose Smut)': 'کھنڈ بیماری یا سماٹ کے بارے میں معلومات',
      'تنے کی مکھی (Stem Fly)': 'تنا مکھی کے حملے اور روک تھام',
      'ٹین سپاٹ (Tan Spot)': 'ٹین سپاٹ کی بیماری کی علامات',
      'زرد کنگی (Yellow Rust)': 'پیلی زنگ (Yellow Rust) کا علاج اور بچاؤ',
    };
    
    return promptMap[diseaseName] ?? '$diseaseName کے بارے میں مزید معلومات درکار ہیں';
  }

  void _navigateToChatbot() {
    try {
      Get.to(
        () => Chatbot(
          initialMessage: _getDiseasePrompt(diseaseName),
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      _showCustomSnackbar(
        'نیویگیشن میں مسئلہ',
        'چیٹ بوٹ تک رسائی میں مسئلہ ہوا۔ براہ کرم دوبارہ کوشش کریں۔',
        Colors.red,
        Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
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
            "تشخیص کا نتیجہ",
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
                  color: statusColor.withAlpha(26),
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
                  // 🌾 Results Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withAlpha(75),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getStatusTitle(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getStatusSubtitle(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (status == 'success') ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "اعتماد: $confidence",
                              style: GoogleFonts.vazirmatn(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
                    child: Column(
                      children: [
                        // Image Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(10),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.photo_library,
                                      color: statusColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "اپ لوڈ کردہ تصویر",
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: statusColor,
                                            size: 50,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "تصویر لوڈ نہیں ہو سکی",
                                            style: GoogleFonts.vazirmatn(
                                              color: statusColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () => Get.back(),
                                            child: Text(
                                              "واپس جائیں",
                                              style: GoogleFonts.vazirmatn(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Results Section - Only show for success case
                        if (status == 'success') ...[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Disease Name
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.medical_services,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "بیماری کی تشخیص",
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: statusColor.withAlpha(50),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        diseaseName,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "اعتماد: $confidence",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 14,
                                          color: statusColor.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Description
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.description,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "بیماری کی تفصیل",
                                      style: GoogleFonts.vazirmatn(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF8E3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: statusColor.withAlpha(30),
                                    ),
                                  ),
                                  child: Text(
                                    description,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Recommendation
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA726).withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb,
                                        color: Color(0xFFFFA726),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "تجاویز اور حل",
                                      style: GoogleFonts.vazirmatn(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFFA726),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFA726).withAlpha(10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFA726).withAlpha(30),
                                    ),
                                  ),
                                  child: Text(
                                    recommendation,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Warning/Error Message for non-success cases
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  _getStatusIcon(),
                                  size: 60,
                                  color: statusColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getStatusTitle(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (status == 'unsure') 
                                  Text(
                                    "اعتماد: $confidence",
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 14,
                                      color: statusColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🟢 Ask AI Button - Only show for success case
                  if (status == 'success') ...[
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withAlpha(75),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _navigateToChatbot,
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                "AI سہولت کار سے مزید معلومات حاصل کریں",
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ℹ️ Info Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "AI سہولت کار آپ کو اس بیماری کے بارے میں مزید تفصیلی معلومات فراہم کرے گا",
                              style: GoogleFonts.vazirmatn(
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Try Again Button for non-success cases
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withAlpha(75),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                "دوبارہ کوشش کریں",
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}