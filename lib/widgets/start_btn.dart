import 'package:flutter/material.dart';

class StartBtn extends StatelessWidget {
  final VoidCallback onPress;
  final bool load;
  const StartBtn({
    super.key,
    required  this.onPress,
    required  this.load,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          width: 200,
          height: 60,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child:   Center(
              child: Text(
            load?"Starting...":"Start Chat",
            style: const TextStyle(color: Colors.white),
          )),
        ),
      ),
    );
  }
}
