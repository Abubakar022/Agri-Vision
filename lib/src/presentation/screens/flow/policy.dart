import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF02a96c),
              Color(0xFF02945f),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "پرائیویسی پالیسی",
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Text(
                  """
ہماری ایپ آپ کی معلومات کی حفاظت کو انتہائی سنجیدگی سے لیتی ہے۔ 
ہم صرف وہی معلومات جمع کرتے ہیں جو ایپ کی بہتر کارکردگی اور صارف کے تجربے کے لیے ضروری ہیں۔

• ہم آپ کا ڈیٹا کسی تیسرے فریق کے ساتھ شیئر نہیں کرتے۔
• آپ کی لوکیشن صرف تب استعمال کی جاتی ہے جب آپ اس کی اجازت دیں۔
• آپ کا ذاتی ڈیٹا خفیہ طور پر محفوظ کیا جاتا ہے۔
• آپ کسی بھی وقت اپنے اکاؤنٹ یا ڈیٹا کو حذف کرنے کی درخواست دے سکتے ہیں۔
• ہماری ایپ مسلسل بہتری کے لیے صارف کی آراء کو مدنظر رکھتی ہے۔

اگر آپ کے کوئی سوالات ہیں تو آپ ہم سے رابطہ کر سکتے ہیں:
support@agrivision.ai
""",
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: 20,
                    color: Colors.white.withAlpha(220),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
