import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../resources/message_methods.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message.dart';
import 'package:campusync/providers/user_provider.dart';
import 'package:campusync/screens/profile_screen.dart'; // Add this import

class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic>? forwardedPost;

  const ChatScreen({
    Key? key,
    required this.chatId,
    this.forwardedPost,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool hasForwarded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendForwardedPost();
      _markMessagesAsRead();
    });
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final currentUser =
          Provider.of<UserProvider>(context, listen: false).user;
      if (currentUser == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUser.uid)
          .get();

      for (final doc in querySnapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
    }
  }

  Future<void> _sendForwardedPost() async {
    if (widget.forwardedPost == null || hasForwarded) return;

    final post = widget.forwardedPost!;
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    final message = Message(
      messageId: '',
      senderId: currentUser.uid,
      text: '[]',
      timestamp: Timestamp.now(),
      postData: {
        'username': post['username'],
        'description': post['description'],
        'postUrl': post['postUrl'],
        'postId': post['postId'],
      },
    );

    try {
      await MessageMethods.sendMessage(widget.chatId, message);
      setState(() => hasForwarded = true);
    } catch (e) {
      _showSnackBar("Gagal mengirim postingan");
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    final message = Message(
      messageId: '',
      senderId: currentUser.uid,
      text: text,
      timestamp: Timestamp.now(),
    );

    try {
      await MessageMethods.sendMessage(widget.chatId, message);
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      _showSnackBar("Gagal mengirim pesan");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirm = await _showDeleteDialog();
    if (confirm == true) {
      try {
        await MessageMethods.deleteMessage(widget.chatId, messageId);
      } catch (e) {
        _showSnackBar("Gagal menghapus pesan");
      }
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Pesan",
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text("Yakin ingin menghapus pesan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(uid: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildAppBarTitle(currentUser),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Menu options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5E6E0),
              ),
              child: _buildMessagesList(currentUser),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(dynamic currentUser) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Chat');

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final users = data?['users'] as List<dynamic>?;

        if (users == null || currentUser == null) return const Text("Unknown");

        final participantId = users.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );

        if (participantId.isEmpty) return const Text("Unknown");

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(participantId)
              .snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const Text("Loading...");
            final userData = userSnap.data!.data() as Map<String, dynamic>?;

            return GestureDetector(
              onTap: () => _navigateToProfile(participantId),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: userData?['photoUrl'] != null
                          ? NetworkImage(userData!['photoUrl'])
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: userData?['photoUrl'] == null
                          ? Text(
                              (userData?['username'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userData?['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "Online",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesList(dynamic currentUser) {
    return StreamBuilder<List<Message>>(
      stream: MessageMethods.getMessages(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9FD9)),
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Mulai percakapan",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == currentUser?.uid;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChatMessage(
                key: ValueKey(msg.messageId),
                message: msg,
                isCurrentUser: isMe,
                onReply: (_) {},
                onDelete: _deleteMessage,
                onProfileTap: _navigateToProfile, // Add this parameter
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF5E6E0),
      ),
      child: SafeArea(
        child: ChatInput(
          controller: _controller,
          sendMessage: _sendMessage,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
