import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campusync/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDE7F3),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF689DB4),
        title: _isSearching
            ? _buildSearchField()
            : const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'Pesan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
        centerTitle: false,
        actions: [_buildSearchToggle()],
      ),
      body: _isSearching && _searchController.text.isNotEmpty
          ? _buildSearchResults(currentUser.uid)
          : _buildRecentChats(currentUser.uid),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: Colors.grey.shade800),
        decoration: const InputDecoration(
          hintText: 'Cari pengguna...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSearchToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(_isSearching ? Icons.close : Icons.search,
            color: const Color(0xFF4A9FD9)),
        onPressed: () {
          setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) _searchController.clear();
          });
        },
      ),
    );
  }

  Widget _buildSearchResults(String currentUserId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username',
              isGreaterThanOrEqualTo: _searchController.text.trim())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(Icons.search_off, 'Pengguna tidak ditemukan');
        }

        final users = snapshot.data!.docs.where((doc) {
          final username = doc['username'].toString().toLowerCase();
          final query = _searchController.text.trim().toLowerCase();
          return username.contains(query) && doc['uid'] != currentUserId;
        }).toList();

        if (users.isEmpty) {
          return _emptyState(Icons.search_off, 'Pengguna tidak ditemukan');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserTile(user, currentUserId);
          },
        );
      },
    );
  }

  Widget _buildRecentChats(String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(Icons.chat_bubble_outline, 'Belum ada pesan');
        }

        // Sort chats by timestamp secara manual
        final chats = snapshot.data!.docs.toList();
        chats.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aTimestamp = aData['timestamp'] as Timestamp?;
          final bTimestamp = bData['timestamp'] as Timestamp?;

          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;

          return bTimestamp.compareTo(aTimestamp); // Descending order
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chatData = chats[index].data() as Map<String, dynamic>;
            final chatId = chats[index].id;
            final users = List<String>.from(chatData['users'] ?? []);
            final participantId =
                users.firstWhere((id) => id != currentUserId, orElse: () => '');
            final lastMessage = chatData['lastMessage'] ?? '';
            final timestamp = chatData['timestamp'] as Timestamp?;

            if (participantId.isEmpty) return const SizedBox();

            return _buildChatTile(
              participantId: participantId,
              lastMessage: lastMessage,
              timestamp: timestamp,
              chatId: chatId,
            );
          },
        );
      },
    );
  }

  Widget _buildChatTile({
    required String participantId,
    required String lastMessage,
    required Timestamp? timestamp,
    required String chatId,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(participantId)
          .get(),
      builder: (context, userSnapshot) {
        // Default user data jika belum ada data
        Map<String, dynamic> userData = {
          'username': 'Loading...',
          'photoUrl': '',
          'uid': participantId,
        };

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          userData = userSnapshot.data!.data() as Map<String, dynamic>;
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .where('isRead', isEqualTo: false)
              .where('senderId', isEqualTo: participantId)
              .snapshots(),
          builder: (context, unreadSnap) {
            final unreadCount = unreadSnap.data?.docs.length ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: _tileDecoration(),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: userData['photoUrl'] != null &&
                          userData['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(userData['photoUrl'])
                      : null,
                  child: userData['photoUrl'] == null ||
                          userData['photoUrl'].toString().isEmpty
                      ? Icon(Icons.person, color: Colors.green.shade400)
                      : null,
                ),
                title: Text(
                  userData['username'] ?? 'Unknown User',
                  style: TextStyle(
                      color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    lastMessage.isEmpty
                        ? 'Tap untuk memulai chat'
                        : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: lastMessage.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (timestamp != null)
                      Text(
                        _formatTime(timestamp.toDate()),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(chatId: chatId)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserTile(QueryDocumentSnapshot user, String currentUserId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _tileDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.green.shade100,
          backgroundImage:
              user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                  ? NetworkImage(user['photoUrl'])
                  : null,
          child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
              ? Icon(Icons.person, color: Colors.green.shade400)
              : null,
        ),
        title: Text(
          user['username'] ?? 'Unknown User',
          style: TextStyle(
              color: Colors.grey.shade800, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chat_bubble_outline, color: Colors.green.shade400),
        onTap: () {
          final targetId = user['uid'];
          final sorted = [currentUserId, targetId]..sort();
          final chatId = sorted.join('_');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
          );
        },
      ),
    );
  }

  BoxDecoration _tileDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _loadingIndicator() => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
        ),
      );

  Widget _emptyState(IconData icon, String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(message,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${time.day}/${time.month}/${time.year}';
  }
}
