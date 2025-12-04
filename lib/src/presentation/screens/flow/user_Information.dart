import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
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
  String? _backendError;

  Future<void> _requestEmailOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _backendError = null;
    });

    try {
      String email = _emailController.text.trim();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'OTP بھیجا جا رہا ہے...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Appcolor.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Replace with your backend URL
      final url = Uri.parse('http://10.0.2.2:5000/request-otp'); // For emulator
      // For real device: http://YOUR_SERVER_IP:5000/api/auth/request-otp
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' || data['success'] == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          Get.off(() => OtpVerifyPage(
            email: email,
          ));
        } else {
          _showErrorSnackBar(data['message'] ?? 'OTP بھیجنے میں ناکامی');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(errorData['message'] ?? 'سرور سے جواب نہیں ملا');
      }

    } catch (e) {
      String errorMessage = 'نیٹ ورک کنکشن میں مسئلہ';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'سرور سے کنکشن نہیں ہو پا رہا۔ براہ کرم سرور چیک کریں';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMessage = 'انٹرنیٹ کنکشن نہیں ہے';
      }
      _showErrorSnackBar('$errorMessage: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ٹھیک ہے',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/userInformation.jpeg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withAlpha(150)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ای میل تصدیق",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "اپنا ای میل درج کریں، ہم آپ کو تصدیقی کوڈ بھیجیں گے",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white70),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: const TextStyle(color: Colors.white38),
                            labelText: 'اپنا ای میل درج کریں',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            suffixIcon: _emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                                    onPressed: () {
                                      setState(() => _emailController.clear());
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.email, color: Colors.white70, size: 20),
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _backendError = null;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'براہ کرم اپنا ای میل درج کریں';
                            }
                            
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                            );
                            
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'براہ کرم درست ای میل درج کریں';
                            }
                            
                            return null;
                          },
                        ),
                      ),
                      
                      if (_backendError != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withAlpha(100)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _backendError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "OTP آپ کے ای میل پر بھیجا جائے گا",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolor.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                          ),
                          onPressed: _isLoading ? null : _requestEmailOTP,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'OTP بھیجیں',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // Network Configuration Help
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "نیٹ ورک کنفیگریشن:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ایمیولیٹر: http://10.0.2.2:5000\nاصل ڈیوائس: http://YOUR_PC_IP:5000",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                          ],
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}