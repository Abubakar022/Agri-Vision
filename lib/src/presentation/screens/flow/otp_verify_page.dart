import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';

class OtpVerifyPage extends StatefulWidget {
  final String name;
  final String phone;
  final String verificationId;

  const OtpVerifyPage({
    required this.name,
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
      // Verify with Firebase
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(cred);

      // Save user info to backend
      final url = Uri.parse('http://localhost:3000/api/save-user');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': widget.name, 'phone': widget.phone}),
      );

      final data = jsonDecode(resp.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'تصدیق کامیاب رہی!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP غلط ہے یا ختم ہو چکا ہے')),
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
            // 🌾 Background image
            Image.asset(
              'assets/images/otp.jpeg',
              fit: BoxFit.cover,
            ),

            // Dark overlay
            Container(color: Colors.black.withAlpha(50)),

            // Foreground content
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
                        color: Colors.white ,
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

                    // 🔸 OTP Input
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
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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

                    // 🔹 Verify Button
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

                    // 🔹 OTP resend message + clickable bold resend text
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          const TextSpan(
                            text: "اگر آپ کو OTP موصول نہیں ہوا، ",
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                // 🟢 TODO: Call resend OTP function here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('OTP دوبارہ بھیج دیا گیا')),
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
                          const TextSpan(
                            text: " پر کلک کریں۔",
                          ),
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
