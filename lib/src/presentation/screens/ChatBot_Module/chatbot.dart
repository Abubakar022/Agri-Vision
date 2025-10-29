import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// class Chatbot extends StatefulWidget {
//   const Chatbot({super.key});

//   @override
//   State<Chatbot> createState() => _ChatbotState();
// }

// class _ChatbotState extends State<Chatbot> {
//   final List<Map<String, String>> _messages = [
//     {'sender': 'bot', 'text': 'السلام علیکم! میں آپ کی گندم کی بیماری کی تشخیص میں مدد کر سکتا ہوں۔'},
//     {'sender': 'user', 'text': 'میری گندم کے پتوں پر پیلے دھبے ہیں۔'},
//     {'sender': 'bot', 'text': 'ممکن ہے یہ رسٹ (Rust) کی بیماری ہو۔ زینب فنگسائڈ کا سپرے کریں۔'}
//   ];

//   final TextEditingController _controller = TextEditingController();
//   final FlutterTts _flutterTts = FlutterTts();
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   bool _isListening = false;
//   String _spokenText = "";

//   @override
//   void initState() {
//     super.initState();
//     _initTTS();
//   }

//   Future<void> _initTTS() async {
//     await _flutterTts.setLanguage("ur-PK"); // Urdu Pakistan
//     await _flutterTts.setSpeechRate(0.9);
//     await _flutterTts.setPitch(1.0);
//   }

//   Future<void> _speak(String text) async {
//     await _flutterTts.stop();
//     await _flutterTts.speak(text);
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('Status: $val'),
//       onError: (val) => print('Error: $val'),
//     );
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         localeId: "ur-PK",
//         onResult: (val) {
//           setState(() {
//             _spokenText = val.recognizedWords;
//             _controller.text = _spokenText;
//           });
//         },
//       );
//     }
//   }

//   Future<void> _stopListening() async {
//     await _speech.stop();
//     setState(() => _isListening = false);
//   }

//   void _sendMessage() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     setState(() {
//       _messages.add({'sender': 'user', 'text': text});
//       _messages.add({
//         'sender': 'bot',
//         'text': 'یہ صرف ڈیمو پیغام ہے۔ ماڈل بعد میں اصل جواب دے گا۔'
//       });
//     });

//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('اردو چیٹ بوٹ', style: TextStyle(fontFamily: 'NotoNastaliqUrdu')),
//         backgroundColor: Colors.green.shade700,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               padding: const EdgeInsets.all(8),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[_messages.length - 1 - index];
//                 final isUser = msg['sender'] == 'user';
//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: GestureDetector(
//                     onTap: () => _speak(msg['text'] ?? ''),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: isUser ? Colors.green.shade200 : Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         msg['text'] ?? '',
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontFamily: 'NotoNastaliqUrdu',
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           _buildInputArea(),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputArea() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         color: Colors.white,
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textDirection: TextDirection.rtl,
//                 decoration: const InputDecoration(
//                   hintText: 'اپنا پیغام لکھیں...',
//                   border: OutlineInputBorder(borderSide: BorderSide.none),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: Icon(
//                 _isListening ? Icons.mic_off : Icons.mic,
//                 color: _isListening ? Colors.red : Colors.green,
//               ),
//               onPressed: _isListening ? _stopListening : _startListening,
//             ),
//             IconButton(
//               icon: const Icon(Icons.send, color: Colors.green),
//               onPressed: _sendMessage,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
