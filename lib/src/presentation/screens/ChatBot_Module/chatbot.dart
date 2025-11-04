import 'package:agri_vision/src/presentation/AppConstant/Colors.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'text': 'السلام علیکم! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔'},
    {'sender': 'user', 'text': 'میری گندم کے پتوں پر پیلے دھبے ہیں۔'},
    {'sender': 'bot', 'text': 'ممکن ہے یہ رسٹ (Rust) کی بیماری ہو۔ زینب فنگسائڈ کا سپرے کریں۔'}
  ];

  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _spokenText = "";
  bool _sttAvailable = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSTT();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("ur-PK");
   await _flutterTts.setSpeechRate(0.5); // slower, 0.0 to 1.0
  await _flutterTts.setPitch(1.0); 
  }

  Future<void> _initSTT() async {
    _sttAvailable = await _speech.initialize(
      onStatus: (val) => print('STT Status: $val'),
      onError: (val) => print('STT Error: $val'),
    );
    setState(() {}); // to refresh mic button state
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  void _startListening() {
    if (!_sttAvailable) return;
    setState(() => _isListening = true);
    _speech.listen(
      localeId: "ur-PK",
      onResult: (val) {
        setState(() {
          _spokenText = val.recognizedWords;
          _controller.text = _spokenText;
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messages.add({
        'sender': 'bot',
        'text': 'یہ صرف ڈیمو پیغام ہے۔ ماڈل بعد میں اصل جواب دے گا۔'
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
  backgroundColor: Appcolor.green,
  title: Align(
    alignment: Alignment.centerRight, // aligns text to the right
    child: Text(
      'اردو چیٹ بوٹ',
      style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
    ),
  ),
  automaticallyImplyLeading: false, // optional, removes back button if not needed
),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            msg['text'] ?? '',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.vazirmatn(fontSize: 16),
                          ),
                        ),
                        if (!isUser) ...[
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.green),
                            onPressed: () => _speak(msg['text'] ?? ''),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

Widget _buildInputArea() {
  return SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اپنا پیغام لکھیں...',
                hintStyle: GoogleFonts.vazirmatn(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Appcolor.green, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Appcolor.green, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_off : Icons.mic,
              color: _isListening ? Colors.red : Appcolor.green,
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Appcolor.green),
            onPressed: _sendMessage,
          ),
        ],
      ),
    ),
  );
}

}
