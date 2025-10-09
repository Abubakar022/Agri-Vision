import 'package:agri_vision/src/presentation/space.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class page2 extends StatelessWidget {
  const page2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final height = size.height; // Not strictly needed here, but kept for context
    final width = size.width;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      // The main content is wrapped in a Column to stack elements vertically
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom vertical space widget
          Aspace.spaceVertical(size.height * 0.1),

          // Main Header Text (Smart Farming)
          Text(
            "آپ کی فصل کا ڈاکٹر، اب آپ کے فون میں",
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: width * 0.08,
            ),
          ),

          Aspace.spaceVertical(10),

          // Sub-header Text
          Text(
            "پریشانی ختم، رہنمائی حاضر! اپنی گندم کی بیماریوں کی شناخت اور آسان حل ہر وقت، ہر جگہ حاصل کریں۔",
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: width * 0.04,
            ),
          ),

          Aspace.spaceVertical(20),

          // Container for the Chat Bubbles Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Message Bubble (Aligned Right)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10, left: 40),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40), // Subtle shadow
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      "میری گندم کے پتوں پر دھبے بن گئے ہیں، کیا یہ بیماری ہے؟",
                      style: GoogleFonts.vazirmatn(
                          fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),

                // 2. Bot Reply Bubble (Aligned Left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10, right: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25), // Subtle shadow
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      "یہ ممکنہ طور پر زنگ کی بیماری ہے، بہتر ہوگا کہ پوری فصل کا مشاہدہ کریں اور فنگسائڈ اسپرے کریں تاکہ بیماری کے پھیلاؤ کو روکا جا سکے۔",
                      style: GoogleFonts.vazirmatn(
                          fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ), // Closing parenthesis for the chat Container

        Aspace.spaceVertical(20),
   Wrap(
  alignment: WrapAlignment.spaceEvenly,
  spacing: 10,
  runSpacing: 10,
  children: [
    Text(
      "\u200F• علاج کی سفارشات",
      textAlign: TextAlign.right,
      style: GoogleFonts.vazirmatn(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
    Text(
      "\u200F• تفصیلی وضاحتیں",
      textAlign: TextAlign.right,
      style: GoogleFonts.vazirmatn(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
    Text(
      "\u200F• 24/7 مدد",
      textAlign: TextAlign.right,
      style: GoogleFonts.vazirmatn(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
  ],
)


        ],



      ),
    );
  }
}