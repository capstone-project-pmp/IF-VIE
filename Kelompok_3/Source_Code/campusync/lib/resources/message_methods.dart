import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Mengirim pesan dan membuat chat jika belum ada
  static Future<void> sendMessage(String chatId, Message message) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final batch = _firestore.batch();

    try {
      final chatDoc = await chatRef.get();

      // 🔧 Jika chat belum ada, buat dokumen baru
      if (!chatDoc.exists) {
        final ids = chatId.split('_');
        if (ids.length != 2)
          throw Exception("❌ Format chatId tidak valid: $chatId");

        final user1 = ids[0];
        final user2 = ids[1];

        if (user1 == user2)
          throw Exception("❌ Tidak bisa membuat chat dengan diri sendiri.");

        batch.set(chatRef, {
          'users': [user1, user2],
          'lastMessage': message.text,
          'timestamp': Timestamp.now(),
        });
      }

      // 🔄 Tambahkan pesan baru ke subkoleksi 'messages'
      final messageRef = chatRef.collection('messages').doc();
      final messageWithId = Message(
        messageId: messageRef.id,
        senderId: message.senderId,
        text: message.text,
        timestamp: message.timestamp,
        repliedToMessageId: message.repliedToMessageId,
        postData: message.postData,
      );

      batch.set(messageRef, messageWithId.toMap());

      // 🔁 Perbarui info chat
      batch.update(chatRef, {
        'lastMessage': message.text,
        'timestamp': Timestamp.now(),
      });

      await batch.commit();
      print("📨 Message sent successfully.");
    } catch (e) {
      print("🔥 sendMessage Error: $e");
      rethrow;
    }
  }

  /// ✅ Ambil stream daftar pesan dari chat tertentu
  static Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Message.fromFirestore(doc);
            } catch (e) {
              print('⚠️ Gagal parse message ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Message>()
          .toList(); // Hanya ambil yang berhasil
    });
  }

  /// ✅ Hapus pesan berdasarkan ID
  static Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      await messageRef.delete();
      print("🗑️ Pesan berhasil dihapus: $messageId");
    } catch (e) {
      print("⚠️ deleteMessage Error: $e");
      rethrow;
    }
  }
}
