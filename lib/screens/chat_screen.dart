import 'package:ai_chat_app/models/massege_model.dart';
import 'package:ai_chat_app/widgets/app_bar_title.dart';
import 'package:ai_chat_app/widgets/bottom_sheet.dart';
import 'package:ai_chat_app/widgets/type_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MassageModel> massagesList = [];
  TextEditingController userMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', apiKey: dotenv.env['ApiKey'] ?? '');
  bool isTyping = false;

  void _sendMassage() {
    if (userMessage.text.isNotEmpty) {
      final data = MassageModel(
        id: "0",
        massage: userMessage.text,
        author: "user",
        time: DateTime.now().toString(),
      );
      setState(() {
        massagesList.add(data);
        isTyping = true;
      });
      _geminiResponse(userMessage.text);
      _scrollToBottom();
      userMessage.clear();
    }
  }

  void _geminiResponse(String userText) async {
    final content = [Content.text(userText)];
    final response = await model.generateContent(content);
    if (response.text != "") {
      final botData = MassageModel(
        id: "0",
        massage: response.text.toString(),
        author: "bot",
        time: DateTime.now().toString(),
      );
      setState(() {
        massagesList.add(botData);
        isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17203A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppBarTitle(
          isTyping: isTyping,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: AppBottomSheet(context: context).showOptionsDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2A3E84),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: massagesList.length,
                  itemBuilder: (context, index) {
                    final massage = massagesList[index];
                    if (massage.author == "user") {
                      return _buildUserMessage(massage.massage, massage.time);
                    } else {
                      return _buildAIMessage(massage.massage, massage.time);
                    }
                  },
                ),
              ),
              TypeBar(
                controller: userMessage,
                onTap: () {
                  _sendMassage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(right: 50, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ),
            // massage time
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                time.split(" ")[1].split(".")[0],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ).copyWith(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, bottom: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            // massage time
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                time.split(" ")[1].split(".")[0],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ).copyWith(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
