import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/flow/otp_verify_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String phone = '+92${_phoneController.text.trim()}';
      
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

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'OTP بھیجنے میں ناکامی';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'غلط فون نمبر کی شکل۔ براہ کرم صحیح نمبر درج کریں';
              break;
            case 'too-many-requests':
              errorMessage = 'بہت زیادہ کوششیں، براہ کرم تھوڑی دیر بعد کوشش کریں';
              break;
            case 'quota-exceeded':
              errorMessage = 'حد سے زیادہ درخواستیں، براہ کرم بعد میں کوشش کریں';
              break;
            case 'network-request-failed':
              errorMessage = 'نیٹ ورک کنکشن نہیں ہے، براہ کرم انٹرنیٹ چیک کریں';
              break;
            default:
              errorMessage = 'نظام میں خرابی: ${e.message}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Get.off(() => OtpVerifyPage(
  phone: _phoneController.text.trim(),
  verificationId: verificationId,
));

        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP کی مدت ختم ہو گئی، براہ کرم دوبارہ کوشش کریں'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('نظام میں خرابی: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
       Image.asset(
      'assets/images/userInformation.jpeg',
      fit: BoxFit.cover,
    ),
    // Dark overlay for better text visibility
    Container(
      color: Colors.black.withAlpha(150), // Adjust alpha as needed
    ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Right-aligned headings
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "فون نمبر کی تصدیق",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "اپنا فون نمبر درج کریں، ہم آپ کو تصدیقی کوڈ بھیجیں گے",
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

                      // Reordered input field - Number input on right, country code on left
           Container(
  decoration: BoxDecoration(
    color: Colors.white.withAlpha(50),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white70),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
  child: Row(
    children: [
   

      // Input Field
      Expanded(
        child: TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: '3xx-xxxxxxx',
            hintStyle: const TextStyle(color: Colors.white38),
            labelText: 'اپنا فون نمبر درج کریں',
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: _phoneController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () {
                      setState(() => _phoneController.clear());
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'براہ کرم اپنا فون نمبر درج کریں';
            }

            final trimmed = value.trim();

            // ✅ Pakistani number check: must start with 3 and have 10 digits total
            if (!RegExp(r'^3\d{9}$').hasMatch(trimmed)) {
              if (!trimmed.startsWith('3')) {
                return 'فون نمبر 3 سے شروع ہونا چاہیے';
              } else if (trimmed.length != 10) {
                return 'فون نمبر 10 ہندسوں کا ہونا چاہیے (مثلاً: 3366215818)';
              } else {
                return 'صرف ہندسے درج کریں (مثلاً: 3366215818)';
              }
            }
            return null;
          },
        ),
      ),
    ],
  ),
),
        
                      // Help text below input field
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "فون نمبر 3 سے شروع ہو کر 10 ہندسوں کا ہونا چاہیے",
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
                          onPressed: _isLoading ? null : _verifyPhoneNumber,
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
                                      Icons.send,
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

                      // Additional info
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                "OTP آپ کے فون پر SMS کے ذریعے بھیجا جائے گا",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}