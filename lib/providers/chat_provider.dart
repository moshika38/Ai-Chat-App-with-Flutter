import 'package:ai_chat_app/models/massege_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {



  Future<void> createRoom() async {
    final newRoom =
        await FirebaseFirestore.instance.collection('ChatRoom').add({});

    final id = FirebaseAuth.instance.currentUser?.uid;

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(id);

    await userDoc.update({
      'roomID': FieldValue.arrayUnion([newRoom.id]),
    });
    notifyListeners();
  }

Future<String?> getLastRoomId() async {
    final id = FirebaseAuth.instance.currentUser?.uid;
    
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();

    if (userDoc.exists) {
      List<dynamic> roomIDs = userDoc.get('roomID') ?? [];
      return roomIDs.isNotEmpty ? roomIDs.last : null;
    }
    return null;
  }






  Future<void> saveMessage(
      String chatRoomId, String massage, String author) async {
    try {
      final data = MassageModel(
        massage: massage,
        author: author,
        time: DateTime.now().toString(),
      );

      CollectionReference chatRoom =
          FirebaseFirestore.instance.collection('ChatRoom');

      CollectionReference messages =
          chatRoom.doc(chatRoomId).collection('messages');

      DocumentReference docRef = await messages.add(data.toJson());

      print(
          'Message saved successfully in ChatRoom $chatRoomId with ID: ${docRef.id}');
    } catch (e) {
      print('Error saving message: $e');
    }
  }
}
