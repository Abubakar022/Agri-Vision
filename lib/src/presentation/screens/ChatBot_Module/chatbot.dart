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

  // Chatbot responses - Replace with actual API calls
  final Map<String, String> _botResponses = {
    'سلام': 'وعلیکم السلام! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔',
    'ہیلو': 'ہیلو! آپ کا استقبال ہے۔ براہ کرم اپنے گندم کے پودوں کی بیماری کی تفصیل بیان کریں۔',
    'پیلے دھبے': 'پیلے دھبے رسٹ بیماری کی علامت ہو سکتے ہیں۔ سفارش: زینب فنگسائڈ کا سپرے کریں اور پانی کا متوازن استعمال کریں۔',
    'سڑنا': 'یہ پاؤڈری ملڈیو ہو سکتا ہے۔ سفارش: گندم کے کھیتوں میں ہوا کی گردش بڑھائیں اور فنگسائڈ کا استعمال کریں۔',
    'زنگ': 'پتوں کا زنگ ایک عام بیماری ہے۔ سفارش: مزاحمتی اقسام کا استعمال کریں اور وقت پر سپرے کریں۔',
    'گندم': 'گندم کی مختلف بیماریوں میں رسٹ، سنٹ، اور پاؤڈری ملڈیو شامل ہیں۔ براہ کرم مخصوص علامات بیان کریں۔',
    'ایفڈ': 'ایفڈ (Aphids) چھوٹے کیڑے ہیں جو گندم کے پودوں کا رس چوستے ہیں۔ سفارش: مناسب کیڑے مار ادویات کا استعمال کریں۔',
    'کالی زنگ': 'کالی زنگ ایک سنگین بیماری ہے۔ سفارش: مزاحمتی اقسام کاشت کریں اور فنگسائڈ سپرے کریں۔',
    'بلاسٹ': 'بلاسٹ بیماری کے لیے فوری اقدامات کی ضرورت ہوتی ہے۔ سفارش: متاثرہ پودوں کو الگ کریں۔',
    'بھوری زنگ': 'بھوری زنگ کے خلاف قوت مدافعت رکھنے والی اقسام استعمال کریں۔',
    'فیوزیریم ہیڈ بلائٹ': 'فیوزیریم ہیڈ بلائٹ کے لیے صحت مند بیج استعمال کریں۔',
    'پتوں کا بلائٹ': 'پتوں کے بلائٹ کے خلاف باقاعدہ سپرے پروگرام اپنائیں۔',
    'پھپھوندی (ملڈیو)': 'پھپھوندی کے خلاف مناسب ہوا کی گردش ضروری ہے۔',
    'مائٹ': 'مائٹ کے خلاف مخصوص ایکارائسائڈز استعمال کریں۔',
    'سیپٹوریا': 'سیپٹوریا کے خلاف متوازن کھاد کا استعمال کریں۔',
    'کھنڈ بیماری (سماٹ)': 'کھنڈ بیماری کے لیے صاف ستھری کاشتکاری اپنائیں۔',
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
      _scrollToBottom(); // Scroll to bottom when chat loads to show greeting
      
      // Send initial message after a short delay if provided
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
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSpeakCompletion(true);
      
      // Try multiple Urdu locales
      final List<String> urduLocales = ["ur-PK", "ur-IN", "ur"];
      for (String locale in urduLocales) {
        if (await _flutterTts.isLanguageAvailable(locale)) {
          await _flutterTts.setLanguage(locale);
          print("TTS set to: $locale");
          break;
        }
      }
      
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
    } catch (e) {
      print("TTS Initialization Error: $e");
    }
  }

  Future<void> _initSTT() async {
    try {
      _sttAvailable = await _speech.initialize(
        onStatus: (status) {
          print('STT Status: $status');
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('STT Error: $error');
          setState(() => _isListening = false);
        },
      );
      setState(() {});
    } catch (e) {
      print("STT Initialization Error: $e");
    }
  }

  // Permission check method
  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  // Simulate API call - Replace with your actual API
  Future<String> _getBotResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
    
    // Simple response logic - Replace with your AI model integration
    final lowerMessage = userMessage.toLowerCase();
    
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
      return _botResponses['فیوزیریم ہیڈ بلائٹ']!;
    } else if (lowerMessage.contains('پتوں') && lowerMessage.contains('بلائٹ')) {
      return _botResponses['پتوں کا بلائٹ']!;
    } else if (lowerMessage.contains('پھپھوندی') || lowerMessage.contains('ملڈیو')) {
      return _botResponses['پھپھوندی (ملڈیو)']!;
    } else if (lowerMessage.contains('مائٹ')) {
      return _botResponses['مائٹ']!;
    } else if (lowerMessage.contains('سیپٹوریا')) {
      return _botResponses['سیپٹوریا']!;
    } else if (lowerMessage.contains('کھنڈ') || lowerMessage.contains('سماٹ')) {
      return _botResponses['کھنڈ بیماری (سماٹ)']!;
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
    try {
      if (text.isNotEmpty) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  // Updated _startListening method with permission check
  void _startListening() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      if (mounted) {
        Get.snackbar(
          'اجازت درکار',
          'مائیکروفون کی اجازت درکار ہے',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }

    if (!_sttAvailable) {
      print("STT not available");
      return;
    }

    try {
      setState(() => _isListening = true);
      _spokenText = "";
      _controller.clear(); // Clear text field when starting to listen
      
      await _speech.listen(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
            _controller.text = _spokenText;
          });
        },
        cancelOnError: true,
        partialResults: true,
        localeId: "ur-PK",
      );
    } catch (e) {
      print("Listening Error: $e");
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    try {
      _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      print("Stop Listening Error: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user message
    final userMessage = Message(
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage); // Add to end of list
      _isLoading = true;
    });
    
    _controller.clear(); // Clear the text field after sending
    _scrollToBottom();

    try {
      // Get bot response
      final botResponse = await _getBotResponse(text);
      
      final botMessage = Message(
        text: botResponse,
        sender: 'bot',
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(botMessage); // Add to end of list
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      print("API Error: $e");
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
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E3), // Same as CropScanScreen
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8E3),
        elevation: 0,
        
        title: Text(
          'گندم کی بیماریوں کی معلومات',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF02A96C),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF02A96C)),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  reverse: false,
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
              decoration: const BoxDecoration(
                color: Color(0xFF02A96C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 18),
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
                      if (!isUser) 
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18, color: Color(0xFF02A96C)),
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
                      if (isUser)
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18, color: Colors.white),
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
              decoration: const BoxDecoration(
                color: Color(0xFFFFA726),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF02A96C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: const Color(0xFF02A96C).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF02A96C),
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
            // Mic Button
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
            
            // Text Field
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem('🎤', 'وائس میں بات کریں'),
                _buildHelpItem('⌨️', 'ٹائپ کر کے پیغام بھیجیں'),
                _buildHelpItem('🔊', 'جواب سننے کے لیے سپیکر آئیکن پر کلک کریں'),
                _buildHelpItem('🌾', 'گندم کی بیماریوں کے بارے میں پوچھیں'),
                _buildHelpItem('📱', 'آواز کے لیے مائیکروفون کی اجازت دیں'),
                _buildHelpItem('💬', 'صاف اور مختصر پیغام لکھیں'),
              ],
            ),
          ),
          actions: [
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
              overflow: TextOverflow.visible,
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