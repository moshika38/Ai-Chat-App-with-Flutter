import 'package:ai_chat_app/models/massege_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (userDoc.exists) {
      List<dynamic> roomIDs = userDoc.get('roomID') ?? [];
      if (roomIDs.isEmpty) {
        await createRoom();
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        List<dynamic> roomIDs = userDoc.get('roomID') ?? [];

        return roomIDs.isNotEmpty ? roomIDs.last : null;
      }
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

  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', apiKey: dotenv.env['ApiKey'] ?? '');
  bool isTyping = false;

  Stream<List<MassageModel>> getAllMessages(String roomID) {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(roomID)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MassageModel.fromJson(doc.data()))
          .toList();

      return messages;
    });
  }

  void sendMassage(String userMassage, String roomID,
      List<MassageModel> massagesList) async {
    if (userMassage.isNotEmpty) {
      saveMessage(roomID, userMassage, "user");

      isTyping = true;
      _geminiResponse(userMassage, roomID, massagesList);
    }
  }

  void _geminiResponse(
      String userText, String roomID, List<MassageModel> massagesList) async {
    String conversationHistory = massagesList.map((msg) {
      return "${msg.author}: ${msg.massage}";
    }).join('\n');

    final content = [
      Content.text(conversationHistory),
      Content.text("user: $userText")
    ];
    final response = await model.generateContent(content);
    if (response.text != "") {
      saveMessage(roomID, response.text.toString(), "bot");

      isTyping = false;
    }
  }

  Future<void> clearRoomMessages(String roomID) {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(roomID)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> deleteRoom(String roomID) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(roomID)
        .delete();

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'roomID': FieldValue.arrayRemove([roomID]),
    });
    notifyListeners();
  }

  Future<List<String>> getAllRooms() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      List<dynamic> roomIDs = userDoc.get('roomID') ?? [];
      return roomIDs.cast<String>().reversed.toList();
    }
    return [];
  }

  Future<String> getLastMassage(String roomID) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(roomID)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final message = MassageModel.fromJson(snapshot.docs.first.data());
      return message.massage;
    } else {
      return '';
    }
  }
}
