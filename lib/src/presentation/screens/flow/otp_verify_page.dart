import 'dart:convert';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _resendLoading = false;

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      _showErrorSnackBar('براہ کرم OTP درج کریں');
      return;
    }

    if (_otpController.text.trim().length != 6) {
      _showErrorSnackBar('براہ کرم 6 ہندسوں کا OTP درج کریں');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Step 1: Verify OTP with Firebase
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // ✅ Sign in user with credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User not found after OTP verification");
      }

      // ✅ Step 2: Save userId (UID) globally + locally
      final prefs = await SharedPreferences.getInstance();
      UserSession.uid = user.uid;
      await prefs.setString('userId', user.uid);
      await prefs.setBool('isLoggedIn', true);

      // ✅ Step 3: Send user data to your MongoDB backend
      final url = Uri.parse('http://10.0.2.2:3000/create');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'uId': user.uid,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _showSuccessSnackBar(data['message'] ?? 'تصدیق کامیاب رہی!');

        // ✅ Step 4: Navigate to Home Screen
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
      if (e.code == 'invalid-verification-code') {
        message = 'غلط OTP درج کیا گیا';
      } else if (e.code == 'session-expired') {
        message = 'OTP کی مدت ختم ہو گئی ہے، دوبارہ کوشش کریں';
      }
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
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          _showErrorSnackBar('OTP دوبارہ بھیجنے میں ناکامی');
        },
        codeSent: (String verificationId, int? resendToken) {
          _showSuccessSnackBar('OTP دوبارہ بھیج دیا گیا');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showErrorSnackBar('OTP دوبارہ بھیجنے میں مسئلہ: $e');
    } finally {
      setState(() => _resendLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Appcolor.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            // Background with gradient overlay
            // Image.asset(
            //   'assets/images/otp.jpeg',
            //   fit: BoxFit.cover,
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Header Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "OTP کی تصدیق",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            children: [
                              TextSpan(text: "ہم نے OTP بھیجا ہے "),
                              TextSpan(
                                text: "03${widget.phone}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: " پر"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // OTP Input Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Field Heading
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, right: 4),
                          child: Text(
                            "OTP درج کریں",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // OTP Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 8,
                            ),
                            maxLength: 6,
                            decoration: InputDecoration(
                              hintText: '123456',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 20,
                                letterSpacing: 8,
                              ),
                              counterText: "",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        Text(
                          "6 ہندسوں کا کوڈ درج کریں",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolor.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          shadowColor: Appcolor.green.withOpacity(0.3),
                        ),
                        onPressed: _isLoading ? null : _verifyOtp,
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
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تصدیق کریں',
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
                    
                    const SizedBox(height: 24),
                    
                    // Resend OTP Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "OTP موصول نہیں ہوا؟",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _resendLoading ? null : _resendOtp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: _resendLoading
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "دوبارہ بھیجیں",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Info Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Appcolor.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "یہ OTP 5 منٹ کے لیے درست رہے گا",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
// import 'dart:convert';
// import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
// import 'package:agri_vision/src/presentation/screens/Navigation/navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OtpVerifyPage extends StatefulWidget {
//   final String phone;
//   final String verificationId;

//   const OtpVerifyPage({
//     required this.phone,
//     required this.verificationId,
//     super.key,
//   });

//   @override
//   State<OtpVerifyPage> createState() => _OtpVerifyPageState();
// }

// class _OtpVerifyPageState extends State<OtpVerifyPage> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _verifyOtp() async {
//     if (_otpController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('براہ کرم OTP درج کریں')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // ✅ Step 1: Verify OTP with Firebase
//       final cred = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: _otpController.text.trim(),
//       );

//       // ✅ Sign in user with credential
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCredential(cred);

//       User? user = userCredential.user; // Firebase user object
//       if (user == null) {
//         throw Exception("User not found after OTP verification");
//       }

//       // ✅ Step 2: Save userId (UID) globally + locally
//       final prefs = await SharedPreferences.getInstance();
//       UserSession.uid = user.uid;
//       await prefs.setString('userId', user.uid);
//       await prefs.setBool('isLoggedIn', true);

//       // ✅ Step 3: Send user data to your MongoDB backend
//       final url = Uri.parse('http://10.0.2.2:3000/create');
//       final resp = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'phone': widget.phone,
//           'uId': user.uid,
//         }),
//       );

//       if (resp.statusCode == 200) {
//         final data = jsonDecode(resp.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'تصدیق کامیاب رہی!')),
//         );

//         // ✅ Step 4: Navigate to Home Screen
//         Future.delayed(const Duration(seconds: 1), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const HomeNavigation()),
//           );
//         });
//       } else {
//         final data = jsonDecode(resp.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(data['message'] ?? 'ڈیٹا محفوظ کرنے میں مسئلہ')),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = 'OTP غلط ہے یا ختم ہو چکا ہے';
//       if (e.code == 'invalid-verification-code') {
//         message = 'غلط OTP درج کیا گیا';
//       } else if (e.code == 'session-expired') {
//         message = 'OTP کی مدت ختم ہو گئی ہے، دوبارہ کوشش کریں';
//       }
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(message)));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('مسئلہ پیش آیا: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.asset('assets/images/otp.jpeg', fit: BoxFit.cover),
//             Container(color: Colors.black.withAlpha(50)),
//             Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "OTP کی تصدیق",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         shadows: [
//                           Shadow(
//                             blurRadius: 10,
//                             color: Colors.black.withAlpha(50),
//                             offset: const Offset(1, 2),
//                           )
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextField(
//                       controller: _otpController,
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         letterSpacing: 3,
//                         fontSize: 18,
//                       ),
//                       textDirection: TextDirection.rtl,
//                       decoration: InputDecoration(
//                         labelText: 'OTP درج کریں',
//                         labelStyle: const TextStyle(
//                             color: Colors.white70, fontSize: 16),
//                         filled: true,
//                         fillColor: Colors.white.withAlpha(50),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.white70),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Appcolor.green,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           elevation: 6,
//                           shadowColor: Colors.black54,
//                         ),
//                         onPressed: _isLoading ? null : _verifyOtp,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2.5,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Text(
//                                 'تصدیق کریں',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     RichText(
//                       textAlign: TextAlign.center,
//                       text: TextSpan(
//                         style: const TextStyle(
//                             fontSize: 14, color: Colors.white70),
//                         children: [
//                           const TextSpan(
//                               text: "اگر آپ کو OTP موصول نہیں ہوا، "),
//                           WidgetSpan(
//                             child: GestureDetector(
//                               onTap: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text('OTP دوبارہ بھیج دیا گیا')),
//                                 );
//                               },
//                               child: const Text(
//                                 "دوبارہ بھیجیں",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const TextSpan(text: " پر کلک کریں۔"),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
