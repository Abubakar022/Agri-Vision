import 'dart:convert';
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
  final Color _green = const Color(0xFF02A96C);

  // Urdu Districts and Tehsils of Punjab
  final Map<String, List<String>> punjabDistricts = {
    "اٹک": ["اٹک", "فتح جنگ", "حسن ابدال", "حضرو", "جنڈ", "پنڈی گھیب", "اس میں موجود نہیں"],
    "بہاولنگر": ["بہاولنگر", "چشتیاں", "ہارون آباد", "منچن آباد", "فورٹ عباس", "اس میں موجود نہیں"],
    "بہاولپور": ["بہاولپور", "احمدپور شرقیہ", "حاصلپور", "خیرپور ٹامیوالی", "یزمان", "اس میں موجود نہیں"],
    "بھکر": ["بھکر", "دریا خان", "کالور کوٹ", "منکیرہ", "دُلیوالا", "اس میں موجود نہیں"],
    "چکوال": ["چکوال", "چوا سیداں شاہ", "کلر کہار", "تلہ گنگ", "اس میں موجود نہیں"],
    "چنیوٹ": ["چنیوٹ", "بھوانہ", "لالیاں", "اس میں موجود نہیں"],
    "ڈی جی خان": ["ڈیرہ غازی خان", "تونسہ", "کوت چٹھہ", "قبائلی علاقہ", "اس میں موجود نہیں"],
    "فیصل آباد": ["فیصل آباد", "جڑانوالہ", "تندلیانوالہ", "سمندری", "چک جھمرہ", "اس میں موجود نہیں"],
    "گوجرانوالہ": ["گوجرانوالہ", "کاموکی", "وزیرآباد", "نوشہرہ ورکاں", "اس میں موجود نہیں"],
    "گجرات": ["گجرات", "کھاریاں", "سری عالمگیر", "اس میں موجود نہیں"],
    "حافظ آباد": ["حافظ آباد", "پندی بھٹیاں", "اس میں موجود نہیں"],
    "جھنگ": ["جھنگ", "شورکوٹ", "احمدپور سیال", "اٹھارہ ہزاری", "اس میں موجود نہیں"],
    "جہلم": ["جہلم", "دینہ", "پند دادن خان", "سوہاوہ", "اس میں موجود نہیں"],
    "قصور": ["قصور", "پتوکی", "کوٹ رادھا کشن", "چونیاں", "اس میں موجود نہیں"],
    "خانیوال": ["خانیوال", "جہانیاں", "کبیر والا", "میان چنوں", "اس میں موجود نہیں"],
    "خوشاب": ["خوشاب", "نورپور تھل", "قائد آباد", "نوشہرہ", "اس میں موجود نہیں"],
    "لاہور": ["لاہور", "ماڈل ٹاؤن", "رائے ونڈ", "واہگہ", "شالیمار", "اس میں موجود نہیں"],
    "لیہ": ["لیہ", "چوبارہ", "کروڑ لعل عیسن", "اس میں موجود نہیں"],
    "لودھراں": ["لودھراں", "دُنیاپور", "کہروڑ پکا", "اس میں موجود نہیں"],
    "منڈی بہاؤالدین": ["منڈی بہاؤالدین", "پھالیہ", "ملکوال", "اس میں موجود نہیں"],
    "میانوالی": ["میانوالی", "عیسی خیل", "پپلاں", "اس میں موجود نہیں"],
    "ملتان": ["ملتان", "شجاع آباد", "جلالپور پیروالا", "اس میں موجود نہیں"],
    "مظفرگڑھ": ["مظفرگڑھ", "علی پور", "جتوئی", "کوٹ ادو", "اس میں موجود نہیں"],
    "ننکانہ صاحب": ["ننکانہ صاحب", "سانگلہ ہل", "شاہ کوٹ", "اس میں موجود نہیں"],
    "نارووال": ["نارووال", "شکرگڑھ", "ظفر وال", "اس میں موجود نہیں"],
    "اوکاڑہ": ["اوکاڑہ", "دِیپالپور", "رینالہ خورد", "اس میں موجود نہیں"],
    "پاکپتن": ["پاکپتن", "عارف والا", "اس میں موجود نہیں"],
    "رحیم یار خان": ["رحیم یار خان", "خانپور", "صادق آباد", "لیاقت پور", "اس میں موجود نہیں"],
    "راجن پور": ["راجن پور", "جامپور", "روجھان مزاری", "اس میں موجود نہیں"],
    "راولپنڈی": ["راولپنڈی", "ٹیکسلا", "کہوٹہ", "کہوٹلی ستیاں", "کلر سیداں", "گوجر خان", "اس میں موجود نہیں"],
    "ساہیوال": ["ساہیوال", "چیچہ وطنی", "اس میں موجود نہیں"],
    "سرگودھا": ["سرگودھا", "بھلوال", "کوٹ مومن", "شاہ پور", "سلانوالی", "اس میں موجود نہیں"],
    "شیخوپورہ": ["شیخوپورہ", "فیروزوالہ", "مریدکے", "صفدرآباد", "شرقپور", "اس میں موجود نہیں"],
    "سیالکوٹ": ["سیالکوٹ", "ڈسکہ", "پسرور", "سمبڑیال", "اس میں موجود نہیں"],
    "ٹوبہ ٹیک سنگھ": ["ٹوبہ ٹیک سنگھ", "گوجرہ", "کمالیہ", "پیرمحل", "اس میں موجود نہیں"],
    "وہاڑی": ["وہاڑی", "میلسی", "بورے والا", "اس میں موجود نہیں"],
    "اس میں موجود نہیں": ["اس میں موجود نہیں"]
  };
  List<String> tehsils = [];
  String? selectedDistrict;

  void _calculatePrice(String value) {
    setState(() {
      final acres = double.tryParse(value) ?? 0;
      _price = (acres < 0) ? 0.0 : acres * 850;
    });
  }

  Future<void> submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar("غلطی", "براہِ کرم تمام فیلڈز درست کریں۔",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final url = Uri.parse('http://10.0.2.2:3000/order');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("کامیابی", "آپ کا آرڈر کامیابی سے جمع ہو گیا!",
            backgroundColor: _green, colorText: Colors.white);
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
          tehsils.clear();
        });
        Get.to(() => const OrderFinalPage());
      } else {
        Get.snackbar("غلطی", "سرور کی جانب سے مسئلہ پیش آیا۔",
            backgroundColor: Colors.red, colorText: Colors.white);
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
    final districts = punjabDistricts.keys.toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                          _buildTextFormField(hint: "نام", controller: _nameController, validator: (v) => v!.isEmpty ? "نام درکار ہے" : null),
                          _buildTextFormField(hint: "فون نمبر", controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'فون نمبر درکار ہے';
                            final reg = RegExp(r'^03[0-9]{9}$');
                            if (!reg.hasMatch(v)) return 'فون نمبر 11 ہندسوں کا ہونا چاہیے';
                            return null;
                          }),
                          _buildDropdownField(
                            label: "ضلع",
                            controller: _districtController,
                            items: districts,
                            validator: (v) => v == null || v.isEmpty ? 'ضلع منتخب کریں' : null,
                            onChanged: (value) {
                              setState(() {
                                selectedDistrict = value;
                                _districtController.text = value ?? '';
                                tehsils = punjabDistricts[value] ?? [];
                                _tehsilController.clear();
                              });
                            },
                          ),
                          _buildDropdownField(
                            label: "تحصیل",
                            controller: _tehsilController,
                            items: tehsils,
                            validator: (v) => v == null || v.isEmpty ? 'تحصیل منتخب کریں' : null,
                          ),
                          _buildTextFormField(hint: "شہر", controller: _cityController, validator: (v) => v!.isEmpty ? "شہر درکار ہے" : null),
                          _buildTextFormField(hint: "پتہ", controller: _addressController, maxLines: 2, validator: (v) => v!.isEmpty ? "پتہ درکار ہے" : null),
                          _buildTextFormField(
                            hint: "رقبہ (ایکرز میں)",
                            controller: _acreController,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty) ? "رقبہ درج کریں" : null,
                            onChanged: _calculatePrice,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("کل قیمت: ${_price.toStringAsFixed(0)} روپے",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : submitOrder,
                              icon: _isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                                  : const Icon(Icons.air, color: Colors.white),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  _isSubmitting ? "بجا رہا ہے..." : "بکنگ جمع کریں",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
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
        ),
      ),
    );
  }

  // Auto Urdu/English direction text field
  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          TextDirection currentDirection = TextDirection.rtl;

          void _updateDirection(String text) {
            if (text.isEmpty) return;
            final isUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
            setInnerState(() {
              currentDirection = isUrdu ? TextDirection.rtl : TextDirection.ltr;
            });
            if (onChanged != null) onChanged(text);
          }

          return TextFormField(
            controller: controller,
            textAlign: currentDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
            textDirection: currentDirection,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: _green,
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _green, width: 2.0)),
            ),
            validator: validator,
            onChanged: _updateDirection,
          );
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    String? Function(String?)? validator,
    Function(String?)? onChanged,
  }) {
    final currentValue = controller.text.isEmpty || !items.contains(controller.text)
        ? null
        : controller.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          hintText: label,
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Align(alignment: Alignment.centerRight, child: Text(e)))).toList(),
        onChanged: (value) {
          controller.text = value ?? '';
          if (onChanged != null) onChanged(value);
        },
        validator: validator,
      ),
    );
  }
}
