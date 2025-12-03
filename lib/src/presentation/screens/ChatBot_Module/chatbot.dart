import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Chatbot responses - Improved for better TTS
  final Map<String, String> _botResponses = {
    'سلام': 'وعلیکم السلام! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔',
    'ہیلو': 'ہیلو! آپ کا استقبال ہے۔ براہ کرم اپنے گندم کے پودوں کی بیماری کی تفصیل بیان کریں۔',
    'پیلے دھبے': 'پیلے دھبے رسٹ بیماری کی علامت ہو سکتے ہیں۔ سفارش: زینب فنگسائڈ کا سپرے کریں اور پانی کا متوازن استعمال کریں۔',
    'سڑنا': 'یہ پاؤڈری ملڈیو ہو سکتا ہے۔ سفارش: گندم کے کھیتوں میں ہوا کی گردش بڑھائیں اور فنگسائڈ کا استعمال کریں۔',
    'زنگ': 'پتوں کا زنگ ایک عام بیماری ہے۔ سفارش: مزاحمتی اقسام کا استعمال کریں اور وقت پر سپرے کریں۔',
    'گندم': 'گندم کی مختلف بیماریوں میں رسٹ، سنٹ، اور پاؤڈری ملڈیو شامل ہیں۔ براہ کرم مخصوص علامات بیان کریں۔',
    'ایفڈ': 'ایفڈ چھوٹے کیڑے ہیں جو گندم کے پودوں کا رس چوستے ہیں۔ سفارش: مناسب کیڑے مار ادویات کا استعمال کریں۔',
    'کالی زنگ': 'کالی زنگ ایک سنگین بیماری ہے۔ سفارش: مزاحمتی اقسام کاشت کریں اور فنگسائڈ سپرے کریں۔',
    'بلاسٹ': 'بلاسٹ بیماری کے لیے فوری اقدامات کی ضرورت ہوتی ہے۔ سفارش: متاثرہ پودوں کو الگ کریں۔',
    'بھوری زنگ': 'بھوری زنگ کے خلاف قوت مدافعت رکھنے والی اقسام استعمال کریں۔',
    'فیوزیریم': 'فیوزیریم ہیڈ بلائٹ کے لیے صحت مند بیج استعمال کریں۔',
    'پتوں کا بلائٹ': 'پتوں کے بلائٹ کے خلاف باقاعدہ سپرے پروگرام اپنائیں۔',
    'پھپھوندی': 'پھپھوندی کے خلاف مناسب ہوا کی گردش ضروری ہے۔',
    'مائٹ': 'مائٹ کے خلاف مخصوص ایکارائسائڈز استعمال کریں۔',
    'سیپٹوریا': 'سیپٹوریا کے خلاف متوازن کھاد کا استعمال کریں۔',
    'کھنڈ': 'کھنڈ بیماری کے لیے صاف ستھری کاشتکاری اپنائیں۔',
    'تنا مکھی': 'تنا مکھی کے خلاف بروقت اقدامات کریں۔',
    'ٹین اسپاٹ': 'ٹین اسپاٹ کے لیے مناسب پانی کا انتظام کریں۔',
    'پیلی زنگ': 'پیلی زنگ کے خلاف مزاحمتی اقسام استعمال کریں۔',
    'default': 'میں آپ کی بات سمجھ گیا ہوں۔ براہ کرم مزید تفصیل سے بیان کریں تاکہ میں بہتر مدد کر سکوں۔'
  };

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

  void _sendInitialMessage(String message) {
    if (_initialMessageSent) return;
    
    _initialMessageSent = true;
    _controller.text = message;
    _sendMessage();
  }

  Future<void> _initTTS() async {
    try {
      // Initialize TTS
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);
      
      // Get all available locales
      final languages = await _flutterTts.getLanguages;
      
      // Store available locales
      _availableLocales.clear();
      for (var locale in languages) {
        _availableLocales[locale] = locale;
      }
      
      print("Available TTS languages: $_availableLocales");
      
      // Try to find best Urdu locale
      final urduLocales = [
        "ur-PK", "ur-PK-u-nu-latn", "ur_IN", "ur", "urd",
        "ur_PK", "ur_PK.UTF-8", "urd_PK", "urd_PK.UTF-8"
      ];
      
      String? selectedLocale;
      for (String locale in urduLocales) {
        if (_availableLocales.containsKey(locale)) {
          selectedLocale = locale;
          print("Found Urdu locale: $selectedLocale");
          break;
        }
      }
      
      // If Urdu not found, use English but show indicator
      if (selectedLocale == null) {
        if (_availableLocales.containsKey("en-US")) {
          selectedLocale = "en-US";
          setState(() {
            _showTTSIndicator = true;
          });
        } else if (_availableLocales.isNotEmpty) {
          selectedLocale = _availableLocales.keys.first;
          setState(() {
            _showTTSIndicator = true;
          });
        }
      }
      
      if (selectedLocale != null) {
        await _flutterTts.setLanguage(selectedLocale);
        
        // Optimize TTS settings
        if (selectedLocale.contains("ur")) {
          // Urdu-specific settings
          await _flutterTts.setSpeechRate(0.4); // Slower for Urdu
          await _flutterTts.setPitch(1.0);
        } else {
          // English/other language settings
          await _flutterTts.setSpeechRate(0.5);
          await _flutterTts.setPitch(1.1); // Slightly higher pitch for English
        }
        
        await _flutterTts.setVolume(1.0);
        
        setState(() {
          _ttsAvailable = true;
          _currentTTSLocale = selectedLocale!;
        });
      } else {
        setState(() {
          _ttsAvailable = false;
        });
      }
      
    } catch (e) {
      print("TTS Initialization Error: $e");
      setState(() {
        _ttsAvailable = false;
      });
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
          setState(() => _isListening = false);
        },
      );
    } catch (e) {
      print("STT Initialization Error: $e");
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final lowerMessage = userMessage.toLowerCase();
    
    // Improved response matching
    if (lowerMessage.contains('پیلے') || lowerMessage.contains('دھبے')) {
      return _botResponses['پیلے دھبے']!;
    } else if (lowerMessage.contains('سڑنا') || lowerMessage.contains('ملڈیو')) {
      return _botResponses['سڑنا']!;
    } else if (lowerMessage.contains('زنگ') || lowerMessage.contains('رسٹ')) {
      return _botResponses['زنگ']!;
    } else if (lowerMessage.contains('سلام') || lowerMessage.contains('ہیلو')) {
      return _botResponses['سلام']!;
    } else if (lowerMessage.contains('گندم')) {
      return _botResponses['گندم']!;
    } else if (lowerMessage.contains('ایفڈ')) {
      return _botResponses['ایفڈ']!;
    } else if (lowerMessage.contains('کالی زنگ')) {
      return _botResponses['کالی زنگ']!;
    } else if (lowerMessage.contains('بلاسٹ')) {
      return _botResponses['بلاسٹ']!;
    } else if (lowerMessage.contains('بھوری زنگ')) {
      return _botResponses['بھوری زنگ']!;
    } else if (lowerMessage.contains('فیوزیریم')) {
      return _botResponses['فیوزیریم']!;
    } else if (lowerMessage.contains('پتوں') && lowerMessage.contains('بلائٹ')) {
      return _botResponses['پتوں کا بلائٹ']!;
    } else if (lowerMessage.contains('پھپھوندی') || lowerMessage.contains('ملڈیو')) {
      return _botResponses['پھپھوندی']!;
    } else if (lowerMessage.contains('مائٹ')) {
      return _botResponses['مائٹ']!;
    } else if (lowerMessage.contains('سیپٹوریا')) {
      return _botResponses['سیپٹوریا']!;
    } else if (lowerMessage.contains('کھنڈ') || lowerMessage.contains('سماٹ')) {
      return _botResponses['کھنڈ']!;
    } else if (lowerMessage.contains('تنا مکھی')) {
      return _botResponses['تنا مکھی']!;
    } else if (lowerMessage.contains('ٹین اسپاٹ')) {
      return _botResponses['ٹین اسپاٹ']!;
    } else if (lowerMessage.contains('پیلی زنگ')) {
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

      // Determine if we're using Urdu or English
      bool isUsingUrdu = _currentTTSLocale.contains("ur");
      
      if (!isUsingUrdu && _showTTSIndicator) {
        // Show snackbar only when using English (not Urdu)
        _showTTSSnackbar();
      }

      // Process text for better TTS output
      String processedText = _processTextForTTS(text, isUsingUrdu);
      
      // Speak the text
      await _flutterTts.speak(processedText);
      
      // Listen for completion
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });

    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _isSpeaking = false;
      });
      
      if (e.toString().contains("not available")) {
        _showUrduInstallGuide();
      }
    }
  }

  String _processTextForTTS(String text, bool isUrdu) {
    if (isUrdu) {
      // For Urdu, add pauses for better natural flow
      return text
          .replaceAll('۔', '۔ ... ')
          .replaceAll('،', '، ... ')
          .replaceAll(':', ': ... ');
    } else {
      // For English, improve pronunciation
      return text
          .replaceAll('زنگ', 'rust')
          .replaceAll('بلائٹ', 'blight')
          .replaceAll('ملڈیو', 'mildew')
          .replaceAll('ایفڈ', 'aphid')
          .replaceAll('فنگسائڈ', 'fungicide');
    }
  }

  void _showTTSSnackbar() {
    // Show snackbar using GetX
    Get.showSnackbar(
      GetSnackBar(
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.language, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'اردو آواز دستیاب نہیں - انگریزی میں بول رہا ہوں',
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
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        animationDuration: const Duration(milliseconds: 300),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void _showUrduInstallGuide() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'اردو آواز کی تنصیب',
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
                  'اردو آواز چلانے کے لیے براہ کرم اپنے فون کی سیٹنگز میں اردو زبان کا TTS پیک ڈاؤن لوڈ کریں۔',
                  style: GoogleFonts.vazirmatn(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildInstallStep('1', 'Settings > Language & Input'),
                _buildInstallStep('2', 'Text-to-Speech Output'),
                _buildInstallStep('3', 'Google Text-to-Speech'),
                _buildInstallStep('4', 'اردو زبان ڈاؤن لوڈ کریں'),
              ],
            ),
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
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: Text(
                'سیٹنگز کھولیں',
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
      return;
    }

    if (!_sttAvailable) {
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
      );
    } catch (e) {
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
      
      // Auto-speak bot response
      if (_ttsAvailable) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _speak(botResponse);
        });
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    bool isUrduTTS = _currentTTSLocale.contains("ur");

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
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EN',
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
        ],
      ),
      body: Column(
        children: [
          // TTS Warning Banner
          if (_showTTSIndicator)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.withAlpha(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'اردو آواز دستیاب نہیں - فی الحال انگریزی میں بول رہا ہوں',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showUrduInstallGuide,
                    child: Text(
                      'انسٹال کریں',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: const Color(0xFF02A96C),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
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
                    return _buildMessageBubble(message);
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

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == 'user';
    bool isUrduTTS = _currentTTSLocale.contains("ur");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF02A96C),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  const Icon(Icons.agriculture, color: Colors.white, size: 18),
                  if (_showTTSIndicator)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.language, size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
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
                    color: isUser ? const Color(0xFF02A96C) : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.transparent : const Color(0xFF02A96C).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser && _ttsAvailable)
                        IconButton(
                          icon: Icon(
                            Icons.volume_up, 
                            size: 18, 
                            color: _isSpeaking && !isUser && _messages.last == message 
                                ? Colors.red 
                                : (isUrduTTS ? const Color(0xFF02A96C) : Colors.orange),
                          ),
                          onPressed: () => _speak(message.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
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
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: GoogleFonts.vazirmatn(
                                fontSize: 10,
                                color: isUser ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUser && _ttsAvailable)
                        IconButton(
                          icon: Icon(
                            Icons.volume_up, 
                            size: 18, 
                            color: _isSpeaking && isUser && _messages.last == message
                                ? Colors.red
                                : Colors.white70,
                          ),
                          onPressed: () => _speak(message.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF02A96C).withOpacity(0.3),
              ),
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
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFFDF8E3),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : const Color(0xFF02A96C),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
            const SizedBox(width: 12),
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
                ),
                child: TextField(
                  controller: _controller,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اپنا سوال یہاں لکھیں',
                    hintStyle: GoogleFonts.vazirmatn(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF02A96C)),
                      onPressed: _sendMessage,
                    ),
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
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
                _buildHelpItem('🎤', 'وائس میں بات کریں'),
                _buildHelpItem('⌨️', 'ٹائپ کر کے پیغام بھیجیں'),
                if (_ttsAvailable) _buildHelpItem('🔊', 'جواب سننے کے لیے سپیکر آئیکن پر کلک کریں'),
                _buildHelpItem('🌾', 'گندم کی بیماریوں کے بارے میں پوچھیں'),
                if (_showTTSIndicator) 
                  _buildHelpItem('🌐', 'اردو آواز کے لیے زبان پیک انسٹال کریں'),
              ],
            ),
          ),
          actions: [
            if (_showTTSIndicator)
              TextButton(
                onPressed: _showUrduInstallGuide,
                child: Text(
                  'اردو انسٹال کریں',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'سمجھ گیا',
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

  Widget _buildHelpItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
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