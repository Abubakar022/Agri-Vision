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
  String _currentTTSLocale = "ur-PK";
  bool _showTTSIndicator = false;
  bool _isSpeaking = false;
  Map<String, String> _availableLocales = {};
  double _speechRate = 0.52;
  double _speechPitch = 1.15;
  double _speechVolume = 0.92;
  bool _ttsSettingsVisible = false;
  String _ttsEngineStatus = 'اردو آواز چیک کی جا رہی ہے';

  // Enhanced chatbot responses with natural Urdu
  final Map<String, String> _botResponses = {
    'سلام': 'وعلیکم السلام! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔ براہ کرم اپنے پودوں کی تفصیل بتائیں۔',
    'ہیلو': 'ہیلو جی! خوش آمدید۔ گندم کے کھیت کیسی حالت میں ہے؟ براہ کرم علامات بیان کریں۔',
    'پیلے دھبے': 'پیلے دھبے ... رسٹ بیماری کی علامت ہو سکتے ہیں۔ سفارش ... زینب فنگسائڈ کا سپرے کریں ... اور پانی کا متوازن استعمال کریں۔ تین دن بعد دوبارہ چیک کریں۔',
    'سڑنا': 'سڑنا ... یہ پاؤڈری ملڈیو ہو سکتا ہے۔ کھیت میں ہوا کی گردش بڑھائیں۔ مناسب فنگسائڈ کا استعمال کریں۔ پانی کا چھڑکاؤ کم کریں۔',
    'default': 'میں آپ کی بات سمجھ گیا ہوں۔ براہ کرم مزید تفصیل سے بیان کریں۔ مثلاً ... پتے کیسی ہیں؟ ... کتنے دن ہوئے؟ ... کون سا حصہ متاثر ہے؟'
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
      print("TTS شروع ہو رہا ہے...");
      
      // TTS سیٹنگز
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);
      
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
          await _flutterTts.setSpeechRate(_speechRate);
          await _flutterTts.setPitch(_speechPitch);
          await _flutterTts.setVolume(_speechVolume);
        } else {
          // انگریزی کے لیے سیٹنگز
          await _flutterTts.setSpeechRate(0.48);
          await _flutterTts.setPitch(1.2);
          await _flutterTts.setVolume(0.95);
        }
        
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
        
        print("TTS تیار ہوگیا: $selectedLocale");
      } else {
        print("کوئی مناسب زبان نہیں ملی");
        setState(() {
          _ttsAvailable = false;
          _ttsEngineStatus = 'آواز سروس دستیاب نہیں';
        });
      }
    } catch (e) {
      print("TTS خرابی: $e");
      setState(() {
        _ttsAvailable = false;
        _ttsEngineStatus = 'خرابی: $e';
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
          print("STT خرابی: $error");
          setState(() => _isListening = false);
        },
      );
      print("STT دستیاب: $_sttAvailable");
    } catch (e) {
      print("STT شروع کرنے میں خرابی: $e");
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('پیلے') || lowerMessage.contains('دھبے') || lowerMessage.contains('زرد')) {
      return _botResponses['پیلے دھبے']!;
    } else if (lowerMessage.contains('سڑنا') || lowerMessage.contains('ملڈیو')) {
      return _botResponses['سڑنا']!;
    } else if (lowerMessage.contains('سلام') || lowerMessage.contains('ہیلو')) {
      return _botResponses['سلام']!;
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

      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      // متن کو قدرتی انداز میں بولنے کے لیے تیار کریں
      String processedText = _processTextForNaturalTTS(text);
      
      print("بول رہا ہوں: ${processedText.substring(0, min(50, processedText.length))}...");
      
      await _flutterTts.speak(processedText);
      
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });

      _flutterTts.setErrorHandler((error) {
        print("بولنے میں خرابی: $error");
        setState(() {
          _isSpeaking = false;
        });
      });

    } catch (e) {
      print("TTS خرابی: $e");
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  String _processTextForNaturalTTS(String text) {
    return text
        .replaceAll('۔', '۔ ... ')
        .replaceAll('!', '! ... ')
        .replaceAll('؟', '؟ ... ')
        .replaceAll('،', '، ... ')
        .replaceAll(':', ': ... ')
        .replaceAll(RegExp(r'\s+'), ' ')
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
      print("سننے میں خرابی: $e");
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
      
      if (_ttsAvailable) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _speak(botResponse);
        });
      }
    } catch (e) {
      print("جواب لینے میں خرابی: $e");
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

  void _showTTSInstallGuide() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.volume_up, color: const Color(0xFF02A96C)),
              SizedBox(width: 10),
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
                
                SizedBox(height: 20),
                
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.download, color: Colors.green),
                          title: Text('سب سے آسان طریقہ', 
                            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold)),
                          subtitle: Text('Google TTS انسٹال کریں', 
                            style: GoogleFonts.vazirmatn(fontSize: 12)),
                        ),
                        
                        SizedBox(height: 10),
                        
                        ElevatedButton(
                          onPressed: () => _launchPlayStore("https://play.google.com/store/apps/details?id=com.google.android.tts"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download),
                              SizedBox(width: 8),
                              Text('Google TTS ڈاؤن لوڈ کریں', 
                                style: GoogleFonts.vazirmatn()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  'انسٹال کرنے کے بعد:',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02A96C),
                  ),
                ),
                
                SizedBox(height: 10),
                
                _buildInstallStep('1', 'Google TTS ایپ کھولیں'),
                _buildInstallStep('2', '"زبان ڈاؤن لوڈ کریں" پر کلک کریں'),
                _buildInstallStep('3', '"اردو (پاکستان)" تلاش کریں'),
                _buildInstallStep('4', 'اردو زبان ڈاؤن لوڈ کریں'),
                _buildInstallStep('5', 'آپ کی ایپ دوبارہ شروع کریں'),
                
                SizedBox(height: 20),
                
                Text(
                  'اگر مسئلہ حل نہ ہو تو:',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                
                SizedBox(height: 10),
                
                OutlinedButton.icon(
                  onPressed: () => _openAppSettings(),
                  icon: Icon(Icons.settings),
                  label: Text('سیٹنگز کھولیں', style: GoogleFonts.vazirmatn()),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
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
    await _speak(testPhrase);
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
          icon: Icon(Icons.arrow_back, color: const Color(0xFF02A96C)),
          onPressed: () => Get.back(),
        ),
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
                    offset: Offset(0, 2),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              child: Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
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
                      topLeft: Radius.circular(isUser ? 12 : 0),
                      topRight: Radius.circular(isUser ? 0 : 12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_ttsAvailable && !isUser)
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Icon(
                              _isSpeaking ? Icons.stop : Icons.volume_up,
                              size: 20,
                              color: _currentTTSLocale.contains("ur") 
                                  ? const Color(0xFF02A96C)
                                  : Colors.orange,
                            ),
                            onPressed: () {
                              if (_isSpeaking) {
                                _flutterTts.stop();
                              } else {
                                _speak(message.text);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ),
                      Flexible(
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
                            SizedBox(height: 4),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
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
            child: Icon(Icons.agriculture, color: Colors.white, size: 20),
          ),
          SizedBox(width: 8),
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF02A96C),
                    ),
                  ),
                ),
                SizedBox(width: 12),
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
            
            SizedBox(width: 8),
            
            // Text Input
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
                          hintText: 'اپنا سوال یہاں لکھیں',
                          hintStyle: GoogleFonts.vazirmatn(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    
                    // Send Button
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF02A96C),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
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
              SizedBox(height: 10),
              _buildHelpPoint('🎤', 'بول کر پیغام بھیجیں'),
              _buildHelpPoint('✍️', 'لکھ کر پیغام بھیجیں'),
              _buildHelpPoint('🔊', 'جواب سننے کے لیے سپیکر آئیکن دبائیں'),
              SizedBox(height: 10),
              if (_showTTSIndicator)
                _buildHelpPoint('ℹ️', 'اردو آواز کے لیے TTS انسٹال کریں'),
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
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Text(text, style: GoogleFonts.vazirmatn(fontSize: 14)),
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