import 'package:agri_vision/src/presentation/space.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class page3 extends StatelessWidget {
  const page3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Aspace.spaceVertical(height*0.1),
           Text(
                           "سمارٹ فارمنگ، ڈرون اسپرے کے ساتھ",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.vazirmatn(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: width * 0.08,
                              
                            ),
                          ),
                          Aspace.spaceVertical(10),
                           Text(
                           "اب جدید انداز میں اسپرے کریں، ڈرون ٹیکنالوجی کے ساتھ وقت، لاگت اور محنت، سب میں بچت پائیں۔",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.vazirmatn(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: width * 0.04,
                              
                            ),
                          ),
                          Aspace.spaceVertical(20),
                           ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset("assets/images/onboard3.png",height: height*0.4,width: width*0.9, alignment: Alignment.center,fit: BoxFit.cover,))
           
                        
      
        ],
      ),
      ),
    );
  }
}