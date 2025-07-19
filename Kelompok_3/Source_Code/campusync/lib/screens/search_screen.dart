import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusync/screens/profile_screen.dart';
import 'package:campusync/screens/university_search_screen.dart';
import 'package:campusync/screens/notification_screen.dart';
import 'package:campusync/screens/navigation_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E0), // Light pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4), // Light blue color
        elevation: 0,
        title: Text(
          'Sync',
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 26,
          ),
        ),

        actions: [
          _buildNotificationButton(),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UniversitySearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NavigationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildUserGrid(),
    );
  }

  Widget _buildNotificationButton() {
    // Get current user ID safely
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return IconButton(
        icon: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 26,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationScreen(),
            ),
          );
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Use actual user ID
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserGrid() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').limit(100).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error loading users: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Gagal memuat data pengguna'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada pengguna',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // Shuffle users for random display
        users.shuffle();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: _buildRows(users),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildRows(List<QueryDocumentSnapshot> users) {
    List<Widget> rows = [];

    for (int i = 0; i < users.length; i += 4) {
      List<QueryDocumentSnapshot> rowUsers = users.skip(i).take(4).toList();
      rows.add(_buildRow(rowUsers));
      rows.add(const SizedBox(height: 8)); // Space between rows
    }

    return rows;
  }

  Widget _buildRow(List<QueryDocumentSnapshot> rowUsers) {
    return SizedBox(
      height: 159, // Fixed height for the row
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rowUsers.length,
        itemBuilder: (context, index) {
          final user = rowUsers[index];
          final userData = user.data() as Map<String, dynamic>?;

          // Safety check for user data
          if (userData == null) {
            return Container(
              width: 133,
              margin: const EdgeInsets.only(right: 8),
              child: const Card(
                child: Center(
                  child: Text('Data tidak valid'),
                ),
              ),
            );
          }

          return Container(
            width: 133, // Fixed width for each photo
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                final uid = userData['uid'];
                if (uid != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(uid: uid),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 133,
                  height: 159,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Profile Image
                      Container(
                        width: 133,
                        height: 159,
                        child: _buildProfileImage(userData['photoUrl']),
                      ),
                      // Username overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            userData['username'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.person,
          color: Colors.grey,
          size: 40,
        ),
      );
    }

    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
    );
  }
}
