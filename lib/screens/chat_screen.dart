import 'package:ai_chat_app/models/massege_model.dart';
import 'package:ai_chat_app/providers/chat_provider.dart';
import 'package:ai_chat_app/providers/user_provider.dart';
import 'package:ai_chat_app/widgets/app_bar_title.dart';
import 'package:ai_chat_app/widgets/bottom_sheet.dart';
import 'package:ai_chat_app/widgets/type_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController userMessage = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', apiKey: dotenv.env['ApiKey'] ?? '');
  bool isTyping = false;
  List<MassageModel> massagesList = [];

  void sendMassage(String userMassage) async {
    if (userMassage.isNotEmpty) {
      final data = MassageModel(
        massage: userMassage,
        author: "user",
        time: DateTime.now().toString(),
      );

      massagesList.add(data);
      isTyping = true;
      setState(() {});
      _geminiResponse(userMassage);
      scrollToBottom();
    }
  }

  void _geminiResponse(String userText) async {
    String conversationHistory = massagesList.map((msg) {
      return "${msg.author}: ${msg.massage}";
    }).join('\n');
    final content = [
      Content.text(conversationHistory),
      Content.text("user: $userText")
    ];
    final response = await model.generateContent(content);
    if (response.text != "") {
      final botData = MassageModel(
        massage: response.text.toString(),
        author: "bot",
        time: DateTime.now().toString(),
      );
      massagesList.add(botData);

      isTyping = false;
      setState(() {});
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2(
      builder: (BuildContext context, ChatProvider chatProvider,
              UserProvider userProvider, child) =>
          Scaffold(
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
            FutureBuilder(
              future: Future.wait([
                chatProvider.getLastRoomId(),
                userProvider.createCollection(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data as List;
                  final lastRoomID = data[0];
                  
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          itemCount: massagesList.length,
                          itemBuilder: (context, index) {
                            final massage = massagesList[index];
                            if (massage.author == "user") {
                              return _buildUserMessage(
                                massage.massage,
                                massage.time,
                              );
                            } else {
                              return _buildAIMessage(
                                massage.massage,
                                massage.time,
                              );
                            }
                          },
                        ),
                      ),
                      TypeBar(
                        controller: userMessage,
                        onTap: () {
                          sendMassage(userMessage.text);
                          chatProvider.saveMessage(
                              lastRoomID.toString(), userMessage.text, "user");
                          userMessage.clear();
                          scrollToBottom();
                        },
                      ),
                    ],
                  );
                }
                return Center(
                  child: Text(
                    'Updating data...',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
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
