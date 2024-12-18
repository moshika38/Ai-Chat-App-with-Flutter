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

  // manage massages

  final ScrollController scrollController = ScrollController();

  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', apiKey: dotenv.env['ApiKey'] ?? '');
  bool isTyping = false;

  // get all massage by roomID
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

  // save user massage
  void sendMassage(String userMassage, String roomID,
      List<MassageModel> massagesList) async {
    if (userMassage.isNotEmpty) {
      saveMessage(roomID, userMassage, "user");

      isTyping = true;
      _geminiResponse(userMassage, roomID, massagesList);
      scrollToBottom();
    }
  }

  // gemini response
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

  // clear room massages
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

  // delete room
  Future<void> deleteRoom(String roomID) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Delete the room document itself
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(roomID)
        .delete();

    // Remove roomID from user's document
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'roomID': FieldValue.arrayRemove([roomID]),
    });

   
  }
}
