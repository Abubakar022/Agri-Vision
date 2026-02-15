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

  String _getDiseasePrompt(String diseaseName) {
    final promptMap = {
      'سست تیلہ (Aphid)': 'گندم میں سست تیلہ کیا ہے؟',
      'کالی کنگی (Stem Rust)': 'گندم میں کالی کنگی کیا ہے؟',
      'گندم کا بلاسٹ (Wheat Blast)': 'گندم میں بلاسٹ کیا ہے؟',
      'بھوری کنگی (Leaf Rust)': 'گندم میں بھوری کنگی کیا ہے؟',
      'سٹے کا جھلسنا (Fusarium)': 'گندم میں سٹے کا جھلسنا کیا ہے؟',
      'صحت مند (Healthy)': 'گندم کا صحت مند پودا کیا ہے؟',
      'پتوں کا جھلسنا (Leaf Blight)': 'گندم میں پتوں کا جھلسنا کیا ہے؟',
      'سفوفی پھپھوندی (Powdery Mildew)': 'گندم میں سفوفی پھپھوندی کیا ہے؟',
      'جوئیں (Wheat Mite)': 'گندم میں جوئیں کیا ہیں؟',
      'سپٹوریا (Leaf Blotch)': 'گندم میں سپٹوریا کیا ہے؟',
      'کانگیاری (Loose Smut)': 'گندم میں کانگیاری کیا ہے؟',
      'تنے کی مکھی (Stem Fly)': 'گندم میں تنے کی مکھی کیا ہے؟',
      'ٹین سپاٹ (Tan Spot)': 'گندم میں ٹین سپاٹ کیا ہے؟',
      'زرد کنگی (Yellow Rust)': 'گندم میں زرد کنگی کیا ہے؟'
    };

    return promptMap[diseaseName] ??
        '$diseaseName کے بارے میں مزید معلومات درکار ہیں';
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
      Get.snackbar(
        'نیویگیشن میں مسئلہ',
        'چیٹ بوٹ تک رسائی میں مسئلہ ہوا۔ براہ کرم دوبارہ کوشش کریں۔',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                        if (status == 'success') ...[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA726)
                                            .withAlpha(20),
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
                                    color:
                                        const Color(0xFFFFA726).withAlpha(10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          const Color(0xFFFFA726).withAlpha(30),
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
                              const Icon(Icons.chat_bubble,
                                  color: Colors.white, size: 24),
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
                              const Icon(Icons.refresh,
                                  color: Colors.white, size: 24),
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