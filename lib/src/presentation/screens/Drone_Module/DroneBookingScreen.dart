import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingConfirmationScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class DroneBookingScreen extends StatefulWidget {
  const DroneBookingScreen({super.key});

  @override
  State<DroneBookingScreen> createState() => _DroneBookingScreenState();
}

class _DroneBookingScreenState extends State<DroneBookingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _tehsilController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _acreController = TextEditingController();

  double _price = 0.0;

  void _calculatePrice(String value) {
    setState(() {
      final acres = double.tryParse(value) ?? 0;
      _price = acres * 850;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02A96C),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Main Form (Centered)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTextField("نام", _nameController),
                          _buildTextField("فون نمبر", _phoneController,
                              keyboardType: TextInputType.phone),

                          // District Dropdown
                          _buildDropdownField("ضلع", _districtController, [
                            "فیصل آباد",
                            "لاہور",
                            "ملتان",
                            "سرگودھا",
                            "ساہیوال",
                            "گوجرانوالہ",
                          ]),

                          // Tehsil Dropdown (predefined)
                          _buildDropdownField("تحصیل", _tehsilController, [
                            "جڑانوالہ",
                            "سمندری",
                            "تاندلیانوالہ",
                            "صدر فیصل آباد",
                            "جھنگ بازار",
                          ]),

                          // City Field
                          _buildTextField("شہر", _cityController),

                          // Address Field
                          _buildTextField("پتہ", _addressController),

                          // Acres (Size)
                          TextField(
                            controller: _acreController,
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            onChanged: _calculatePrice,
                            decoration: InputDecoration(
                              hintText: "رقبہ (ایکرز میں)",
                              hintTextDirection: TextDirection.rtl,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Display
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "کل قیمت: ${_price.toStringAsFixed(0)} روپے",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF02A96C),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() =>  OrderFinalPage());
                              },
                              icon: const Icon(Icons.air, color: Colors.white),
                              label: const Text(
                                "بکنگ جمع کریں",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF02A96C).withAlpha(230),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Urdu Text Field
  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Urdu Dropdown Field
  Widget _buildDropdownField(
      String label, TextEditingController controller, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: label,
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(e, textAlign: TextAlign.right),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
      ),
    );
  }
}
