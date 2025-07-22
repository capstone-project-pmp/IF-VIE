import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatMessage extends StatelessWidget {
  final Message message;
  final Function(String) onReply;
  final bool isCurrentUser;
  final Function(String) onDelete;
  final Function(String) onProfileTap; // Add this parameter

  const ChatMessage({
    Key? key,
    required this.message,
    required this.onReply,
    required this.isCurrentUser,
    required this.onDelete,
    required this.onProfileTap, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isForwarded = message.postData != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            // Add clickable profile picture for other users
            GestureDetector(
              onTap: () => onProfileTap(message.senderId),
              child: _buildSenderAvatar(),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.repliedToMessageId != null)
                  _buildRepliedMessage(message.repliedToMessageId!),
                GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: _buildMessageBubble(isForwarded),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(message.senderId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 16, color: Colors.grey),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final photoUrl = userData?['photoUrl'];
        final username = userData?['username'] ?? 'U';

        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : null,
        );
      },
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.reply, color: Colors.blue.shade600),
                title: const Text('Balas'),
                onTap: () {
                  Navigator.pop(context);
                  onReply(message.messageId);
                },
              ),
              if (!isCurrentUser)
                ListTile(
                  leading: Icon(Icons.person, color: Colors.green.shade600),
                  title: const Text('Lihat Profil'),
                  onTap: () {
                    Navigator.pop(context);
                    onProfileTap(message.senderId);
                  },
                ),
              if (isCurrentUser)
                ListTile(
                  leading:
                      Icon(Icons.delete_outline, color: Colors.red.shade400),
                  title: const Text('Hapus'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Hapus Pesan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text("Yakin ingin menghapus pesan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Batal",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Hapus",
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onDelete(message.messageId);
    }
  }

  Widget _buildRepliedMessage(String repliedToMessageId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('messages')
          .doc(repliedToMessageId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRepliedContainer("Memuat...", Colors.grey.shade400);
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return _buildRepliedContainer(
              "Balasan tidak ditemukan", Colors.grey.shade400);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final text = data?['text'] ?? "Pesan kosong";

        return _buildRepliedContainer("Membalas: $text", Colors.blue.shade400);
      },
    );
  }

  Widget _buildRepliedContainer(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMessageBubble(bool isForwarded) {
    final bgColor = isCurrentUser ? const Color(0xFF4A9FD9) : Colors.white;
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isCurrentUser ? 18 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isForwarded && message.postData != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forward,
                    size: 16,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Post Diteruskan",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (message.postData!['postUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.postData!['postUrl'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A9FD9),
                              ),
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          "Gambar tidak dapat dimuat",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (message.postData!['username'] != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Navigate to profile of the original post author
                  // You need to get the uid from postData if available
                  // or implement a search by username
                  final originalPosterId = message.postData!['posterId'];
                  if (originalPosterId != null) {
                    onProfileTap(originalPosterId);
                  }
                },
                child: Text(
                  "@${message.postData!['username']}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            if (message.postData!['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                message.postData!['description'],
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ] else ...[
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 4),
          // Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Now";
    }
  }
}
