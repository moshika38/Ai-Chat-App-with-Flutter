<<<<<<< HEAD
import 'package:ai_chat_app/providers/chat_provider.dart';
import 'package:ai_chat_app/providers/user_provider.dart';
import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:ai_chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
=======
import 'package:flutter/material.dart';
import 'package:ai_chat_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
=======
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  runApp(const MyApp());
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          secondary: const Color(0xFF03DAC5),
          background: const Color(0xFFF5F5F7),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
<<<<<<< HEAD
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const ChatScreen(),
=======
      home: const LoginScreen(),
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
    );
  }
}
