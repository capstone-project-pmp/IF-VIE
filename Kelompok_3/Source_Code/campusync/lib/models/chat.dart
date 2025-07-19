import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String participantUsername;
  final String participantImageUrl;
  final String lastMessage;
  final Timestamp timestamp;

  Chat({
    required this.chatId,
    required this.participantUsername,
    required this.participantImageUrl,
    required this.lastMessage,
    required this.timestamp,
  });

  // Factory method untuk membuat objek Chat dari Firestore document
  factory Chat.fromDocument(DocumentSnapshot doc) {
    // Mengambil data dari dokumen Firestore dan memberikan nilai default jika ada field yang tidak ditemukan
    final data = doc.data() as Map<String, dynamic>;

    return Chat(
      chatId: doc.id, // Menggunakan ID dokumen sebagai chatId
      participantUsername:
          data['username'] ?? 'Unknown User', // Default jika username tidak ada
      participantImageUrl:
          data['photoUrl'] ?? '', // Default kosong jika photoUrl tidak ada
      lastMessage: data['lastMessage'] ??
          'No message yet', // Default jika lastMessage tidak ada
      timestamp: data['timestamp'] ??
          Timestamp
              .now(), // Pastikan timestamp ada, jika tidak, fallback ke now
    );
  }
}
