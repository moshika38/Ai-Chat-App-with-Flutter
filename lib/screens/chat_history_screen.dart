import 'package:ai_chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_app/constants/colors.dart';
import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.iconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.circleBackground,
        title: const Text(
          'Chat History',
          style: TextStyle(color: AppColors.primaryText),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (BuildContext context, ChatProvider chatProvider, child) =>
            FutureBuilder<List<String>>(
          future: chatProvider.getAllRooms(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final rooms = snapshot.data!;
              return ListView.builder(
                itemCount: rooms.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: chatProvider.getLastMassage(rooms[index]),
                    builder: (context, messageSnapshot) {
                      return HistoryCard(
                        index: index,
                        lastMassage: messageSnapshot.data ?? '',
                        roomID: rooms[index],
                      );
                    },
                  );
                },
              );
            }
            return const Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final int index;
  final String lastMassage;
  final String roomID;
  const HistoryCard({
    super.key,
    required this.index,
    required this.lastMassage,
    required this.roomID,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              loadedRoomID: roomID,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.containerOverlay,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat ${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMassage,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Consumer(
                  builder: (BuildContext context, ChatProvider chatProvider,
                          child) =>
                      TextButton(
                    onPressed: () {
                      chatProvider.deleteRoom(roomID);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Text(
                  '2h ago',
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
