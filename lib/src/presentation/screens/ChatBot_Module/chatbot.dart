import 'dart:math';
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
      text:
          'السلام علیکم! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔',
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
  String _currentTTSLocale = "ur-PK";
  bool _showTTSIndicator = false;
  bool _isSpeaking = false;
  Map<String, String> _availableLocales = {};
  double _speechRate = 0.52;
  double _speechPitch = 1.15;
  double _speechVolume = 0.92;
  bool _ttsSettingsVisible = false;
  String _ttsEngineStatus = 'اردو آواز چیک کی جا رہی ہے';
  Message? _currentlySpeakingMessage; // Track which message is being spoken

  // Enhanced chatbot responses with natural Urdu and structured format for API integration
  final Map<String, Map<String, dynamic>> _botResponses = {
    'پیلے دھبے': {
      'response':
          'پیلے دھبے رسٹ کی بیماری کی علامت ہیں۔ سفارش: زینب فنگسائڈ کا سپرے کریں اور پانی کا متوازن استعمال کریں۔ تین دن بعد دوبارہ چیک کریں۔',
      'disease_name': 'رسٹ (Rust)',
      'recommendations': [
        'زینب فنگسائڈ کا سپرے کریں',
        'پانی کا متوازن استعمال کریں',
        'ہر تین دن بعد حالت چیک کریں',
        'متاثرہ پودوں کو الگ کریں'
      ],
      'severity': 'درمیانی',
      'treatment': 'فنگسائیڈ سپرے'
    },
    'سڑنا': {
      'response':
          'سڑنا پاؤڈری ملڈیو ہو سکتا ہے۔ کھیت میں ہوا کی گردش بڑھائیں۔ مناسب فنگسائڈ کا استعمال کریں۔ پانی کا چھڑکاؤ کم کریں۔',
      'disease_name': 'پاؤڈری ملڈیو (Powdery Mildew)',
      'recommendations': [
        'کھیت میں ہوا کی گردش بڑھائیں',
        'فنگسائڈ کا استعمال کریں',
        'پانی کا چھڑکاؤ کم کریں',
        'فضائی نمی کو کنٹرول کریں'
      ],
      'severity': 'ہلکی',
      'treatment': 'ہوا کی گردش اور فنگسائیڈ'
    },
    'سیاہ دھبے': {
      'response':
          'سیاہ دھبے ٹیلے سنٹ کی بیماری کی علامت ہیں۔ پودوں کو الگ کریں اور کاربندازیم سپرے کریں۔',
      'disease_name': 'ٹیلے سنٹ (Tilletia)',
      'recommendations': [
        'متاثرہ پودوں کو فوری الگ کریں',
        'کاربندازیم فنگسائڈ سپرے کریں',
        'بیج کو علاج کریں',
        'کھیت کو ہر سال تبدیل کریں'
      ],
      'severity': 'شدید',
      'treatment': 'کاربندازیم فنگسائیڈ'
    },
    'جھلساؤ': {
      'response':
          'جھلساؤ کیلشیئم کی کمی کی علامت ہو سکتا ہے۔ کیلشیئم نائٹریٹ کا استعمال کریں اور پانی کا شیڈول بہتر کریں۔',
      'disease_name': 'کیلشیئم کی کمی (Calcium Deficiency)',
      'recommendations': [
        'کیلشیئم نائٹریٹ کا استعمال کریں',
        'پانی کا شیڈول بہتر کریں',
        'مٹی کی پی ایچ چیک کریں',
        'کھاد کا متوازن استعمال کریں'
      ],
      'severity': 'ہلکی',
      'treatment': 'کیلشیئم نائٹریٹ'
    },
    'سفوف نما تہ': {
      'response':
          'سفوف نما تہ پاؤڈری ملڈیو کی واضح علامت ہے۔ سلفر سپرے کریں اور کھیت کی صفائی کریں۔',
      'disease_name': 'پاؤڈری ملڈیو (Powdery Mildew)',
      'recommendations': [
        'سلفر بیسڈ فنگسائڈ سپرے کریں',
        'کھیت کی صفائی کریں',
        'پودوں کے درمیان فاصلہ رکھیں',
        'سہ پہر کے بعد پانی نہ دیں'
      ],
      'severity': 'درمیانی',
      'treatment': 'سلفر سپرے'
    },
    'default': {
      'response':
          'میں آپ کی بات سمجھ گیا ہوں۔ براہ کرم مزید تفصیل سے بیان کریں۔ مثلاً: پتے کیسی ہیں؟ کتنے دن ہوئے؟ کون سا حصہ متاثر ہے؟',
      'disease_name': 'نامعلوم',
      'recommendations': ['مزید تفصیل درکار'],
      'severity': 'نامعلوم',
      'treatment': 'تشخیص درکار'
    }
  };

  // Disease names in Urdu for matching
  final List<String> _diseaseKeywords = [
    'پیلے دھبے',
    'زرد دھبے',
    'پیلا',
    'زرد',
    'سڑنا',
    'ملڈیو',
    'سڑ',
    'گلنا',
    'سیاہ دھبے',
    'کالے دھبے',
    'سیاہ',
    'کالا',
    'جھلساؤ',
    'جھلس',
    'سوکھا',
    'خشک',
    'سفوف',
    'سفوف نما',
    'پاؤڈر',
    'آٹا'
  ];

  @override
  void initState() {
    super.initState();
    _initTTS();
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

  @override
  void dispose() {
    // Cancel any pending futures
    _controller.dispose();
    _scrollController.dispose();

    // Stop TTS and remove handlers before disposing
    _flutterTts.setCompletionHandler(() {});
    _flutterTts.setErrorHandler((msg) {});
    _flutterTts.setStartHandler(() {});

    _flutterTts.stop();

    super.dispose();
  }

  void _sendInitialMessage(String message) {
    if (_initialMessageSent) return;

    _initialMessageSent = true;
    _controller.text = message;
    _sendMessage();
  }

  Future<void> _initTTS() async {
    try {
      print("TTS شروع ہو رہا ہے...");

      // TTS سیٹنگز
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);

      // Set up completion handler with mounted check
      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingMessage = null;
          });
        }
      });

      // Set up error handler with mounted check
      _flutterTts.setErrorHandler((error) {
        print("بولنے میں خرابی: $error");
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingMessage = null;
          });
        }
      });

      // Set up start handler
      _flutterTts.setStartHandler(() {
        print("بولنا شروع ہو گیا");
      });

      // دستیاب زبانوں کی فہرست
      final languages = await _flutterTts.getLanguages;
      print("دستیاب زبانیں: $languages");

      _availableLocales.clear();
      for (var locale in languages) {
        _availableLocales[locale] = locale;
      }

      // اردو زبان کی تلاش
      String? selectedLocale;
      if (_availableLocales.containsKey("ur-PK")) {
        selectedLocale = "ur-PK";
      } else if (_availableLocales.containsKey("ur")) {
        selectedLocale = "ur";
      } else if (_availableLocales.containsKey("ur_IN")) {
        selectedLocale = "ur_IN";
      } else if (_availableLocales.containsKey("ar_SA")) {
        selectedLocale = "ar_SA"; // عربی بطور متبادل
      } else if (_availableLocales.containsKey("en_US")) {
        selectedLocale = "en_US"; // انگریزی بطور متبادل
      }

      if (selectedLocale != null) {
        await _flutterTts.setLanguage(selectedLocale);

        // اردو/عربی کے لیے سیٹنگز
        if (selectedLocale.contains("ur") || selectedLocale.contains("ar")) {
          await _flutterTts
              .setSpeechRate(0.45); // 0.0 - 1.0, slower = more natural
          await _flutterTts
              .setPitch(1.0); // 0.5 - 2.0, keep near 1.0 for natural tone
          await _flutterTts.setVolume(0.9); // 0.0 - 1.0
        } else {
          // انگریزی کے لیے سیٹنگز
          await _flutterTts.setSpeechRate(0.48);
          await _flutterTts.setPitch(1.2);
          await _flutterTts.setVolume(0.95);
        }

        if (mounted) {
          setState(() {
            _ttsAvailable = true;
            _currentTTSLocale = selectedLocale!;

            // انڈیکیٹر صرف اس صورت میں دکھائیں جب اردو دستیاب نہ ہو
            _showTTSIndicator = !selectedLocale.contains("ur");

            if (selectedLocale.contains("ur")) {
              _ttsEngineStatus = 'اردو آواز فعال ہے';
            } else if (selectedLocale.contains("ar")) {
              _ttsEngineStatus = 'عربی آواز استعمال ہو رہی ہے';
            } else {
              _ttsEngineStatus = 'انگریزی آواز استعمال ہو رہی ہے';
            }
          });
        }

        print("TTS تیار ہوگیا: $selectedLocale");
      } else {
        print("کوئی مناسب زبان نہیں ملی");
        if (mounted) {
          setState(() {
            _ttsAvailable = false;
            _ttsEngineStatus = 'آواز سروس دستیاب نہیں';
          });
        }
      }
    } catch (e) {
      print("TTS خرابی: $e");
      if (mounted) {
        setState(() {
          _ttsAvailable = false;
          _ttsEngineStatus = 'خرابی: $e';
        });
      }
    }
  }

  void _initSTT() async {
    try {
      _sttAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' && mounted) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print("STT خرابی: $error");
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      print("STT دستیاب: $_sttAvailable");
    } catch (e) {
      print("STT شروع کرنے میں خرابی: $e");
    }
  }

  // Detect disease from user message
  String _detectDisease(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    for (var keyword in _diseaseKeywords) {
      if (lowerMessage.contains(keyword.toLowerCase())) {
        // Map keyword to main disease
        if (keyword.contains('پیلے') || keyword.contains('زرد')) {
          return 'پیلے دھبے';
        } else if (keyword.contains('سڑنا') ||
            keyword.contains('ملڈیو') ||
            keyword.contains('گلنا')) {
          return 'سڑنا';
        } else if (keyword.contains('سیاہ') || keyword.contains('کالے')) {
          return 'سیاہ دھبے';
        } else if (keyword.contains('جھلساؤ') || keyword.contains('سوکھا')) {
          return 'جھلساؤ';
        } else if (keyword.contains('سفوف')) {
          return 'سفوف نما تہ';
        }
      }
    }

    return 'default';
  }

  Future<Map<String, dynamic>> _getBotResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));

    // Detect disease from user message
    String diseaseKey = _detectDisease(userMessage);

    // Get response data
    Map<String, dynamic> responseData =
        _botResponses[diseaseKey] ?? _botResponses['default']!;

    // Prepare response for display
    String responseText = responseData['response'];

    // Add structured data for API integration
    Map<String, dynamic> structuredResponse = {
      'user_query': userMessage,
      'detected_disease': diseaseKey,
      'disease_name': responseData['disease_name'],
      'severity': responseData['severity'],
      'treatment': responseData['treatment'],
      'recommendations': responseData['recommendations'],
      'confidence_level': diseaseKey != 'default' ? 'high' : 'low',
      'timestamp': DateTime.now().toIso8601String(),
      // API Integration Placeholder
      'api_endpoint': 'https://your-api.com/predict',
      'api_payload': {
        'symptoms': userMessage,
        'language': 'ur',
        'model_version': 'v1.0'
      }
    };

    // Log structured response (Replace with actual API call)
    print('Structured Response: $structuredResponse');

    return {
      'display_text': responseText,
      'structured_data': structuredResponse
    };
  }

  Future<void> _speak(String text, Message? message) async {
    if (!_ttsAvailable || _isSpeaking || !mounted) {
      return;
    }

    try {
      setState(() {
        _isSpeaking = true;
        _currentlySpeakingMessage = message;
      });

      // Stop any ongoing speech
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      // متن کو قدرتی انداز میں بولنے کے لیے تیار کریں
      String processedText = _processTextForNaturalTTS(text);

      print(
          "بول رہا ہوں: ${processedText.substring(0, min(50, processedText.length))}...");

      await _flutterTts.speak(processedText);
    } catch (e) {
      print("TTS خرابی: $e");
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessage = null;
        });
      }
    }
  }

  // Function to stop speech
  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
      print("بولنا روک دیا گیا");
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessage = null;
        });
      }
    } catch (e) {
      print("روکنے میں خرابی: $e");
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessage = null;
        });
      }
    }
  }

  // Function to toggle speech
  void _toggleSpeech(String text, Message? message) {
    if (_isSpeaking) {
      _stopSpeaking();
    } else {
      _speak(text, message);
    }
  }

  String _processTextForNaturalTTS(String text) {
    return text
        .replaceAll('۔', '۔ ... ') // add pause after full stop
        .replaceAll('!', '! ... ')
        .replaceAll('؟', '؟ ... ')
        .replaceAll('،', '، ... ')
        .replaceAll(':', ': ... ')
        .replaceAll(RegExp(r'\s+'), ' ') // clean extra spaces
        .trim();
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
      if (mounted) {
        setState(() => _isListening = true);
      }
      _spokenText = "";
      _controller.clear();

      await _speech.listen(
        listenFor: const Duration(seconds: 30),
        onResult: (result) {
          if (mounted) {
            setState(() {
              _spokenText = result.recognizedWords;
              _controller.text = _spokenText;
            });
          }
        },
        localeId: "ur-PK",
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      print("سننے میں خرابی: $e");
      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    try {
      _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isListening = false);
      }
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

    if (mounted) {
      setState(() {
        _messages.add(userMessage);
        _isLoading = true;
      });
    }

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _getBotResponse(text);
      final botResponse = response['display_text'];

      final botMessage = Message(
        text: botResponse,
        sender: 'bot',
        timestamp: DateTime.now(),
        structuredData: response['structured_data'],
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
        });
      }

      _scrollToBottom();

      // Auto-speak only for disease responses
      if (_ttsAvailable &&
          response['structured_data']['detected_disease'] != 'default') {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _speak(botResponse, botMessage);
          }
        });
      }
    } catch (e) {
      print("جواب لینے میں خرابی: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Urdu text input validator
  bool _isUrduText(String text) {
    if (text.trim().isEmpty) return true;

    // Urdu Unicode range: \u0600-\u06FF
    // Also includes Arabic and Persian characters
    final urduRegex = RegExp(
        r'^[\u0600-\u06FF\s\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF.,،؛!؟:()\-0-9]+$');
    return urduRegex.hasMatch(text);
  }

  // Filter English characters from input
  String _filterEnglish(String text) {
    // Remove English letters (A-Z, a-z)
    return text.replaceAll(RegExp(r'[A-Za-z]'), '');
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
        title: Text(
          'گندم کی بیماریاں',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF02A96C),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_ttsAvailable && _showTTSIndicator)
            IconButton(
              icon: Icon(
                Icons.volume_up,
                color: isUrduTTS ? Colors.green : Colors.orange,
              ),
              onPressed: _showTTSInstallGuide,
              tooltip: 'اردو آواز کی معلومات',
            ),
          IconButton(
            icon: Icon(Icons.help_outline, color: const Color(0xFF02A96C)),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // TTS Status Banner (Only show if Urdu voice not available)
          if (_showTTSIndicator)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
              ),
              child: GestureDetector(
                onTap: _showTTSInstallGuide,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabicTTS
                            ? 'عربی آواز استعمال ہو رہی ہے - اردو آواز انسٹال کریں'
                            : 'انگریزی آواز استعمال ہو رہی ہے - اردو آواز انسٹال کریں',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Chat Messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _buildLoadingBubble();
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == 'user';
    final isSpeakingThisMessage =
        _currentlySpeakingMessage == message && _isSpeaking;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF02A96C),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF02A96C) : Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 12 : 0),
                      topRight: Radius.circular(isUser ? 0 : 12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TTS Button - Always show for bot messages
                      if (!isUser && _ttsAvailable)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: isSpeakingThisMessage
                                ? Icon(Icons.stop, size: 20, color: Colors.red)
                                : Icon(
                                    Icons.volume_up,
                                    size: 20,
                                    color: _currentTTSLocale.contains("ur")
                                        ? const Color(0xFF02A96C)
                                        : Colors.orange,
                                  ),
                            onPressed: () =>
                                _toggleSpeech(message.text, message),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pulsing animation when speaking
                            if (isSpeakingThisMessage)
                              Row(
                                children: [
                                  _buildSoundWave(),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            Text(
                              message.text,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 14,
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: GoogleFonts.vazirmatn(
                                fontSize: 10,
                                color:
                                    isUser ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            // Show structured data for API debugging
                            if (message.structuredData != null && !isUser)
                              _buildStructuredData(message.structuredData!),
                          ],
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
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoundWave() {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSoundWaveBar(100),
          const SizedBox(width: 2),
          _buildSoundWaveBar(140),
          const SizedBox(width: 2),
          _buildSoundWaveBar(180),
          const SizedBox(width: 2),
          _buildSoundWaveBar(140),
          const SizedBox(width: 2),
          _buildSoundWaveBar(100),
        ],
      ),
    );
  }

  Widget _buildSoundWaveBar(int delay) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 3,
      height: _isSpeaking ? Random().nextInt(15) + 5 : 5,
      decoration: BoxDecoration(
        color: const Color(0xFF02A96C),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStructuredData(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API ڈیٹا (ڈیبگنگ کے لیے):',
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'بیماری: ${data['disease_name']} | شدت: ${data['severity']}',
            style: GoogleFonts.vazirmatn(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF02A96C),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جواب آ رہا ہے...',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
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
        padding: const EdgeInsets.all(8),
        color: const Color(0xFFFDF8E3),
        child: Row(
          children: [
            // Voice Button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : const Color(0xFF02A96C),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),

            const SizedBox(width: 8),

            // Text Input with Urdu-only validation
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
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
                        decoration: InputDecoration(
                          hintText: 'اپنا سوال یہاں لکھیں (صرف اردو)',
                          hintStyle: GoogleFonts.vazirmatn(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          errorText: _controller.text.isNotEmpty &&
                                  !_isUrduText(_controller.text)
                              ? 'صرف اردو متن درج کریں'
                              : null,
                          errorStyle: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                        onChanged: (value) {
                          // Filter English characters
                          if (value.isNotEmpty && !_isUrduText(value)) {
                            final filtered = _filterEnglish(value);
                            if (filtered != value) {
                              _controller.value = _controller.value.copyWith(
                                text: filtered,
                                selection: TextSelection.collapsed(
                                    offset: filtered.length),
                              );
                            }
                          }
                          if (mounted) {
                            setState(() {}); // Rebuild to show/hide error
                          }
                        },
                        onSubmitted: (value) {
                          if (_isUrduText(value)) {
                            _sendMessage();
                          }
                        },
                      ),
                    ),

                    // Send Button (disabled for non-Urdu text)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _isUrduText(_controller.text) &&
                                _controller.text.isNotEmpty
                            ? const Color(0xFF02A96C)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send,
                            color: _isUrduText(_controller.text) &&
                                    _controller.text.isNotEmpty
                                ? Colors.white
                                : Colors.grey[500]),
                        onPressed: _isUrduText(_controller.text) &&
                                _controller.text.isNotEmpty
                            ? _sendMessage
                            : null,
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
    } else {
      return '${difference.inHours} گھنٹے پہلے';
    }
  }

  void _showHelpDialog() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'مدد',
            style: GoogleFonts.vazirmatn(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF02A96C),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ایپ استعمال کرنے کا طریقہ:',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildHelpPoint('🎤', 'بول کر پیغام بھیجیں'),
              _buildHelpPoint('✍️', 'صرف اردو میں لکھیں'),
              _buildHelpPoint('🔊', 'جواب سننے کے لیے سپیکر آئیکن دبائیں'),
              _buildHelpPoint('⏹️', 'آواز بند کرنے کے لیے اسٹاپ آئیکن دبائیں'),
              _buildHelpPoint('⚠️', 'انگریزی حروف خود بخود حذف ہو جائیں گے'),
              const SizedBox(height: 10),
              Text(
                'پوچھی جانے والی بیماریاں:',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              _buildHelpPoint('•', 'پیلے دھبے - رسٹ بیماری'),
              _buildHelpPoint('•', 'سڑنا - پاؤڈری ملڈیو'),
              _buildHelpPoint('•', 'سیاہ دھبے - ٹیلے سنٹ'),
              _buildHelpPoint('•', 'جھلساؤ - کیلشیئم کی کمی'),
              _buildHelpPoint('•', 'سفوف نما تہ - پاؤڈری ملڈیو'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'بند کریں',
                style: GoogleFonts.vazirmatn(
                  color: const Color(0xFF02A96C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpPoint(String emoji, String text) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.vazirmatn(fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ));
  }

  void _showTTSInstallGuide() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.volume_up, color: const Color(0xFF02A96C)),
              const SizedBox(width: 10),
              Text(
                'اردو آواز انسٹال کریں',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF02A96C),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اردو میں بولنے کے لیے آپ کو TTS (Text-to-Speech) انجن انسٹال کرنا ہوگا۔',
                  style: GoogleFonts.vazirmatn(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.download, color: Colors.green),
                          title: Text('سب سے آسان طریقہ',
                              style: GoogleFonts.vazirmatn(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text('Google TTS انسٹال کریں',
                              style: GoogleFonts.vazirmatn(fontSize: 12)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _launchPlayStore(
                              "https://play.google.com/store/apps/details?id=com.google.android.tts"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download),
                              const SizedBox(width: 8),
                              Text('Google TTS ڈاؤن لوڈ کریں',
                                  style: GoogleFonts.vazirmatn()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'انسٹال کرنے کے بعد:',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02A96C),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInstallStep('1', 'Google TTS ایپ کھولیں'),
                _buildInstallStep('2', '"زبان ڈاؤن لوڈ کریں" پر کلک کریں'),
                _buildInstallStep('3', '"اردو (پاکستان)" تلاش کریں'),
                _buildInstallStep('4', 'اردو زبان ڈاؤن لوڈ کریں'),
                _buildInstallStep('5', 'آپ کی ایپ دوبارہ شروع کریں'),
                const SizedBox(height: 20),
                Text(
                  'اگر مسئلہ حل نہ ہو تو:',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _openAppSettings(),
                  icon: const Icon(Icons.settings),
                  label: Text('سیٹنگز کھولیں', style: GoogleFonts.vazirmatn()),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('بند کریں',
                  style: GoogleFonts.vazirmatn(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _testTTS();
              },
              child: Text('ٹیسٹ کریں',
                  style: GoogleFonts.vazirmatn(
                    color: const Color(0xFF02A96C),
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _launchPlayStore(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } catch (e) {
      print("Play Store کھولنے میں خرابی: $e");
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print("سیٹنگز کھولنے میں خرابی: $e");
    }
  }

  Future<void> _testTTS() async {
    if (!_ttsAvailable) return;

    final testPhrase = "آواز کی جانچ۔ اردو آواز کام کر رہی ہے۔";
    await _speak(testPhrase, null);
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;
  final Map<String, dynamic>? structuredData;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.structuredData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          sender == other.sender &&
          timestamp == other.timestamp;

  @override
  int get hashCode => text.hashCode ^ sender.hashCode ^ timestamp.hashCode;
}
