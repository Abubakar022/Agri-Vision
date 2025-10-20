import 'dart:convert';

import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingConfirmationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DroneBookingScreen extends StatefulWidget {
  const DroneBookingScreen({super.key});

  @override
  State<DroneBookingScreen> createState() => _DroneBookingScreenState();
}

class _DroneBookingScreenState extends State<DroneBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _tehsilController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _acreController = TextEditingController();

  double _price = 0.0;
  bool _isSubmitting = false;

  // green color used across the screen
  final Color _green = const Color(0xFF02A96C);

  void _calculatePrice(String value) {
    setState(() {
      final acres = double.tryParse(value) ?? 0;
      _price = (acres < 0) ? 0.0 : acres * 850;
    });
  }

  Future<void> submitOrder() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      // show a focused snackbar for user
      Get.snackbar("غلطی", "براہِ کرم تمام فیلڈز درست کریں۔",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Use emulator-local URL (change to your real server / ip for device)
      final url = Uri.parse('http://10.0.2.2:3000/order');

      // Get Firebase UID if available (optional)
      User? user = FirebaseAuth.instance.currentUser;
      final String uid = user?.uid ?? '';

      final body = {
        "userId": uid,
        "Username": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "district": _districtController.text.trim(),
        "tehsil": _tehsilController.text.trim(),
        "city": _cityController.text.trim(),
        "address": _addressController.text.trim(),
        "acres": double.tryParse(_acreController.text.trim()) ?? 0,
        "price": _price,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // success
        Get.snackbar("کامیابی", "آپ کا آرڈر کامیابی سے جمع ہو گیا!",
            backgroundColor: _green, colorText: Colors.white);

        // clear the form
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _districtController.clear();
        _tehsilController.clear();
        _cityController.clear();
        _addressController.clear();
        _acreController.clear();
        setState(() {
          _price = 0.0;
        });

        // Navigate to confirmation
        Get.to(() => const OrderFinalPage());
      } else {
        // Try decode JSON message, fallback to raw body
        try {
          final data = jsonDecode(response.body);
          Get.snackbar("غلطی", data["message"] ?? "آرڈر جمع کرنے میں مسئلہ ہوا۔",
              backgroundColor: Colors.red, colorText: Colors.white);
        } catch (_) {
          Get.snackbar("غلطی",
              "سرور نے غیر متوقع جواب دیا (status: ${response.statusCode})",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("خرابی", "سرور سے رابطہ نہیں ہو سکا: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // available dropdown options
    final districts = [
      "فیصل آباد",
      "لاہور",
      "ملتان",
      "سرگودھا",
      "ساہیوال",
      "گوجرانوالہ"
    ];
    final tehsils = [
      "جڑانوالہ",
      "سمندری",
      "تاندلیانوالہ",
      "صدر فیصل آباد",
      "جھنگ بازار"
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // enforce RTL
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Top Right Heading
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "ڈرون سروس کی بکنگ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 8),

                          // Name
                          _buildTextFormField(
                            hint: "نام",
                            controller: _nameController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'نام درکار ہے';
                              }
                              if (v.trim().length < 2) {
                                return 'صحیح نام درج کریں';
                              }
                              return null;
                            },
                          ),

                          // Phone (exactly 11 digits and starts with 03)
                          _buildTextFormField(
                            hint: "فون نمبر",
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'فون نمبر درکار ہے';
                              }
                              final val = v.trim();
                              final reg = RegExp(r'^03[0-9]{9}$');
                              if (!reg.hasMatch(val)) {
                                return 'فون نمبر 11 ہندسوں کا ہونا چاہیے (مثال: 03001234567)';
                              }
                              return null;
                            },
                          ),

                          // District dropdown
                          _buildDropdownField(
                            label: "ضلع",
                            controller: _districtController,
                            items: districts,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'ضلع منتخب کریں';
                              return null;
                            },
                          ),

                          // Tehsil dropdown
                          _buildDropdownField(
                            label: "تحصیل",
                            controller: _tehsilController,
                            items: tehsils,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'تحصیل منتخب کریں';
                              return null;
                            },
                          ),

                          // City
                          _buildTextFormField(
                            hint: "شہر",
                            controller: _cityController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'شہر درکار ہے';
                              }
                              return null;
                            },
                          ),

                          // Address
                          _buildTextFormField(
                            hint: "پتہ",
                            controller: _addressController,
                            maxLines: 2,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'پتہ درکار ہے';
                              }
                              if (v.trim().length < 5) return 'پتہ مختصر ہے';
                              return null;
                            },
                          ),

                          // Acres
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: _acreController,
                              textAlign: TextAlign.right,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              cursorColor: _green, // green cursor
                              decoration: InputDecoration(
                                hintText: "رقبہ (ایکرز میں)",
                                hintTextDirection: TextDirection.rtl,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'رقبہ درج کریں';
                                }
                                final val = double.tryParse(v.trim());
                                if (val == null || val <= 0) return 'صحیح رقبہ درج کریں';
                                return null;
                              },
                              onChanged: (v) => _calculatePrice(v),
                            ),
                          ),

                          // Price display
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "کل قیمت: ${_price.toStringAsFixed(0)} روپے",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _green,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : submitOrder,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.air, color: Colors.white),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  _isSubmitting ? "بجا رہا ہے..." : "بکنگ جمع کریں",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green.withAlpha(230),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 5,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // helper: TextFormField with RTL and green cursor
  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: _green,
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
         focusedBorder: OutlineInputBorder( // Focus color
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _green, width: 2.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Dropdown with validation
  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    final String? currentValue = controller.text.isEmpty || !items.contains(controller.text)
        ? null
        : controller.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          hintText: label,
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(e, textAlign: TextAlign.right),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
        validator: validator,
      ),
    );
  }
}
