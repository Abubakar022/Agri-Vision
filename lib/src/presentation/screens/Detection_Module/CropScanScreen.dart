import 'package:flutter/material.dart';

class CropScanScreen extends StatelessWidget {
  const CropScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    String username = "ابو بکر";
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3), // soft wheat tone
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🌾 Top "خوش آمدید" Text
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "خوش آمدید، $username",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02A96C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // 🌾 Center Card with Image
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/scan.jpeg', // your wheat image
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(77),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 📷 Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "تصویر کھینچیں",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02A96C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Gallery Button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text(
                      "فوٹو منتخب کریں",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02A96C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 🟢 Detect Button
              Center(
                  child: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // makes children take full width
    children: [
      SizedBox(
        height: 50, // optional fixed height
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF02A96C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.local_hospital, // doctor/medical style icon
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                "تجزیہ کریں",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)

              )
              ,
            ],
          ),
        ),
      ),
    );
  }
}
