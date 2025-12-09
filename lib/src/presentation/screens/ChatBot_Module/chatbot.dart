import 'dart:math';

import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Chatbot extends StatefulWidget {
  final String? initialMessage;
  
  const Chatbot({super.key, this.initialMessage});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final List<Message> _messages = [
    Message(
      text: 'السلام علیکم! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔',
      sender: 'bot',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false;
  String _spokenText = "";
  bool _sttAvailable = false;
  bool _isLoading = false;
  bool _initialMessageSent = false;
  bool _ttsAvailable = false;
  String _currentTTSLocale = "en-US";
  bool _showTTSIndicator = false;
  bool _isSpeaking = false;
  Map<String, String> _availableLocales = {};
  double _speechRate = 0.52;
  double _speechPitch = 1.15;
  double _speechVolume = 0.92;
  bool _ttsSettingsVisible = false;
  String _ttsEngineStatus = 'جائزہ لیا جا رہا ہے';

  // Enhanced chatbot responses with natural Urdu
  final Map<String, String> _botResponses = {
    'سلام': 'وعلیکم السلام! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔ براہ کرم اپنے پودوں کی تفصیل بتائیں۔',
    'ہیلو': 'ہیلو جی! خوش آمدید۔ گندم کے کھیت کیسی حالت میں ہے؟ براہ کرم علامات بیان کریں۔',
    'پیلے دھبے': 'پیلے دھبے ... رسٹ بیماری کی علامت ہو سکتے ہیں۔ سفارش ... زینب فنگسائڈ کا سپرے کریں ... اور پانی کا متوازن استعمال کریں۔ تین دن بعد دوبارہ چیک کریں۔',
    'سڑنا': 'سڑنا ... یہ پاؤڈری ملڈیو ہو سکتا ہے۔ کھیت میں ہوا کی گردش بڑھائیں۔ مناسب فنگسائڈ کا استعمال کریں۔ پانی کا چھڑکاؤ کم کریں۔',
    'زنگ': 'زنگ ... یہ پتوں کا رسٹ ہے۔ مزاحمتی اقسام استعمال کریں۔ بروقت سپرے کریں۔ متاثرہ پودوں کو الگ کریں۔',
    'گندم': 'گندم ... اس کی بیماریوں میں رسٹ، سنٹ، پاؤڈری ملڈیو شامل ہیں۔ براہ کرم مخصوص علامات بتائیں۔ جیسے پیلے دھبے یا سڑنا۔',
    'ایفڈ': 'ایفڈ ... چھوٹے کیڑے ہیں۔ پودوں کا رس چوستے ہیں۔ مناسب کیڑے مار ادویات کا استعمال کریں۔ قدرتی دشمن بھی متعارف کروائیں۔',
    'کالی زنگ': 'کالی زنگ ... ایک سنگین بیماری ہے۔ فوری علاج ضروری ہے۔ مزاحمتی اقسام کاشت کریں۔ فنگسائڈ کا سپرے کریں۔',
    'بلاسٹ': 'بلاسٹ ... تیز رفتار پھیلنے والی بیماری۔ متاثرہ پودوں کو فوری الگ کریں۔ اینٹی بائیوٹک سپرے استعمال کریں۔',
    'بھوری زنگ': 'بھوری زنگ ... قوت مدافعت رکھنے والی اقسام استعمال کریں۔ پانی کا مناسب انتظام کریں۔ کھاد کا متوازن استعمال۔',
    'فیوزیریم': 'فیوزیریم ... ہیڈ بلائٹ کے لیے صحت مند بیج استعمال کریں۔ کھیت صاف رکھیں۔ متوازن کھاد دیں۔',
    'پتوں کا بلائٹ': 'پتوں کا بلائٹ ... باقاعدہ سپرے پروگرام اپنائیں۔ متاثرہ پتے جلائیں۔ کھیت کی صفائی ضروری ہے۔',
    'پھپھوندی': 'پھپھوندی ... ہوا کی گردش بڑھائیں۔ نمی کم کریں۔ فنگسائڈ کا استعمال کریں۔',
    'مائٹ': 'مائٹ ... مخصوص ایکارائسائڈز استعمال کریں۔ قدرتی تیل کے سپرے بھی مفید ہیں۔',
    'سیپٹوریا': 'سیپٹوریا ... متوازن کھاد کا استعمال کریں۔ متاثرہ پودوں کو الگ کریں۔ مناسب سپرے کریں۔',
    'کھنڈ': 'کھنڈ ... صاف ستھری کاشتکاری اپنائیں۔ بیماری کے بیج استعمال نہ کریں۔',
    'تنا مکھی': 'تنا مکھی ... بروقت اقدامات کریں۔ کیڑے مار ادویات کا استعمال کریں۔',
    'ٹین اسپاٹ': 'ٹین اسپاٹ ... مناسب پانی کا انتظام کریں۔ فنگسائڈ سپرے کریں۔',
    'پیلی زنگ': 'پیلی زنگ ... مزاحمتی اقسام استعمال کریں۔ متاثرہ حصے کاٹ دیں۔',
    'default': 'میں آپ کی بات سمجھ گیا ہوں۔ براہ کرم مزید تفصیل سے بیان کریں۔ مثلاً ... پتے کیسی ہیں؟ ... کتنے دن ہوئے؟ ... کون سا حصہ متاثر ہے؟'
  };

  @override
  void initState() {
    super.initState();
    _initEnhancedTTS();
    _initSTT();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      
      if (widget.initialMessage != null && !_initialMessageSent) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendInitialMessage(widget.initialMessage!);
        });
      }
    });
  }

  void _sendInitialMessage(String message) {
    if (_initialMessageSent) return;
    
    _initialMessageSent = true;
    _controller.text = message;
    _sendMessage();
  }

  Future<void> _initEnhancedTTS() async {
    try {
      print("Initializing Enhanced TTS...");
      
      // Initialize TTS with better settings
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setQueueMode(1); // Sequential queue
      
      // Get all available locales
      final languages = await _flutterTts.getLanguages;
      print("Available languages: $languages");
      
      // Store available locales
      _availableLocales.clear();
      for (var locale in languages) {
        _availableLocales[locale] = locale;
      }
      
      // Try to find best Urdu locale with priority
      final preferredUrduLocales = [
        "ur_PK",
        "urd_PK", 
        "ur_IN",
        "ur",
        "urd_Arab",
        "ur-PK",
        "urd-PK",
        "ur_PK.UTF-8",
        "urd_PK.UTF-8"
      ];
      
      String? selectedLocale;
      for (String locale in preferredUrduLocales) {
        if (_availableLocales.containsKey(locale)) {
          selectedLocale = locale;
          print("✅ Found preferred Urdu locale: $selectedLocale");
          break;
        }
      }
      
      // If Urdu not found, try Arabic as alternative
      if (selectedLocale == null) {
        print("Urdu locale not found, trying Arabic...");
        final arabicLocales = ["ar_SA", "ar_AE", "ar", "ar_EG"];
        for (String locale in arabicLocales) {
          if (_availableLocales.containsKey(locale)) {
            selectedLocale = locale;
            print("✅ Using Arabic as alternative: $selectedLocale");
            break;
          }
        }
      }
      
      // If still not found, use English but show indicator
      if (selectedLocale == null) {
        print("Arabic not found, trying English...");
        if (_availableLocales.containsKey("en_US")) {
          selectedLocale = "en_US";
        } else if (_availableLocales.containsKey("en_GB")) {
          selectedLocale = "en_GB";
        } else if (_availableLocales.containsKey("en")) {
          selectedLocale = "en";
        } else if (_availableLocales.isNotEmpty) {
          selectedLocale = _availableLocales.keys.first;
        }
        
        if (selectedLocale != null) {
          setState(() {
            _showTTSIndicator = true;
            _ttsEngineStatus = 'انگریزی آواز - اردو دستیاب نہیں';
          });
        }
      } else {
        setState(() {
          _ttsEngineStatus = selectedLocale!.contains("ur") 
              ? 'اردو آواز فعال' 
              : selectedLocale.contains("ar")
                  ? 'عربی آواز - قریب ترین'
                  : 'انگریزی آواز';
        });
      }
      
      if (selectedLocale != null) {
        await _flutterTts.setLanguage(selectedLocale);
        
        // Enhanced settings for natural voice
        if (selectedLocale.contains("ur") || selectedLocale.contains("ar")) {
          // Urdu/Arabic کے لئے optimized natural settings
          await _flutterTts.setSpeechRate(_speechRate);  // Natural speed
          await _flutterTts.setPitch(_speechPitch);      // Natural pitch variation
          await _flutterTts.setVolume(_speechVolume);    // Softer volume
          await _flutterTts.setSilence(300);             // Pause between sentences
        } else {
          // English کے لئے optimized settings
          await _flutterTts.setSpeechRate(0.48);
          await _flutterTts.setPitch(1.2);
          await _flutterTts.setVolume(0.95);
          await _flutterTts.setSilence(250);
        }
        
        // Test voice quality
        Future.delayed(const Duration(seconds: 1), () {
          _testVoiceQuality();
        });
        
        setState(() {
          _ttsAvailable = true;
          _currentTTSLocale = selectedLocale!;
        });
        
        print("TTS initialized with: $selectedLocale");
        
      } else {
        print("No suitable locale found");
        setState(() {
          _ttsAvailable = false;
          _ttsEngineStatus = 'آواز سروس دستیاب نہیں';
        });
      }
      
    } catch (e) {
      print("Enhanced TTS Initialization Error: $e");
      setState(() {
        _ttsAvailable = false;
        _ttsEngineStatus = 'خرابی: $e';
      });
    }
  }

  Future<void> _testVoiceQuality() async {
    if (!_ttsAvailable) return;
    
    try {
      print("Testing voice quality...");
      await _flutterTts.speak("آواز کی جانچ");
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print("Voice test failed: $e");
    }
  }

  void _initSTT() async {
    try {
      _sttAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print("STT Error: $error");
          setState(() => _isListening = false);
        },
      );
      print("STT Available: $_sttAvailable");
    } catch (e) {
      print("STT Initialization Error: $e");
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final lowerMessage = userMessage.toLowerCase();
    
    // Enhanced response matching with natural pauses
    if (lowerMessage.contains('پیلے') || lowerMessage.contains('دھبے') || lowerMessage.contains('زرد')) {
      return _botResponses['پیلے دھبے']!;
    } else if (lowerMessage.contains('سڑنا') || lowerMessage.contains('ملڈیو') || lowerMessage.contains('پھپھوند')) {
      return _botResponses['سڑنا']!;
    } else if (lowerMessage.contains('زنگ') || lowerMessage.contains('رسٹ') || lowerMessage.contains('rusted')) {
      return _botResponses['زنگ']!;
    } else if (lowerMessage.contains('سلام') || lowerMessage.contains('ہیلو') || lowerMessage.contains('السلام')) {
      return _botResponses['سلام']!;
    } else if (lowerMessage.contains('گندم') || lowerMessage.contains('wheat')) {
      return _botResponses['گندم']!;
    } else if (lowerMessage.contains('ایفڈ') || lowerMessage.contains('aphid') || lowerMessage.contains('کیڑے')) {
      return _botResponses['ایفڈ']!;
    } else if (lowerMessage.contains('کالی') && lowerMessage.contains('زنگ')) {
      return _botResponses['کالی زنگ']!;
    } else if (lowerMessage.contains('بلاسٹ') || lowerMessage.contains('blast')) {
      return _botResponses['بلاسٹ']!;
    } else if (lowerMessage.contains('بھوری') && lowerMessage.contains('زنگ')) {
      return _botResponses['بھوری زنگ']!;
    } else if (lowerMessage.contains('فیوزیریم') || lowerMessage.contains('fusarium')) {
      return _botResponses['فیوزیریم']!;
    } else if ((lowerMessage.contains('پتوں') || lowerMessage.contains('پتے')) && lowerMessage.contains('بلائٹ')) {
      return _botResponses['پتوں کا بلائٹ']!;
    } else if (lowerMessage.contains('پھپھوندی') || lowerMessage.contains('فنگس') || lowerMessage.contains('fungus')) {
      return _botResponses['پھپھوندی']!;
    } else if (lowerMessage.contains('مائٹ') || lowerMessage.contains('mite')) {
      return _botResponses['مائٹ']!;
    } else if (lowerMessage.contains('سیپٹوریا') || lowerMessage.contains('septoria')) {
      return _botResponses['سیپٹوریا']!;
    } else if (lowerMessage.contains('کھنڈ') || lowerMessage.contains('سماٹ') || lowerMessage.contains('smut')) {
      return _botResponses['کھنڈ']!;
    } else if (lowerMessage.contains('تنا') && lowerMessage.contains('مکھی')) {
      return _botResponses['تنا مکھی']!;
    } else if (lowerMessage.contains('ٹین') && lowerMessage.contains('اسپاٹ')) {
      return _botResponses['ٹین اسپاٹ']!;
    } else if (lowerMessage.contains('پیلی') && lowerMessage.contains('زنگ')) {
      return _botResponses['پیلی زنگ']!;
    } else {
      return _botResponses['default']!;
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsAvailable || _isSpeaking) {
      return;
    }

    try {
      setState(() {
        _isSpeaking = true;
      });

      // Stop any ongoing speech
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      // Show indicator if using non-Urdu voice
      bool isUsingUrdu = _currentTTSLocale.contains("ur");
      bool isUsingArabic = _currentTTSLocale.contains("ar");
      
      if (!isUsingUrdu && _showTTSIndicator) {
        _showTTSSnackbar(isUsingArabic);
      }

      // Process text for natural TTS output
      String processedText = _processTextForNaturalTTS(text, isUsingUrdu);
      
      print("Speaking: ${processedText.substring(0, min(50, processedText.length))}...");
      
      // Speak the text
      await _flutterTts.speak(processedText);
      
      // Listen for completion
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });

      // Set error handler
      _flutterTts.setErrorHandler((error) {
        print("TTS Error during speech: $error");
        setState(() {
          _isSpeaking = false;
        });
        
        if (error.contains("not available") || error.contains("language")) {
          _showUrduInstallGuide();
        }
      });

    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _isSpeaking = false;
      });
      
      if (e.toString().contains("not available") || e.toString().contains("language")) {
        _showUrduInstallGuide();
      }
    }
  }

  String _processTextForNaturalTTS(String text, bool isUrdu) {
    if (isUrdu || _currentTTSLocale.contains("ar")) {
      // For Urdu/Arabic - add natural pauses and emphasis
      return text
          // Sentence endings with longer pauses
          .replaceAll('۔', '۔ ... ... ')
          .replaceAll('!', '! ... ... ')
          .replaceAll('؟', '؟ ... ... ')
          
          // Commas with shorter pauses
          .replaceAll('،', '، ... ')
          .replaceAll(':', ': ... ')
          
          // Important terms with emphasis
          .replaceAll('رسٹ', ' ... رسٹ ... ')
          .replaceAll('ملڈیو', ' ... ملڈیو ... ')
          .replaceAll('بلائٹ', ' ... بلائٹ ... ')
          .replaceAll('ایفڈ', ' ... ایفڈ ... ')
          .replaceAll('فنگسائڈ', ' ... فنگسائڈ ... ')
          
          // Recommendations with pauses
          .replaceAll('سفارش', ' ... سفارش ... ')
          .replaceAll('براہ کرم', ' ... براہ کرم ... ')
          .replaceAll('ضروری ہے', ' ... ضروری ہے ... ')
          
          // Numbers with spacing
          .replaceAllMapped(RegExp(r'\d+'), (match) {
            return ' ${match.group(0)} ';
          })
          
          // Remove extra spaces
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    } else {
      // For English - improve pronunciation of Urdu terms
      return text
          .replaceAll('زنگ', 'rust')
          .replaceAll('بلائٹ', 'blight')
          .replaceAll('ملڈیو', 'mildew')
          .replaceAll('ایفڈ', 'aphid')
          .replaceAll('فنگسائڈ', 'fungicide')
          .replaceAll('رسٹ', 'rust')
          .replaceAll('گندم', 'wheat');
    }
  }

  void _showTTSSnackbar(bool isArabic) {
    String message = isArabic 
        ? 'اردو آواز دستیاب نہیں - عربی میں بول رہا ہوں'
        : 'اردو آواز دستیاب نہیں - انگریزی میں بول رہا ہوں';
    
    Get.showSnackbar(
      GetSnackBar(
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.language, color: isArabic ? Colors.blue : Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isArabic ? Colors.blue : Colors.orange,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        animationDuration: const Duration(milliseconds: 300),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        mainButton: TextButton(
          onPressed: _showUrduInstallGuide,
          child: Text(
            'انسٹال کریں',
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showUrduInstallGuide() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'بہتر اردو آواز کے لیے',
            style: GoogleFonts.vazirmatn(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF02A96C),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قدرتی اردو آواز کے لیے براہ کرم ان میں سے کوئی ایک TTS انجن انسٹال کریں:',
                  style: GoogleFonts.vazirmatn(fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                _buildTTSOption(
                  'Google Text-to-Speech',
                  'سب سے بہتر معیار',
                  'https://play.google.com/store/apps/details?id=com.google.android.tts',
                  Icons.audiotrack,
                  Colors.green,
                ),
                
                _buildTTSOption(
                  'Microsoft TTS',
                  'بہتر اردو سپورٹ',
                  'https://play.google.com/store/apps/details?id=com.microsoft.tts',
                  Icons.record_voice_over,
                  Colors.blue,
                ),
                
                _buildTTSOption(
                  'Samsung TTS',
                  'سیمسنگ فونز کے لیے',
                  'https://play.google.com/store/apps/details?id=com.samsung.SMT',
                  Icons.phone_android,
                  Colors.purple,
                ),
                
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),
                
                Text(
                  'انسٹال کرنے کے بعد:',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02A96C),
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildInstallStep('1', 'Settings > Language & Input کھولیں'),
                _buildInstallStep('2', 'Text-to-Speech Output پر جائیں'),
                _buildInstallStep('3', 'انجن منتخب کریں (Google TTS)'),
                _buildInstallStep('4', 'اردو زبان ڈاؤن لوڈ کریں'),
                _buildInstallStep('5', 'ایپ دوبارہ شروع کریں'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'بند کریں',
                style: GoogleFonts.vazirmatn(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _openAppSettings();
              },
              child: Text(
                'سیٹنگز کھولیں',
                style: GoogleFonts.vazirmatn(
                  color: const Color(0xFF02A96C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _testAllVoices();
              },
              child: Text(
                'آواز ٹیسٹ کریں',
                style: GoogleFonts.vazirmatn(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTTSOption(String title, String subtitle, String playStoreUrl, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.vazirmatn(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchPlayStore(playStoreUrl),
      ),
    );
  }

  Future<void> _launchPlayStore(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } catch (e) {
      print("Failed to launch Play Store: $e");
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print("Failed to open app settings: $e");
    }
  }

  Future<void> _testAllVoices() async {
    if (!_ttsAvailable) return;
    
    final testPhrases = [
      "آواز کی جانچ ... ایک، دو، تین۔",
      "گندم کی بیماریاں ... رسٹ اور ملڈیو۔",
      "براہ کرم تفصیل بتائیں۔"
    ];
    
    for (var phrase in testPhrases) {
      await _speak(phrase);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Widget _buildInstallStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vazirmatn(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  void _startListening() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'مائیکروفون کی اجازت درکار ہے',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_sttAvailable) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'وائس ریکگنیشن دستیاب نہیں',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isListening = true);
      _spokenText = "";
      _controller.clear();
      
      await _speech.listen(
        listenFor: const Duration(seconds: 30),
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
            _controller.text = _spokenText;
          });
        },
        localeId: "ur-PK",
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      print("Listening error: $e");
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    try {
      _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = Message(
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      final botResponse = await _getBotResponse(text);
      
      final botMessage = Message(
        text: botResponse,
        sender: 'bot',
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });
      
      _scrollToBottom();
      
      // Auto-speak bot response with delay
      if (_ttsAvailable) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _speak(botResponse);
        });
      }
    } catch (e) {
      print("Error getting bot response: $e");
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTTSSettings() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'آواز کی سیٹنگز',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF02A96C),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Voice Status
                    Card(
                      color: _currentTTSLocale.contains("ur") 
                          ? Colors.green[50]
                          : _currentTTSLocale.contains("ar")
                              ? Colors.blue[50]
                              : Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              'موجودہ آواز:',
                              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _ttsEngineStatus,
                              style: GoogleFonts.vazirmatn(
                                color: _currentTTSLocale.contains("ur") 
                                    ? Colors.green
                                    : _currentTTSLocale.contains("ar")
                                        ? Colors.blue
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Speech Rate
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'رفتار',
                              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_speechRate.toStringAsFixed(2)}',
                              style: GoogleFonts.vazirmatn(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        Slider(
                          value: _speechRate,
                          min: 0.3,
                          max: 0.8,
                          divisions: 10,
                          onChanged: (value) async {
                            setState(() => _speechRate = value);
                            await _flutterTts.setSpeechRate(value);
                          },
                          activeColor: const Color(0xFF02A96C),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Pitch
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'آواز کی اونچائی',
                              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_speechPitch.toStringAsFixed(2)}',
                              style: GoogleFonts.vazirmatn(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        Slider(
                          value: _speechPitch,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          onChanged: (value) async {
                            setState(() => _speechPitch = value);
                            await _flutterTts.setPitch(value);
                          },
                          activeColor: const Color(0xFF02A96C),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Test Button
                    ElevatedButton.icon(
                      onPressed: () => _speak("یہ آواز کی جانچ ہے۔ گندم کی بیماریوں کی معلومات۔"),
                      icon: const Icon(Icons.volume_up),
                      label: Text(
                        'آواز ٹیسٹ کریں',
                        style: GoogleFonts.vazirmatn(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02A96C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'بند کریں',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    _showUrduInstallGuide();
                  },
                  child: Text(
                    'بہتر آواز انسٹال کریں',
                    style: GoogleFonts.vazirmatn(
                      color: const Color(0xFF02A96C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isUrduTTS = _currentTTSLocale.contains("ur");
    bool isArabicTTS = _currentTTSLocale.contains("ar");

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8E3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF02A96C),
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'گندم کی بیماریوں کی معلومات',
              style: GoogleFonts.vazirmatn(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF02A96C),
                fontSize: 20,
              ),
            ),
            if (_showTTSIndicator) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isArabicTTS ? Colors.blue : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isArabicTTS ? 'AR' : 'EN',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF02A96C)),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.volume_up,
              color: _ttsAvailable 
                  ? (isUrduTTS ? Colors.green : (isArabicTTS ? Colors.blue : Colors.orange))
                  : Colors.grey,
            ),
            onPressed: _ttsAvailable ? _showTTSSettings : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // TTS Status Banner
          if (_showTTSIndicator)
            GestureDetector(
              onTap: _showUrduInstallGuide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isArabicTTS
                        ? [Colors.blue[50]!, Colors.lightBlue[50]!]
                        : [Colors.orange[50]!, Colors.amber[50]!],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      color: isArabicTTS ? Colors.blue : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabicTTS
                            ? 'عربی آواز استعمال ہو رہی ہے - اردو کے لیے TTS انسٹال کریں'
                            : 'انگریزی آواز استعمال ہو رہی ہے - اردو کے لیے TTS انسٹال کریں',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          color: isArabicTTS ? Colors.blue[800] : Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isArabicTTS ? Colors.blue : Colors.orange,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),

          // Chat Messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      return _buildLoadingBubble();
                    }
                    
                    final message = _messages[index];
                    return _buildMessageBubble(message, isUrduTTS, isArabicTTS);
                  },
                ),
              ),
            ),
          ),
          
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isUrduTTS, bool isArabicTTS) {
    final isUser = message.sender == 'user';
    bool isLastBotMessage = !isUser && _messages.isNotEmpty && _messages.last == message;

    Color voiceIconColor = isUrduTTS
        ? const Color(0xFF02A96C)
        : isArabicTTS
            ? Colors.blue
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF02A96C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
                ),
                if (_showTTSIndicator)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isArabicTTS ? Colors.blue : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.language,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF02A96C) : Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser 
                          ? const Color(0xFF02A96C).withOpacity(0.3)
                          : const Color(0xFF02A96C).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser && _ttsAvailable)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: IconButton(
                            icon: Icon(
                              _isSpeaking && isLastBotMessage
                                  ? Icons.stop_circle
                                  : Icons.volume_up,
                              size: 20,
                              color: _isSpeaking && isLastBotMessage
                                  ? Colors.red
                                  : voiceIconColor,
                            ),
                            onPressed: () {
                              if (_isSpeaking && isLastBotMessage) {
                                _flutterTts.stop();
                              } else {
                                _speak(message.text);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 14,
                                color: isUser ? Colors.white : Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                                if (!isUser && _ttsAvailable && _showTTSIndicator)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isArabicTTS 
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isArabicTTS ? 'عربی' : 'انگریزی',
                                      style: GoogleFonts.vazirmatn(
                                        fontSize: 9,
                                        color: isArabicTTS ? Colors.blue : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isUser && _ttsAvailable)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            icon: Icon(
                              _isSpeaking && isLastBotMessage && isUser
                                  ? Icons.stop_circle
                                  : Icons.volume_up,
                              size: 20,
                              color: _isSpeaking && isLastBotMessage && isUser
                                  ? Colors.red
                                  : Colors.white70,
                            ),
                            onPressed: () => _speak(message.text),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF02A96C).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF02A96C),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جواب آ رہا ہے',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'گندم کی بیماریوں کی معلومات',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFFDF8E3),
        child: Row(
          children: [
            // Voice Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isListening ? 54 : 50,
              height: _isListening ? 54 : 50,
              decoration: BoxDecoration(
                color: _isListening 
                    ? Colors.red 
                    : const Color(0xFF02A96C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : const Color(0xFF02A96C)).withOpacity(0.4),
                    blurRadius: _isListening ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: _isListening ? 26 : 24,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Text Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF02A96C).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'اپنا سوال یہاں لکھیں یا بول کر بتائیں',
                          hintStyle: GoogleFonts.vazirmatn(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          suffixIcon: _spokenText.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _spokenText = "");
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    
                    // Send Button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF02A96C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF02A96C).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'ابھی';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} منٹ پہلے';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} گھنٹے پہلے';
    } else {
      return '${difference.inDays} دن پہلے';
    }
  }

  void _showHelpDialog() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'چیٹ بوٹ کیسے استعمال کریں',
            style: GoogleFonts.vazirmatn(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF02A96C),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem('🎤', 'وائس میں بات کریں - مائیک بٹن دبائیں'),
                _buildHelpItem('⌨️', 'ٹائپ کر کے پیغام بھیجیں'),
                if (_ttsAvailable) _buildHelpItem('🔊', 'جواب سننے کے لیے سپیکر آئیکن پر کلک کریں'),
                _buildHelpItem('⚙️', 'آواز کی سیٹنگز کے لیے ٹاپ رائٹ میں گیئر آئیکن'),
                _buildHelpItem('🌾', 'گندم کی بیماریوں کے بارے میں پوچھیں'),
                _buildHelpItem('💡', 'مثالیں: "پیلے دھبے"، "سڑنا"، "زنگ"'),
                if (_showTTSIndicator) 
                  _buildHelpItem('🌐', 'اردو آواز کے لیے TTS انجن انسٹال کریں'),
              ],
            ),
          ),
          actions: [
            if (_showTTSIndicator)
              TextButton(
                onPressed: _showUrduInstallGuide,
                child: Text(
                  'اردو آواز انسٹال کریں',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Get.back();
                _testAllVoices();
              },
              child: Text(
                'آواز ٹیسٹ کریں',
                style: GoogleFonts.vazirmatn(
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'سمجھ گیا',
                style: GoogleFonts.vazirmatn(
                  color: const Color(0xFF02A96C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vazirmatn(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}