// Jalankan script ini sekali untuk membersihkan data yang tidak konsisten
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDataMigration {
  static Future<void> standardizeChats() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Ambil semua chat documents
      final chatsSnapshot = await firestore.collection('chats').get();

      final batch = firestore.batch();

      for (var doc in chatsSnapshot.docs) {
        final data = doc.data();
        final chatRef = doc.reference;

        // Standardisasi timestamp field
        Map<String, dynamic> updates = {};

        // Jika ada lastMessageTime tapi tidak ada timestamp, copy ke timestamp
        if (data['lastMessageTime'] != null && data['timestamp'] == null) {
          updates['timestamp'] = data['lastMessageTime'];
        }

        // Jika ada timestamp tapi tidak ada lastMessageTime, copy ke lastMessageTime
        if (data['timestamp'] != null && data['lastMessageTime'] == null) {
          updates['lastMessageTime'] = data['timestamp'];
        }

        // Pastikan ada users array
        if (data['users'] == null) {
          print('Warning: Chat ${doc.id} tidak memiliki users array');
          continue;
        }

        // Pastikan ada lastMessage
        if (data['lastMessage'] == null) {
          updates['lastMessage'] = '';
        }

        // Update jika ada perubahan
        if (updates.isNotEmpty) {
          batch.update(chatRef, updates);
          print('Updating chat ${doc.id} with: $updates');
        }
      }

      await batch.commit();
      print('Data migration completed successfully');
    } catch (e) {
      print('Error during migration: $e');
    }
  }
}

// Cara menggunakan:
// ChatDataMigration.standardizeChats();
