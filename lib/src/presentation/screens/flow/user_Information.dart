import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_vision/src/presentation/screens/flow/otp_verify_page.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clearPartialLoginState();
  }

  Future<void> _clearPartialLoginState() async {
    // Clear any partial login state when user comes to this page
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('otpVerified', false);
  }

  void _showSnackbar(String message, Color color) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Future<void> _requestEmailOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      
      final url = Uri.parse('https://agri-vision-backend-1075549714370.us-central1.run.app/request-otp');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' || data['success'] == true) {
          _showSnackbar('OTP آپ کے ای میل پر بھیج دیا گیا ہے', const Color(0xFF02A96C));
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          Get.off(() => OtpVerifyPage(email: email));
        } else {
          throw data['message'] ?? 'OTP بھیجنے میں ناکامی';
        }
      } else {
        throw 'سرور سے جواب نہیں ملا';
      }

    } catch (e) {
      _showSnackbar('نیٹ ورک مسئلہ۔ دوبارہ کوشش کریں۔', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF8E3),
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                " ویژن",
                style: GoogleFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF02A96C),
                ),
              ),
              Text(
                "ایگری",
                style: GoogleFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFA726),
                ),
              ),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF02A96C).withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF02A96C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.email, size: 40, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              "OTP حاصل کرنے کے لیے ای میل درج کریں",
                              style: GoogleFonts.vazirmatn(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  labelText: "ای میل ایڈریس",
                                  labelStyle: GoogleFonts.vazirmatn(),
                                  hintText: "kisaan@gmail.com",
                                  hintStyle: GoogleFonts.vazirmatn(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: _emailController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () => setState(() => _emailController.clear()),
                                        )
                                      : null,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'ای میل درج کریں';
                                  }
                                  if (value.contains(' ')) {
                                    return 'ای میل میں خالی جگہ نہیں ہونی چاہیے';
                                  }
                                  if (!value.contains('@')) {
                                    return '@ شامل کریں';
                                  }
                                  if (!value.contains('.')) {
                                    return 'غلط ای میل ایڈریس';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF02A96C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _requestEmailOTP,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'OTP بھیجیں',
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}