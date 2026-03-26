import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if a room exists in Firestore
  Future<bool> roomExists(String roomCode) async {
    try {
      final doc = await _firestore
          .collection('rooms')
          .doc(roomCode.toUpperCase())
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check room: $e');
    }
  }

  // Create a new room in Firestore
  Future<void> createRoom(String roomCode) async {
    try {
      await _firestore.collection('rooms').doc(roomCode.toUpperCase()).set({
        'roomCode': roomCode.toUpperCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
      });
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  // Increment member count when someone joins
  Future<void> incrementMemberCount(String roomCode) async {
    try {
      await _firestore.collection('rooms').doc(roomCode.toUpperCase()).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to update member count: $e');
    }
  }

  // Get room details as a stream (realtime member count)
  Stream<DocumentSnapshot> roomStream(String roomCode) {
    return _firestore
        .collection('rooms')
        .doc(roomCode.toUpperCase())
        .snapshots();
  }

  // Generate a random 6 character room code
  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = List.generate(
      6,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    );
    return random.join();
  }
}
