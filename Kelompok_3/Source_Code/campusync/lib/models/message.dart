import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final String? repliedToMessageId;
  final Map<String, dynamic>? postData;

  Message({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.repliedToMessageId,
    this.postData,
  });

  /// 🔁 Konversi ke Map (untuk upload ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      if (repliedToMessageId != null) 'repliedToMessageId': repliedToMessageId,
      if (postData != null) 'postData': postData,
    };
  }

  /// 🔁 Buat Message dari DocumentSnapshot Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw StateError("📛 Dokumen kosong atau tidak valid.");
    }

    return Message.fromMap(data, messageId: doc.id);
  }

  /// 🔁 Buat Message dari Map (misal hasil query manual)
  factory Message.fromMap(Map<String, dynamic> data,
      {required String messageId}) {
    return Message(
      messageId: messageId,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      repliedToMessageId: data['repliedToMessageId'],
      postData: data['postData'] != null && data['postData'] is Map
          ? Map<String, dynamic>.from(data['postData'])
          : null,
    );
  }
}
