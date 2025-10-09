import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otp_verify_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final RegExp _pakPhone = RegExp(r'^92[0-9]{10}$');

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('براہِ کرم شرائط و ضوابط قبول کریں۔')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+${_phoneCtl.text.trim()}',
        verificationCompleted: (cred) {},
        verificationFailed: (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? 'خطا')));
        },
        codeSent: (verificationId, resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerifyPage(
                name: _nameCtl.text.trim(),
                phone: _phoneCtl.text.trim(),
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطا: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اندراج', style: GoogleFonts.vazirmatn())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameCtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'پورا نام'),
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'صحیح نام درج کریں' : null,
              style: GoogleFonts.vazirmatn(),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'فون نمبر (92 سے شروع)'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'فون نمبر درکار ہے';
                if (!_pakPhone.hasMatch(v.trim()))
                  return 'فون نمبر 92 سے شروع اور 12 ہندسوں پر مشتمل ہونا چاہیے';
                return null;
              },
              style: GoogleFonts.vazirmatn(),
            ),
            Row(
              children: [
                Checkbox(
                    value: _acceptedTerms,
                    onChanged: (val) => setState(() => _acceptedTerms = val!)),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    // show terms screen
                  },
                  child: Text(
                    'میں شرائط و ضوابط اور پرائیویسی پالیسی پڑھ کر قبول کرتا/کرتی ہوں',
                    style: GoogleFonts.vazirmatn(
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.right,
                  ),
                ))
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('OTP بھیجیں', style: GoogleFonts.vazirmatn()),
            )
          ]),
        ),
      ),
    );
  }
}
