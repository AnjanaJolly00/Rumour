import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumour/models/message_model.dart' show Message;

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to messages subcollection
  CollectionReference messagesRef(String roomCode) {
    return _firestore
        .collection('rooms')
        .doc(roomCode.toUpperCase())
        .collection('messages');
  }

  // Send a message
  Future<void> sendMessage({
    required String roomCode,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String text,
  }) async {
    try {
      await messagesRef(roomCode).add({
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Load initial messages — last 20
  Future<List<Message>> loadInitialMessages(String roomCode) async {
    try {
      final snapshot = await messagesRef(
        roomCode,
      ).orderBy('timestamp', descending: true).limit(20).get();

      return snapshot.docs
          .map((doc) => Message.fromDocument(doc))
          .toList()
          .reversed
          .toList(); // reverse so oldest is at top
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Load older messages for pagination
  Future<List<Message>> loadMoreMessages({
    required String roomCode,
    required DocumentSnapshot lastDocument,
  }) async {
    try {
      final snapshot = await messagesRef(roomCode)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Message.fromDocument(doc))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to load more messages: $e');
    }
  }

  // Realtime stream — only listens for NEW messages after initial load
  Stream<List<Message>> newMessagesStream({
    required String roomCode,
    required DateTime after,
  }) {
    return messagesRef(roomCode)
        .orderBy('timestamp', descending: false)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(after))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromDocument(doc)).toList(),
        );
  }
}
