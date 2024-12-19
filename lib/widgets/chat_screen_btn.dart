import 'package:ai_chat_app/constants/colors.dart';
import 'package:flutter/material.dart';

class ChatScreenBtn extends StatelessWidget {
  final VoidCallback onTap;
   const ChatScreenBtn({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          height: 60,
          child: Container(
            width: 160,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_comment_outlined, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "New Chat",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
