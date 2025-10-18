import 'dart:convert';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';

class OtpVerifyPage extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpVerifyPage({
    required this.phone,
    required this.verificationId,
    super.key,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم OTP درج کریں')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Step 1: Verify OTP with Firebase
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(cred);

      // ✅ Step 2: Save or verify user in MongoDB backend
      final url = Uri.parse('http://10.0.2.2:3000/api/save-user'); // your backend endpoint
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'verified': true,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'تصدیق کامیاب رہی!')),
        );

        // ✅ Navigate to main HomeNavigation after success
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeNavigation()),
          );
        });
      } else {
        final data = jsonDecode(resp.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'ڈیٹا محفوظ کرنے میں مسئلہ')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'OTP غلط ہے یا ختم ہو چکا ہے';
      if (e.code == 'invalid-verification-code') {
        message = 'غلط OTP درج کیا گیا';
      } else if (e.code == 'session-expired') {
        message = 'OTP کی مدت ختم ہو گئی ہے، دوبارہ کوشش کریں';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مسئلہ پیش آیا: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/otp.jpeg', fit: BoxFit.cover),
            Container(color: Colors.black.withAlpha(50)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "OTP کی تصدیق",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 3,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        labelText: 'OTP درج کریں',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 16),
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
                    ),
                    const SizedBox(height: 30),

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
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تصدیق کریں',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        children: [
                          const TextSpan(text: "اگر آپ کو OTP موصول نہیں ہوا، "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('OTP دوبارہ بھیج دیا گیا')),
                                );
                              },
                              child: const Text(
                                "دوبارہ بھیجیں",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: " پر کلک کریں۔"),
                        ],
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
