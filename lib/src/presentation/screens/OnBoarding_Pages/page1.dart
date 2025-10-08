import 'package:agri_vision/src/presentation/space.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class page1 extends StatelessWidget {
  const page1({super.key});

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
                            "گندم کی بیماریوں کی فوری تشخیص کریں",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.vazirmatn(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: width * 0.08,
                              
                            ),
                          ),
                          Aspace.spaceVertical(10),
                           Text(
                           "تصویر لیں، چند سیکنڈوں میں اپنی فصل کی بیماری کی درست شناخت حاصل کریں اور بروقت علاج کر کے نقصان سے بچیں۔",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.vazirmatn(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: width * 0.04,
                              
                            ),
                          ),
                           Image.asset("assets/images/onboard1.png",height: height*0.5,width: width*0.7, alignment: Alignment.center,fit: BoxFit.contain,)
           
                        
      
        ],
      ),
      ),
    );
  }
}