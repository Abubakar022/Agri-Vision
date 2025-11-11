// // ignore: file_names
// ignore: file_names
import 'dart:io';
import 'package:agri_vision/src/presentation/screens/Detection_Module/resultScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CropScanScreen extends StatefulWidget {
  const CropScanScreen({super.key});

  @override
  State<CropScanScreen> createState() => _CropScanScreenState();
}

class _CropScanScreenState extends State<CropScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String username = "ابو بکر";

  // Simulate API call
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      Get.snackbar(
        'تنبہہ',
        'براہ کرم پہلے ایک تصویر منتخب کریں',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Dummy response - replace with actual API response
    final dummyResponse = {
      'diseaseName': "پتوں کا زنگ",
      'description': "یہ بیماری عام طور پر گندم کے پتوں پر زرد دھبے پیدا کرتی ہے۔",
      'recommendation': "زرعی ماہر سے مشورہ کریں اور تجویز کردہ اسپرے استعمال کریں۔",
      'confidence': '85%',
    };

    Get.to(() => DetectionResultScreen(
      imageFile: "assets/images/scan.jpeg",
      diseaseName: dummyResponse['diseaseName']!,
      description: dummyResponse['description']!,
      recommendation: dummyResponse['recommendation']!,
      // confidence: dummyResponse['confidence']!,
    ));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'خرابی',
        'تصویر منتخب کرنے میں مسئلہ ہوا',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              "تصویر منتخب کریں",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF02A96C),
              ),
            ),
            content: const Text("کیا آپ کیمرے یا گیلری سے تصویر لینا چاہیں گے؟"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Color(0xFF02A96C)),
                    SizedBox(width: 8),
                    Text("کیمرا", style: TextStyle(color: Color(0xFF02A96C))),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library, color: Color(0xFF02A96C)),
                    SizedBox(width: 8),
                    Text("گیلری", style: TextStyle(color: Color(0xFF02A96C))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3),
        body: Stack(
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🌾 Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF02A96C), Color(0xFF00C853)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.agriculture,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "خوش آمدید، $username",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "اپنی فصل کی تصویر اپ لوڈ کریں اور تجزیہ حاصل کریں",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 🌾 Image Preview Card
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: _selectedImage != null
                              ? Border.all(
                                  color: const Color(0xFF02A96C),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF02A96C)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          child: const Icon(
                                            Icons.photo_camera,
                                            color: Color(0xFF02A96C),
                                            size: 50,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          "تصویر منتخب کریں",
                                          style: TextStyle(
                                            color: Color(0xFF02A96C),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            if (_selectedImage != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 📷 Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.camera_alt,
                            text: "کیمرا",
                            onTap: () => _pickImage(ImageSource.camera),
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.photo_library,
                            text: "گیلری",
                            onTap: () => _pickImage(ImageSource.gallery),
                            color: const Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🩺 Analyze Button
                    _isLoading
                        ? Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF02A96C),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF02A96C).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "تجزیہ ہو رہا ہے...",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _selectedImage != null
                                    ? const [Color(0xFF02A96C), Color(0xFF00C853)]
                                    : const [Colors.grey, Colors.grey],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _selectedImage != null
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF02A96C)
                                            .withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _selectedImage != null
                                  ? _analyzeImage
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics, color: Colors.white),
                                  SizedBox(width: 12),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:agri_vision/src/presentation/screens/Detection_Module/resultScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

// class CropScanScreen extends StatelessWidget {
//   const CropScanScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     //File? _selectedImage;
//     String username = "ابو بکر";
//     File? selectedImage; // dynamically filled later

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFDF8E3), // soft wheat tone
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 🌾 Greeting Text
//                 Text(
//                   "خوش آمدید، $username",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF02A96C),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // 🌾 Image Card
//                 Container(
//                   height: 220,
//                   width: 220,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withAlpha(77), // 0.3 opacity shadow
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(24),
//                         child: selectedImage != null
//                             ? Image.file(selectedImage!, fit: BoxFit.cover)
//                             : Image.asset(
//                                 'assets/images/scan.jpeg',
//                                 fit: BoxFit.cover,
//                                 height: double.infinity,
//                                 width: double.infinity,
//                               ),
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withAlpha(102), // ≈ 0.4 opacity
//                           shape: BoxShape.circle,
//                         ),
//                         padding: const EdgeInsets.all(12),
//                         child: const Icon(
//                           Icons.camera_alt,
//                           color: Colors.white,
//                           size: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // 📷 Buttons Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Get.to(() => DetectionResultScreen( imageFile: 'assets/images/scan.jpeg', diseaseName: "پتوں کا زنگ",description: "یہ بیماری عام طور پر گندم کے پتوں پر زرد دھبے پیدا کرتی ہے۔", recommendation: "زرعی ماہر سے مشورہ کریں اور تجویز کردہ اسپرے استعمال کریں۔",));
//                       },
//                       icon: const Icon(Icons.camera_alt, color: Colors.white),
//                       label: const Text(
//                         "تصویر کھینچیں",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF02A96C),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 18, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Get.to(() => DetectionResultScreen( imageFile: 'assets/images/scan.jpeg', diseaseName: "پتوں کا زنگ",description: "یہ بیماری عام طور پر گندم کے پتوں پر زرد دھبے پیدا کرتی ہے۔", recommendation: "زرعی ماہر سے مشورہ کریں اور تجویز کردہ اسپرے استعمال کریں۔",));
//                       },
//                       icon: const Icon(Icons.photo, color: Colors.white),
//                       label: const Text(
//                         "فوٹو منتخب کریں",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF02A96C),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 18, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),

//                 // 🩺 Detect Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF02A96C),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 5,
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.local_hospital, color: Colors.white),
//                         SizedBox(width: 8),
//                         Text(
//                           "تجزیہ کریں",
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
