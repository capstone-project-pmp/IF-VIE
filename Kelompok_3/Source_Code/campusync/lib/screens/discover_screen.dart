import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusync/utils/utils.dart';
import 'dart:math';
import 'chat_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final PageController _pageController = PageController();
  List<DocumentSnapshot> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Track user interactions
  Map<String, String> _userInteractions = {}; // userId -> 'liked' or 'disliked'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user's following list
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      final following =
          List<String>.from(currentUserDoc.data()?['following'] ?? []);

      // Get all users except current user
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').limit(100).get();

      List<DocumentSnapshot> allUsers = querySnapshot.docs.where((doc) {
        final userId = doc.id;
        return userId != _currentUserId;
      }).toList();

      // Randomize the user list
      allUsers.shuffle(Random());

      // Take only 20 users for better performance
      _users = allUsers.take(20).toList();

      // Initialize interaction states
      for (var user in _users) {
        final userId = user.id;
        if (following.contains(userId)) {
          _userInteractions[userId] = 'liked';
        } else {
          _userInteractions[userId] = 'disliked';
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar('Error loading users: $e', context);
    }
  }

  Future<void> _handleLike() async {
    if (_currentIndex >= _users.length) return;

    final targetUserId = _users[_currentIndex].id;

    try {
      // Follow the user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({
        'following': FieldValue.arrayUnion([targetUserId])
      });

      // Add to target user's followers
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .update({
        'followers': FieldValue.arrayUnion([_currentUserId])
      });

      setState(() {
        _userInteractions[targetUserId] = 'liked';
      });

      showSnackBar('User diikuti!', context);
    } catch (e) {
      showSnackBar('Error: $e', context);
    }
  }

  Future<void> _handleDislike() async {
    if (_currentIndex >= _users.length) return;

    final targetUserId = _users[_currentIndex].id;

    try {
      // Unfollow the user if currently following
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({
        'following': FieldValue.arrayRemove([targetUserId])
      });

      // Remove from target user's followers
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .update({
        'followers': FieldValue.arrayRemove([_currentUserId])
      });

      setState(() {
        _userInteractions[targetUserId] = 'disliked';
      });

      _nextUser();
    } catch (e) {
      showSnackBar('Error: $e', context);
    }
  }

  Future<void> _handleChat() async {
    if (_currentIndex >= _users.length) return;

    final targetUserId = _users[_currentIndex].id;

    try {
      // Create or get existing chat
      final chatId = await _createOrGetChat(targetUserId);

      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chatId),
        ),
      );
    } catch (e) {
      showSnackBar('Error opening chat: $e', context);
    }
  }

  Future<String> _createOrGetChat(String targetUserId) async {
    // Check if chat already exists
    final existingChats = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: _currentUserId)
        .get();

    for (var doc in existingChats.docs) {
      final users = List<String>.from(doc.data()['users']);
      if (users.contains(targetUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final chatRef = await FirebaseFirestore.instance.collection('chats').add({
      'users': [_currentUserId, targetUserId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  void _nextUser() {
    if (_currentIndex < _users.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Reload and shuffle users
      _loadUsers();
      setState(() {
        _currentIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4),
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'Match Friend',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Tidak ada pengguna baru',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        child: const Text('Muat Ulang'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header text - lebih compact
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Geser dan temukan koneksi.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _users.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final userData = user.data() as Map<String, dynamic>;
                          final userId = user.id;
                          final interactionState =
                              _userInteractions[userId] ?? 'disliked';

                          return SingleChildScrollView(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  // Profile Image - Smaller and circular
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: userData['photoUrl'] != null
                                          ? Image.network(
                                              userData['photoUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // User Info Card - Compact and flexible
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE49AB0),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                            'Nama',
                                            userData['fullname'] ??
                                                userData['username'] ??
                                                'Unknown'),
                                        _buildInfoRow(
                                            'Univ',
                                            userData['university'] ??
                                                'Tidak diketahui'),
                                        _buildInfoRow(
                                            'Prodi',
                                            userData['prodi'] ??
                                                'Tidak diketahui'),
                                        _buildInfoRow(
                                            'Gender',
                                            userData['gender'] ??
                                                'Tidak diketahui'),
                                        _buildInfoRow(
                                            'Hobby',
                                            userData['hobbies'] ??
                                                'Tidak diketahui'),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Action Buttons - Compact
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Left Button (Dislike/Like)
                                      GestureDetector(
                                        onTap: interactionState == 'liked'
                                            ? _handleDislike
                                            : _handleLike,
                                        child: Container(
                                          width: 100,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: interactionState == 'liked'
                                                ? const Color(0xFFFF6B6B)
                                                : const Color(0xFF51CF66),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              interactionState == 'liked'
                                                  ? 'Dislike'
                                                  : 'Like',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Right Button (Chat/Next)
                                      GestureDetector(
                                        onTap: interactionState == 'liked'
                                            ? _handleChat
                                            : _nextUser,
                                        child: Container(
                                          width: 100,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: interactionState == 'liked'
                                                ? const Color(0xFF339AF0)
                                                : const Color(0xFFE49AB0),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (interactionState == 'liked')
                                                  const Icon(
                                                    Icons.chat,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                if (interactionState == 'liked')
                                                  const SizedBox(width: 4),
                                                Text(
                                                  interactionState == 'liked'
                                                      ? 'Chat'
                                                      : 'Next',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
