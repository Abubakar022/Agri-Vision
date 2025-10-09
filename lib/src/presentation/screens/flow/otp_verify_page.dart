import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class OtpVerifyPage extends StatefulWidget {
  final String name;
  final String phone;
  final String verificationId;

  OtpVerifyPage({required this.name, required this.phone, required this.verificationId});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpCtl = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: _otpCtl.text.trim());

      await FirebaseAuth.instance.signInWithCredential(cred);

      // Save verified user to backend (MongoDB)
      final url = Uri.parse('http://localhost:3000/api/save-user'); // local testing
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': widget.name, 'phone': widget.phone}));

      final data = jsonDecode(resp.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'] ?? 'محفوظ ہو گیا')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('OTP غلط یا expired')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP تصدیق', style: GoogleFonts.vazirmatn())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _otpCtl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'OTP درج کریں'),
              style: GoogleFonts.vazirmatn(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('تصدیق کریں', style: GoogleFonts.vazirmatn()),
            ),
          ],
        ),
      ),
    );
  }
}
