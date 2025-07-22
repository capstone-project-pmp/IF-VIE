import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String _getTitle(NotifModel notif) {
    switch (notif.type) {
      case 'comment':
        return "${notif.fromUsername} mengomentari postingan anda";
      case 'like':
        return "${notif.fromUsername} telah menyukai anda";
      case 'follow':
        return "${notif.fromUsername} mulai mengikuti anda";
      default:
        return "${notif.fromUsername} berinteraksi dengan anda";
    }
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    return 'Baru saja';
  }

  void _handleTap(NotifModel notif, String uid, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notif.notifId)
        .update({'isRead': true});

    if (notif.type == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(uid: notif.fromUid)),
      );
    }
  }

  Widget _buildNotificationItem(
      NotifModel notif, String uid, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(notif.fromPhotoUrl),
            radius: 25,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(notif),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notif.timestamp.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E0),
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF689DB4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Friend Requests Section

          // Notifications List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5DB3C1),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Tidak ada notifikasi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notif = NotifModel.fromDoc(docs[index]);
                    return InkWell(
                      onTap: () => _handleTap(notif, user.uid, context),
                      child: _buildNotificationItem(notif, user.uid, context),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
