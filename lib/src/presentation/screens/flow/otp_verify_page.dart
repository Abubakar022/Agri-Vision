import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:agri_vision/src/presentation/screens/flow/user_information.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;

  const OtpVerifyPage({
    required this.email,
    super.key,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  late TextEditingController _otpController;
  bool _isLoading = false;
  bool _resendLoading = false;
  int _resendCooldown = 60;
  Timer? _timer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _isDisposed = false;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      if (_resendCooldown > 0) {
        if (mounted && !_isDisposed) {
          setState(() => _resendCooldown--);
        }
      } else {
        timer.cancel();
      }
    });
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
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_isDisposed || !mounted) return;
    if (_isLoading) return;
    
    String otp;
    try {
      otp = _otpController.text.trim();
    } catch (e) {
      return;
    }
    
    if (otp.length != 6) {
      _showSnackbar('6 ہندسوں کا OTP درج کریں', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://agri-node-backend-1075549714370.us-central1.run.app/verify-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' || data['success'] == true) {
          // ✅ FIXED LINE HERE
          final userId = data['user']['uId'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
          await UserSession.saveLogin(userId, widget.email);

          _showSnackbar('کامیابی سے لاگ ان ہو گئے!', const Color(0xFF02A96C));

          await Future.delayed(const Duration(milliseconds: 500));
          
          Get.offAll(() => const HomeNavigation());
        } else {
          throw data['message'] ?? 'غلط OTP';
        }
      } else {
        throw 'سرور سے جواب نہیں ملا';
      }
    } catch (e) {
      _showSnackbar('غلط OTP۔ دوبارہ کوشش کریں۔', Colors.red);
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isDisposed || !mounted) return;
    if (_resendCooldown > 0) return;
    if (_resendLoading) return;

    setState(() => _resendLoading = true);

    try {
      final url = Uri.parse('https://agri-node-backend-1075549714370.us-central1.run.app/request-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      ).timeout(const Duration(seconds: 30));

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' || data['success'] == true) {
          setState(() {
            _resendCooldown = 60;
            _resendLoading = false;
          });
          _startTimer();
          
          _showSnackbar('نیا OTP بھیج دیا گیا ہے', const Color(0xFF02A96C));
        } else {
          throw 'دوبارہ بھیجنے میں مسئلہ';
        }
      } else {
        throw 'سرور سے جواب نہیں ملا';
      }
    } catch (e) {
      _showSnackbar('دوبارہ بھیجنے میں ناکامی', Colors.red);
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _resendLoading = false);
      }
    }
  }

  void _changeEmail() {
    if (_isDisposed) return;
    Get.off(() => const UserInformation());
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    try {
      if (_otpController.hasListeners) {
        _otpController.dispose();
      }
    } catch (e) {
      debugPrint("Error disposing controller: $e");
    }
    super.dispose();
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
                "ایگری",
                style: GoogleFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF02A96C),
                ),
              ),
              Text(
                " ویژن",
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
                            const Icon(Icons.lock, size: 40, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              "او ٹی پی بھیجا جا رہا ہے",
                              style: GoogleFonts.vazirmatn(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.email,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textStyle: GoogleFonts.vazirmatn(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 60,
                            fieldWidth: 50,
                            activeColor: const Color(0xFF02A96C),
                            inactiveColor: Colors.grey,
                            selectedColor: const Color(0xFF02A96C),
                          ),
                          onCompleted: (value) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted && !_isDisposed) {
                                _verifyOtp();
                              }
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

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
                          onPressed: _isLoading ? null : _verifyOtp,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : Text(
                                  'تصدیق کریں',
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_resendCooldown > 0)
                            Text(
                              "دوبارہ بھیجیں ($_resendCooldown s)",
                              style: GoogleFonts.vazirmatn(color: Colors.grey),
                            )
                          else
                            TextButton(
                              onPressed: _resendLoading ? null : _resendOtp,
                              child: _resendLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      "دوبارہ OTP بھیجیں",
                                      style: GoogleFonts.vazirmatn(
                                        color: const Color(0xFF02A96C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextButton.icon(
                        icon: const Icon(Icons.email, size: 18),
                        label: Text(
                          "ای میل تبدیل کریں",
                          style: GoogleFonts.vazirmatn(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF02A96C),
                          ),
                        ),
                        onPressed: _changeEmail,
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
}