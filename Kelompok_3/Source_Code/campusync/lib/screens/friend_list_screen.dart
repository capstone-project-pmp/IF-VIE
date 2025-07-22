import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({super.key});

  /// Ambil semua user dari followers dan following (digabung)
  Future<List<DocumentSnapshot>> _getCombinedUserList() async {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();
    final data = userDoc.data() as Map<String, dynamic>;

    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);

    // Gabungkan lalu hapus duplikat
    final Set<String> allUids = {...followers, ...following};

    if (allUids.isEmpty) return [];

    final usersRef = FirebaseFirestore.instance.collection('users');
    final snapshots = await Future.wait(
      allUids.map((uid) => usersRef.doc(uid).get()),
    );

    return snapshots.where((snap) => snap.exists).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FB3D3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text("Teman",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getCombinedUserList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text("Belum ada teman ditemukan"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(
                  user['fullname'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  user['bio'] ?? '',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(uid: user['uid']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
