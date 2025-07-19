// models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotifModel {
  final String notifId;
  final String type;
  final String postId;
  final String commentId;
  final String fromUid;
  final String fromUsername;
  final String fromPhotoUrl;
  final String text;
  final Timestamp timestamp;
  final bool isRead;

  NotifModel({
    required this.notifId,
    required this.type,
    required this.postId,
    required this.commentId,
    required this.fromUid,
    required this.fromUsername,
    required this.fromPhotoUrl,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory NotifModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return NotifModel(
      notifId: doc.id,
      type: data?['type'] ?? 'unknown',
      postId: data?['postId'] ?? '',
      commentId: data?['commentId'] ?? '',
      fromUid: data?['fromUid'] ?? '',
      fromUsername: data?['fromUsername'] ?? 'Anonim',
      fromPhotoUrl: data?['fromPhotoUrl'] ?? '',
      text: data?['text'] ?? '',
      timestamp: data?['timestamp'] ?? Timestamp.now(),
      isRead: data?['isRead'] ?? false,
    );
  }
}
