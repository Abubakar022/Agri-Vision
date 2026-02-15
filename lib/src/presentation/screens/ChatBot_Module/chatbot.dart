import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
  String _ttsEngineStatus = 'اردو آواز چیک کی جا رہی ہے';
  Message? _currentlySpeakingMessage;

  // ✅ WORKING API ENDPOINT - REPLACED THE DUMMY LINK
  final String _apiEndpoint = 'https://wheat-bot-multi-1075549714370.us-central1.run.app/ask';

  // Local fallback responses (only used when API fails)
  final Map<String, Map<String, dynamic>> _fallbackResponses = {
    'پیلے دھبے': {
      'response':
          'پیلے دھبے رسٹ کی بیماری کی علامت ہیں۔ سفارش: زینب فنگسائڈ کا سپرے کریں اور پانی کا متوازن استعمال کریں۔ تین دن بعد دوبارہ چیک کریں۔',
      'disease_name': 'رسٹ (Rust)',
    },
    'سڑنا': {
      'response':
          'سڑنا پاؤڈری ملڈیو ہو سکتا ہے۔ کھیت میں ہوا کی گردش بڑھائیں۔ مناسب فنگسائڈ کا استعمال کریں۔ پانی کا چھڑکاؤ کم کریں۔',
      'disease_name': 'پاؤڈری ملڈیو (Powdery Mildew)',
    },
    'سیاہ دھبے': {
      'response':
          'سیاہ دھبے ٹیلے سنٹ کی بیماری کی علامت ہیں۔ پودوں کو الگ کریں اور کاربندازیم سپرے کریں۔',
      'disease_name': 'ٹیلے سنٹ (Tilletia)',
    },
    'جھلساؤ': {
      'response':
          'جھلساؤ کیلشیئم کی کمی کی علامت ہو سکتا ہے۔ کیلشیئم نائٹریٹ کا استعمال کریں اور پانی کا شیڈول بہتر کریں۔',
      'disease_name': 'کیلشیئم کی کمی (Calcium Deficiency)',
    },
    'سفوف نما تہ': {
      'response':
          'سفوف نما تہ پاؤڈری ملڈیو کی واضح علامت ہے۔ سلفر سپرے کریں اور کھیت کی صفائی کریں۔',
      'disease_name': 'پاؤڈری ملڈیو (Powdery Mildew)',
    },
    'default': {
      'response':
          'میں آپ کی بات سمجھ گیا ہوں۔ براہ کرم مزید تفصیل سے بیان کریں۔ مثلاً: پتے کیسی ہیں؟ کتنے دن ہوئے؟ کون سا حصہ متاثر ہے؟',
      'disease_name': 'نامعلوم',
    }
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingMessage = null;
          });
        }
      });

      _flutterTts.setErrorHandler((error) {
        print("بولنے میں خرابی: $error");
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingMessage = null;
          });
        }
      });

      final languages = await _flutterTts.getLanguages;
      _availableLocales.clear();
      for (var locale in languages) {
        _availableLocales[locale] = locale;
      }

      String? selectedLocale;
      if (_availableLocales.containsKey("ur-PK")) {
        selectedLocale = "ur-PK";
      } else if (_availableLocales.containsKey("ur")) {
        selectedLocale = "ur";
      } else if (_availableLocales.containsKey("ur_IN")) {
        selectedLocale = "ur_IN";
      } else if (_availableLocales.containsKey("ar_SA")) {
        selectedLocale = "ar_SA";
      } else if (_availableLocales.containsKey("en_US")) {
        selectedLocale = "en_US";
      }

      if (selectedLocale != null) {
        await _flutterTts.setLanguage(selectedLocale);
        
        if (selectedLocale.contains("ur") || selectedLocale.contains("ar")) {
          await _flutterTts.setSpeechRate(0.45);
          await _flutterTts.setPitch(1.0);
          await _flutterTts.setVolume(0.9);
        } else {
          await _flutterTts.setSpeechRate(0.48);
          await _flutterTts.setPitch(1.2);
          await _flutterTts.setVolume(0.95);
        }

        if (mounted) {
          setState(() {
            _ttsAvailable = true;
            _currentTTSLocale = selectedLocale!;
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
      } else {
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
    } catch (e) {
      print("STT شروع کرنے میں خرابی: $e");
    }
  }

  // ✅ UPDATED API CALL WITH PROPER ERROR HANDLING
  Future<Map<String, dynamic>> _getBotResponseFromAPI(String userMessage) async {
    try {
      print('📡 Calling API: $_apiEndpoint');
      print('📝 Question: $userMessage');

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': userMessage,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? 'جواب نہیں ملا';
        
        return {
          'display_text': answer,
          'from_api': true
        };
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      
      // Simple fallback - just return a generic response
      return {
        'display_text': 'معذرت، میں فی الحال سرور سے منسلک نہیں ہو سکا۔ براہ کرم کچھ دیر بعد دوبارہ کوشش کریں۔',
        'from_api': false,
        'error': true
      };
    }
  }

  Future<Map<String, dynamic>> _getBotResponse(String userMessage) async {
    return await _getBotResponseFromAPI(userMessage);
  }

  Future<void> _speak(String text, Message? message) async {
    if (!_ttsAvailable || _isSpeaking || !mounted) return;

    try {
      setState(() {
        _isSpeaking = true;
        _currentlySpeakingMessage = message;
      });

      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      String processedText = text
          .replaceAll('۔', '۔ ... ')
          .replaceAll('!', '! ... ')
          .replaceAll('؟', '؟ ... ')
          .replaceAll('،', '، ... ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

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

  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessage = null;
        });
      }
    } catch (e) {
      print("روکنے میں خرابی: $e");
    }
  }

  void _toggleSpeech(String text, Message? message) {
    if (_isSpeaking) {
      _stopSpeaking();
    } else {
      _speak(text, message);
    }
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
      Get.snackbar(
        'اجازت درکار',
        'مائیکروفون کی اجازت درکار ہے',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_sttAvailable) {
      Get.snackbar(
        'سروس دستیاب نہیں',
        'وائس ریکگنیشن دستیاب نہیں',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (mounted) setState(() => _isListening = true);
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
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    try {
      _speech.stop();
      if (mounted) setState(() => _isListening = false);
    } catch (e) {
      if (mounted) setState(() => _isListening = false);
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
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
        });
      }

      _scrollToBottom();

      if (_ttsAvailable) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _speak(botResponse, botMessage);
        });
      }
    } catch (e) {
      print("جواب لینے میں خرابی: $e");
      if (mounted) setState(() => _isLoading = false);
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

  bool _isUrduText(String text) {
    if (text.trim().isEmpty) return true;
    final urduRegex = RegExp(r'^[\u0600-\u06FF\s\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF.,،؛!؟:()\-0-9]+$');
    return urduRegex.hasMatch(text);
  }

  String _filterEnglish(String text) {
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
                    const SizedBox(width: 8),
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
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == 'user';
    final isSpeakingThisMessage = _currentlySpeakingMessage == message && _isSpeaking;

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
              child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
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
                            onPressed: () => _toggleSpeech(message.text, message),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ),
                      Flexible(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isSpeakingThisMessage)
                                Row(
                                  children: [
                                    _buildSoundWave(),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  message.text,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 14,
                                    color: isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  _formatTime(message.timestamp),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
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
        children: List.generate(5, (index) {
          return Container(
            width: 3,
            height: _isSpeaking ? Random().nextInt(15) + 5 : 5,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
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
                          if (mounted) setState(() {});
                        },
                        onSubmitted: (value) {
                          if (_isUrduText(value)) _sendMessage();
                        },
                      ),
                    ),
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

    if (difference.inMinutes < 1) return 'ابھی';
    if (difference.inMinutes < 60) return '${difference.inMinutes} منٹ پہلے';
    return '${difference.inHours} گھنٹے پہلے';
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
              const SizedBox(height: 10),
              Text(
                'پوچھی جانے والی بیماریاں:',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              _buildHelpPoint('•', 'زرد کنگی، بھوری کنگی'),
              _buildHelpPoint('•', 'کالی کنگی، کانگیاری'),
              _buildHelpPoint('•', 'سست تیلہ، تنے کی مکھی'),
              _buildHelpPoint('•', 'سفوفی پھپھوندی، جوئیں'),
              _buildHelpPoint('•', 'گندم کا بلاسٹ، ٹین سپاٹ'),
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
      ),
    );
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
                          leading: const Icon(Icons.download, color: Colors.green),
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
      if (await canLaunch(url)) await launch(url);
    } catch (e) {
      print("Play Store کھولنے میں خرابی: $e");
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

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}