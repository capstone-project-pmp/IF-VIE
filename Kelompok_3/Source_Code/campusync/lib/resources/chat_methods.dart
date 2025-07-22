import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Fungsi untuk membuat chat baru jika belum ada
  Future<void> createChat(String userId1, String userId2) async {
    final chatId = _getChatId(userId1, userId2);

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'users': [userId1, userId2],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Chat created with ID: $chatId");
    } else {
      // Validasi: pastikan tetap 2 user
      final data = chatDoc.data() as Map<String, dynamic>;
      if (!(data['users'] is List) || (data['users'] as List).length != 2) {
        await chatRef.update({
          'users': [userId1, userId2],
        });
        print("⚠️ Chat users repaired for ID: $chatId");
      } else {
        print("ℹ️ Chat already exists: $chatId");
      }
    }
  }

  /// ✅ Fungsi untuk mengirim pesan
  Future<void> sendMessage(
      String chatId, String senderId, String messageText) async {
    try {
      // Pastikan ID lawan bicara bisa ditemukan
      final otherUserId = chatId
          .split('_')
          .firstWhere((id) => id != senderId, orElse: () => '');

      if (otherUserId.isEmpty) {
        print("❌ Invalid chatId: $chatId (can't find other user)");
        return;
      }

      // Pastikan chat ada dan valid
      await createChat(senderId, otherUserId);

      final messagesRef =
          _firestore.collection('chats').doc(chatId).collection('messages');

      await messagesRef.add({
        'senderId': senderId,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      // Update lastMessage dan timestamp
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("📩 Message sent in chat: $chatId");
    } catch (e) {
      print("🔥 sendMessage Error: $e");
    }
  }

  /// ✅ Buat chatId konsisten berdasarkan UID user
  String _getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return sorted.join('_');
  }
}
