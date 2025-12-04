import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';

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
  String? _backendError;
  bool _isDisposed = false; // Track if disposed

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _isDisposed = false;
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed first

    // ✅ CRITICAL FIX: Wrap dispose in try-catch to prevent "already disposed" crashes
    try {
      _otpController.dispose();
    } catch (e) {
      debugPrint("Controller disposal error ignored: $e");
    }

    super.dispose();
  }

  // Safe state check
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _verifyOtp() async {
    // Check if widget is alive
    if (_isDisposed || !mounted) return;

    // Prevent double submission
    if (_isLoading) return;

    // ✅ CRITICAL FIX: Safe access to controller text
    String otp = '';
    try {
      otp = _otpController.text.trim();
    } catch (e) {
      // If controller is disposed, stop here silently
      return;
    }

    if (otp.length != 6) {
      _showErrorSnackBar('براہ کرم 6 ہندسوں کا OTP درج کریں');
      return;
    }

    _safeSetState(() {
      _isLoading = true;
      _backendError = null;
    });

    try {
      // IMPORTANT: Update this URL to match your backend
      // Android Emulator uses 10.0.2.2, Physical device needs your PC IP
      final url = Uri.parse('http://10.0.2.2:5000/verify-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' || data['success'] == true) {
          // Save user session
          final prefs = await SharedPreferences.getInstance();
          final userId = data['user']['uId']; // Get userId from response

          await prefs.setString('userId', userId);
          await prefs.setString('userEmail', widget.email);
          await prefs.setBool('isLoggedIn', true);

          // Also set in UserSession
          UserSession.uid = userId;

          _showSuccessSnackBar(data['message'] ??
              data['success'] ??
              'کامیابی سے لاگ ان ہو گئے!');

          // Navigate to home - WITHOUT using setState after navigation
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted && !_isDisposed) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeNavigation()),
              (route) => false,
            );
          }
        } else {
          _showErrorSnackBar(data['message'] ?? 'غلط OTP درج کیا گیا ہے');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(
            errorData['message'] ?? 'سرور سے کوئی جواب موصول نہیں ہوا');
      }
    } catch (e) {
      String errorMessage = 'نیٹ ورک کنکشن میں مسئلہ';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'سرور سے کنکشن نہیں ہو پا رہا۔ براہ کرم سرور چیک کریں';
      }
      _showErrorSnackBar('$errorMessage');
    } finally {
      // Only update state if not disposed
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isDisposed || !mounted) return;

    _safeSetState(() => _resendLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/auth/request-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' || data['success'] == true) {
          _showSuccessSnackBar('OTP دوبارہ کامیابی سے بھیج دیا گیا ہے');
        } else {
          _showErrorSnackBar(data['message'] ?? 'OTP بھیجنے میں ناکامی ہوئی');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(
            errorData['message'] ?? 'سرور سے کوئی جواب موصول نہیں ہوا');
      }
    } catch (e) {
      _showErrorSnackBar('OTP دوبارہ بھیجنے میں مسئلہ درپیش ہے');
    } finally {
      _safeSetState(() => _resendLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted || _isDisposed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Appcolor.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted || _isDisposed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.red,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      "ہم نے OTP بھیجا ہے ${widget.email} پر",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    if (_backendError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _backendError!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

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
                        onChanged: (value) {
                          _safeSetState(() {
                            _backendError = null;
                          });
                        },
                        onCompleted: (value) {
                          // Use a small delay to avoid race conditions
                          Future.delayed(const Duration(milliseconds: 100), () {
                            // Check explicitly before calling function
                            if (mounted && !_isDisposed) {
                              _verifyOtp();
                            }
                          });
                        },
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

                    // OTP Testing Help
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
                            "ٹیسٹنگ کے لیے:",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "1. سرور کنسول پر OTP دیکھیں\n2. OTP سرور کنسول پر نظر آئے گا",
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
          ],
        ),
      ),
    );
  }
}
