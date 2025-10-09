import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/flow/policy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Right-to-left for Urdu
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 🌾 Background Image
            Image.asset(
              'assets/images/userInformation.jpeg',
              fit: BoxFit.cover,
            ),

            // Dark overlay for readability
            Container(
              color: Colors.black.withAlpha(50),
            ),

            // Foreground content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "صارف کی معلومات",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Appcolor.green,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withAlpha(50),
                              offset: const Offset(1, 2),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔹 Name Field
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'نام درج کریں',
                          labelStyle:
                              const TextStyle(color: Colors.white70, fontSize: 16),
                          prefixIcon: const Icon(Icons.person, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withAlpha(50),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'براہ کرم اپنا نام درج کریں';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Phone Field
                    // 🔹 Phone Field (with flag + code on left)
Row(
  children: [
    // 🇵🇰 Country Code Container
    Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white70),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: const Row(
        children: [
          Text(
            "🇵🇰",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 6),
          Text(
            "92+",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 10),

    // 🔸 Number Input Field
    Expanded(
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'اپنا نمبر درج کریں',
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 16),
          hintText: '3366215818',
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withAlpha(50),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'براہ کرم اپنا فون نمبر درج کریں';
          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return 'صحیح فون نمبر درج کریں (مثال: 3366215818)';
          }
          return null;
        },
      ),
    ),
  ],
),

                      const SizedBox(height: 30),

                      // 🔹 Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolor.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 6,
                            shadowColor: Colors.black54,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('فارم کامیابی سے جمع کر دیا گیا'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'جمع کریں',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Privacy Policy
                      GestureDetector(
                        onTap: () {
                            Get.to(() => PrivacyPage());
                          // Handle privacy policy tap
                        },
                        child: Text(
                          "فارم جمع کر کے آپ ہماری رازداری کی پالیسی سے اتفاق کرتے ہیں۔",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'otp_verify_page.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _nameCtl = TextEditingController();
//   final _phoneCtl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _acceptedTerms = false;
//   bool _isLoading = false;

//   final RegExp _pakPhone = RegExp(r'^92[0-9]{10}$');

//   Future<void> _sendOtp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_acceptedTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('براہِ کرم شرائط و ضوابط قبول کریں۔')));
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: '+${_phoneCtl.text.trim()}',
//         verificationCompleted: (cred) {},
//         verificationFailed: (e) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text(e.message ?? 'خطا')));
//         },
//         codeSent: (verificationId, resendToken) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => OtpVerifyPage(
//                 name: _nameCtl.text.trim(),
//                 phone: _phoneCtl.text.trim(),
//                 verificationId: verificationId,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (verificationId) {},
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('خطا: $e')));
//     }
//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('اندراج', style: GoogleFonts.vazirmatn())),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(children: [
//             TextFormField(
//               controller: _nameCtl,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(labelText: 'پورا نام'),
//               validator: (v) =>
//                   (v == null || v.trim().length < 3) ? 'صحیح نام درج کریں' : null,
//               style: GoogleFonts.vazirmatn(),
//             ),
//             SizedBox(height: 12),
//             TextFormField(
//               controller: _phoneCtl,
//               keyboardType: TextInputType.number,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(labelText: 'فون نمبر (92 سے شروع)'),
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'فون نمبر درکار ہے';
//                 if (!_pakPhone.hasMatch(v.trim()))
//                   return 'فون نمبر 92 سے شروع اور 12 ہندسوں پر مشتمل ہونا چاہیے';
//                 return null;
//               },
//               style: GoogleFonts.vazirmatn(),
//             ),
//             Row(
//               children: [
//                 Checkbox(
//                     value: _acceptedTerms,
//                     onChanged: (val) => setState(() => _acceptedTerms = val!)),
//                 Expanded(
//                     child: GestureDetector(
//                   onTap: () {
//                     // show terms screen
//                   },
//                   child: Text(
//                     'میں شرائط و ضوابط اور پرائیویسی پالیسی پڑھ کر قبول کرتا/کرتی ہوں',
//                     style: GoogleFonts.vazirmatn(
//                         decoration: TextDecoration.underline),
//                     textAlign: TextAlign.right,
//                   ),
//                 ))
//               ],
//             ),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _sendOtp,
//               child: _isLoading
//                   ? CircularProgressIndicator()
//                   : Text('OTP بھیجیں', style: GoogleFonts.vazirmatn()),
//             )
//           ]),
//         ),
//       ),
//     );
//   }
// }
