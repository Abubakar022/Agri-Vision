import 'dart:async';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showErrorSnackBar('براہ کرم 6 ہندسوں کا OTP درج کریں');
      return;
    }

    // Validate OTP contains only digits
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showErrorSnackBar('OTP صرف نمبرز پر مشتمل ہونا چاہیے');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify OTP with Firebase
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(cred);
      User? user = userCredential.user;
      
      if (user == null) {
        throw Exception("User not found after OTP verification");
      }

      // Save user session
      final prefs = await SharedPreferences.getInstance();
      UserSession.uid = user.uid;
      await prefs.setString('userId', user.uid);
      await prefs.setBool('isLoggedIn', true);

      // Call backend API
      await _registerUserWithBackend(user.uid);
      
    } on FirebaseAuthException catch (e) {
      String message = 'OTP تصدیق میں ناکامی';
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'غلط OTP درج کیا گیا';
          break;
        case 'session-expired':
          message = 'OTP کی مدت ختم ہو گئی ہے';
          break;
        case 'too-many-requests':
          message = 'بہت زیادہ کوششیں، براہ کرم تھوڑی دیر بعد کوشش کریں';
          break;
        default:
          message = 'OTP تصدیق میں مسئلہ: ${e.message}';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('مسئلہ پیش آیا، براہ کرم دوبارہ کوشش کریں');
      debugPrint('OTP Verification Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerUserWithBackend(String uid) async {
    try {
      final url = Uri.parse('https://agri-node-backend-1075549714370.us-central1.run.app/create');
      
      // Clean phone number - remove any spaces or special characters
      final cleanPhone = widget.phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Check if phone number is valid
      if (cleanPhone.length < 10) {
        throw Exception('Invalid phone number format');
      }

      final Map<String, dynamic> requestBody = {
        'uId': uid,
        'phone': cleanPhone,  // Send as string
      };

      debugPrint('Sending request to backend with: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Backend Response Status: ${response.statusCode}');
      debugPrint('Backend Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
        
        _showSuccessSnackBar(data['message'] ?? 'کامیابی سے رجسٹر ہو گئے!');
        
        // Navigate to home after successful verification
        if (mounted) {
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeNavigation()),
            (route) => false,
          );
        }
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        'سرور سے جواب ملا: ${response.statusCode}';
        } catch (e) {
          errorMessage = 'سرور سے جواب ملا: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('نیٹ ورک کنکشن میں مسئلہ: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('ڈیٹا فارمیٹ میں مسئلہ: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('سرور سے جواب کا انتظار کر رہے ہیں، دوبارہ کوشش کریں');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resendLoading = true);
    try {
      // Clean and format phone number
      String cleanPhone = widget.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (!cleanPhone.startsWith('92')) {
        cleanPhone = '92${cleanPhone}';
      }
      final formattedPhone = '+$cleanPhone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (cred) {},
        verificationFailed: (e) {
          String message = 'OTP دوبارہ بھیجنے میں ناکامی';
          if (e.code == 'invalid-phone-number') {
            message = 'غلط فون نمبر فارمیٹ';
          } else if (e.code == 'too-many-requests') {
            message = 'بہت زیادہ درخواستیں، براہ کرم تھوڑی دیر انتظار کریں';
          }
          _showErrorSnackBar(message);
        },
        codeSent: (verificationId, forceResendingToken) {
          // Note: In production, you might want to update the verificationId
          _showSuccessSnackBar('OTP دوبارہ بھیج دیا گیا');
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: const Duration(seconds: 60),
        forceResendingToken: null,
      );
    } catch (e) {
      _showErrorSnackBar('OTP دوبارہ بھیجنے میں مسئلہ پیش آیا');
      debugPrint('Resend OTP Error: $e');
    } finally {
      if (mounted) {
        setState(() => _resendLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Appcolor.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ہم نے OTP بھیجا ہے ${widget.phone} پر",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 50),

                    // OTP Field
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        autoFocus: true,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                        onCompleted: (_) => _verifyOtp(),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تصدیق کریں',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: _resendLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        child: _resendLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "OTP دوبارہ بھیجیں",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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