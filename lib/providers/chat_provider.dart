import 'package:ai_chat_app/models/massege_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatProvider extends ChangeNotifier {
  Future<String> createRoom() async {
    final newRoom =
        await FirebaseFirestore.instance.collection('ChatRoom').add({});
    final id = FirebaseAuth.instance.currentUser?.uid;

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(id);

    await userDoc.update({
      'roomID': FieldValue.arrayUnion([newRoom.id]),
    });

    return newRoom.id;
  }

  Future<String?> getLastRoomId() async {
    final id = FirebaseAuth.instance.currentUser?.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

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
      notifyListeners();
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
      notifyListeners();
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
      notifyListeners();
    }
  }

  bool isDel = false;
  Future<void> deleteRoom(String roomID) async {
    isDel = true;
    notifyListeners();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      // Delete the chats in the sub-collection
      final messagesCollection = FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(roomID)
          .collection('Messages');

      final messagesSnapshot = await messagesCollection.get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the room document
      await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(roomID)
          .delete();

      // Remove room ID from user's document
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'roomID': FieldValue.arrayRemove([roomID]),
        });
      }

      // Verify and clean up if room document still exists
      final roomDoc = await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(roomID)
          .get();

      if (roomDoc.exists) {
        await FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(roomID)
            .delete();
      }

      // Notify listeners if using Provider or similar state management
      isDel = false;
      notifyListeners();
    } catch (e) {
      isDel = false;
      notifyListeners();
      print('Error deleting room and its messages: $e');
    }
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

  Future<List<MassageModel>> getAllMassagesRelevantIDs(dynamic roomIDs) async {
    List<MassageModel> messages = [];

    if (roomIDs is String) {
      roomIDs = [roomIDs];
    }

    for (String roomID in roomIDs) {
      final snapshot = await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(roomID)
          .collection('messages')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final message = MassageModel.fromJson(snapshot.docs.first.data());
        messages.add(message);
      }
    }

    return messages;
  }
}
