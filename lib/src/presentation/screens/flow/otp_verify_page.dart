import 'dart:convert';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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
  late TextEditingController _otpController;
  bool _isLoading = false;
  bool _resendLoading = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showErrorSnackBar('براہ کرم 6 ہندسوں کا OTP درج کریں');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);

      User? user = userCredential.user;
      if (user == null) throw Exception("User not found after OTP verification");

      final prefs = await SharedPreferences.getInstance();
      UserSession.uid = user.uid;
      await prefs.setString('userId', user.uid);
      await prefs.setBool('isLoggedIn', true);

      final url = Uri.parse('http://10.0.2.2:3000/create');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': widget.phone, 'uId': user.uid}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _showSuccessSnackBar(data['message'] ?? 'تصدیق کامیاب رہی!');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeNavigation()),
          );
        });
      } else {
        final data = jsonDecode(resp.body);
        _showErrorSnackBar(data['message'] ?? 'ڈیٹا محفوظ کرنے میں مسئلہ');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'OTP غلط ہے یا ختم ہو چکا ہے';
      if (e.code == 'invalid-verification-code') message = 'غلط OTP درج کیا گیا';
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('مسئلہ پیش آیا: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resendLoading = true);
    try {
      String phone = '+92${widget.phone}';
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (cred) {},
        verificationFailed: (e) => _showErrorSnackBar('OTP دوبارہ بھیجنے میں ناکامی'),
        codeSent: (verificationId, _) =>
            _showSuccessSnackBar('OTP دوبارہ بھیج دیا گیا'),
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showErrorSnackBar('OTP دوبارہ بھیجنے میں مسئلہ: $e');
    } finally {
      setState(() => _resendLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Appcolor.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/otp.jpeg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withAlpha(150)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "OTP کی تصدیق",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ہم نے OTP بھیجا ہے ${widget.phone} پر",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 50),

                    // --- Modern OTP Field ---
                   // --- Modern OTP Field ---
Directionality(
  textDirection: TextDirection.ltr, // force OTP input left-to-right
  child: PinCodeTextField(
    appContext: context,
    length: 6,
    controller: _otpController,
    autoFocus: true,
    enableActiveFill: true,
    keyboardType: TextInputType.number,
    textStyle: const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    pinTheme: PinTheme(
      shape: PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(10),
      fieldHeight: 50,
      fieldWidth: 45,
      activeFillColor: Colors.white.withAlpha(26),
      inactiveFillColor: Colors.white.withAlpha(26),
      selectedFillColor: Colors.white.withAlpha(38),
      activeColor: Colors.white70,
      inactiveColor: Colors.white54,
      selectedColor: Appcolor.green,
    ),
    onChanged: (_) {},
    enablePinAutofill: true,
  ),
),


                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolor.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'تصدیق کریں',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                   Center(
  child: SizedBox(
    height: 40, // adjust height
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3, // adds the elevation effect
        backgroundColor: Colors.transparent, // keep background transparent
        shadowColor: Colors.black45, // shadow color
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: _resendLoading ? null : _resendOtp,
      child: Text(
        _resendLoading ? "ارسال ہو رہا ہے..." : "OTP دوبارہ بھیجیں",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
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
