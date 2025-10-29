import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/flow/otp_verify_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'policy.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/userInformation.jpeg',
                fit: BoxFit.cover),
            Container(color: Colors.black.withAlpha(50)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "فون نمبر کی تصدیق",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white70),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: const Row(
                              children: [
                                Text("🇵🇰", style: TextStyle(fontSize: 18)),
                                SizedBox(width: 6),
                                Text("92+",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                labelText: 'اپنا نمبر درج کریں',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                hintText: '3366215818',
                                hintStyle:
                                    const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: Colors.white.withAlpha(50),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'براہ کرم اپنا فون نمبر درج کریں';
                                } else if (!RegExp(r'^[0-9]{10}$')
                                    .hasMatch(value)) {
                                  return 'صحیح فون نمبر درج کریں (مثال: 3366215818)';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolor.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String phone =
                                  '+92${_phoneController.text.trim()}';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('OTP بھیجا جا رہا ہے...')),
                              );
                              try {
                                await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: phone,
                                  verificationCompleted:
                                      (PhoneAuthCredential credential) {},
                                  verificationFailed:
                                      (FirebaseAuthException e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('OTP ناکام: ${e.message}')),
                                    );
                                  },
                                  codeSent: (String verificationId,
                                      int? resendToken) {
                                    Get.to(() => OtpVerifyPage(
                                          phone: _phoneController.text.trim(),
                                          verificationId: verificationId,
                                        ));
                                  },
                                  codeAutoRetrievalTimeout:
                                      (String verificationId) {},
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('خرابی: $e')),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'OTP بھیجیں',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Get.to(() => PrivacyPage()),
                        child: const Text(
                          "OTP کے ذریعے آپ ہماری پالیسی سے اتفاق کرتے ہیں۔",
                          style: TextStyle(color: Colors.white70),
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
