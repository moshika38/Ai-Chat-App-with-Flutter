import 'package:ai_chat_app/models/user_model.dart';
import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:ai_chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  bool isLoading = false;

  // create user account
  Future<void> createUser(
      String email, String pass, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (credential.user != null) {
        createCollection();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong!'),
          ),
        );
      }
      isLoading = false;
      notifyListeners();
    }
  }

  // login user
  bool isLogin = false;
  Future<void> loginUser(
      String email, String pass, BuildContext context) async {
    isLogin = true;
    notifyListeners();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      if (credential.user != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        }
      }
      isLogin = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      isLogin = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Something went wrong!'),
          ),
        );
      }
    }
  }

  // create new user collection

  Future<void> createCollection() async {
    final id = FirebaseAuth.instance.currentUser?.uid;

    final docRef = FirebaseFirestore.instance.collection('users').doc(id);

    // Check if the document already exists
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // If it doesn't exist, create a new document
      final data = UserModel(id: id.toString(), roomID: <String>[]);
      await docRef.set(data.toJson());
      print('User document created successfully.');
    } else {
      print('User document already exists.');
    }
  }

  // user logout
  Future<void> userLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }
}
