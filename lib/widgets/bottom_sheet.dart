import 'package:ai_chat_app/constants/colors.dart';
import 'package:ai_chat_app/providers/chat_provider.dart';
import 'package:ai_chat_app/screens/chat_history_screen.dart';
import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBottomSheet {
  final BuildContext context;
  final String roomID;

  AppBottomSheet({
    required this.context,
    required this.roomID,
  });

  void showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (context, ChatProvider chatProvider, child) =>
                  _buildOptionTile(
                icon: Icons.add_comment_rounded,
                title: 'New Chat',
                onTap: () async {
                  await chatProvider.createRoom();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            _buildOptionTile(
              icon: Icons.history_rounded,
              title: 'Chat History',
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatHistoryScreen()),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Chat',
              onTap: () {
                Navigator.pop(context);
                _showClearChatDialog();
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_rounded,
              title: 'Delete Chat',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _showDeleteChatDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17203A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: 10, // Replace with actual chat history
                itemBuilder: (context, index) => _buildHistoryTile(
                  'Chat ${index + 1}',
                  'Last message from chat ${index + 1}',
                  DateTime.now().subtract(Duration(days: index)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String subtitle, DateTime time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: Text(
          '${time.hour}:${time.minute}',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        onTap: () {
          // Implement chat history selection
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17203A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear this chat?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (BuildContext context, ChatProvider chatProvider, child) =>
                TextButton(
              onPressed: () async {
                if (roomID.isNotEmpty) {
                  await chatProvider.clearRoomMessages(roomID);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17203A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (BuildContext context, ChatProvider chatProvider, child) =>
                TextButton(
              onPressed: () async {
                if (roomID.isNotEmpty) {
                  await chatProvider.deleteRoom(roomID);
                }
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(),
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
