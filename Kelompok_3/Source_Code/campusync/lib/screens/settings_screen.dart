import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campusync/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color(0xFFE55896),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Anda Yakin Akan Logout\nakun atau bermasalah?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCEAE6),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Tidak"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FB3D3),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Ya"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color(0xFFE55896),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Anda Yakin Akan Hapus Akun?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          content: const Text(
            "Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus permanen.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("TIDAK"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                await _handleDeleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("HAPUS"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // Simpan navigator reference
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        navigator.pop(); // Tutup loading
        return;
      }

      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Batch operations untuk hapus data Firestore
      final batch = firestore.batch();

      // Hapus data pengguna
      final userDocRef = firestore.collection('users').doc(uid);
      batch.delete(userDocRef);

      // Hapus posts milik user
      final postsQuery = await firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in postsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Hapus comments milik user
      final commentsQuery = await firestore
          .collection('comments')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in commentsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Hapus semua chat yang melibatkan user ini
      await _removeUserChats(uid, firestore);

      // Update followers/following lists
      await _removeUserFromFollowersLists(uid, firestore);

      // Commit batch operations
      await batch.commit();

      // Sign out dari Google SEBELUM menghapus user
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      // Tutup loading dialog
      navigator.pop();

      // Pindah ke LoginScreen SEBELUM menghapus user dari Auth
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      // Hapus dari Firebase Authentication (di background)
      user.delete().catchError((error) {
        debugPrint("Error deleting user from Auth: $error");
      });

      // Tampilkan pesan sukses
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Tutup loading dialog
      navigator.pop();

      // Handle error
      String errorMessage = "Gagal menghapus akun";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            errorMessage = "Silakan login ulang untuk menghapus akun";
            break;
          case 'user-not-found':
            errorMessage = "Akun tidak ditemukan";
            break;
          default:
            errorMessage = "Error: ${e.message}";
        }
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint("Delete account error: ${e.toString()}");
    }
  }

  Future<void> _removeUserChats(String uid, FirebaseFirestore firestore) async {
    try {
      // 1. Cari semua chat yang melibatkan user ini
      final chatsQuery = await firestore
          .collection('chats')
          .where('users', arrayContains: uid)
          .get();

      final batch = firestore.batch();

      for (var chatDoc in chatsQuery.docs) {
        final chatId = chatDoc.id;

        // 2. Hapus semua messages dalam chat ini
        final messagesQuery = await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .get();

        for (var messageDoc in messagesQuery.docs) {
          batch.delete(messageDoc.reference);
        }

        // 3. Hapus document chat utama
        batch.delete(chatDoc.reference);
      }

      // Commit batch operations
      await batch.commit();
      debugPrint(
          "Successfully removed ${chatsQuery.docs.length} chats for user $uid");
    } catch (e) {
      debugPrint("Error removing user chats: $e");
    }
  }

  Future<void> _removeUserFromFollowersLists(
      String uid, FirebaseFirestore firestore) async {
    try {
      // Ambil semua pengguna yang memiliki uid ini di followers atau following list
      final usersQuery = await firestore.collection('users').get();

      final batch = firestore.batch();

      for (var doc in usersQuery.docs) {
        final data = doc.data();
        bool needsUpdate = false;

        // Update followers list
        if (data['followers'] != null) {
          List<String> followers = List<String>.from(data['followers']);
          if (followers.contains(uid)) {
            followers.remove(uid);
            data['followers'] = followers;
            needsUpdate = true;
          }
        }

        // Update following list
        if (data['following'] != null) {
          List<String> following = List<String>.from(data['following']);
          if (following.contains(uid)) {
            following.remove(uid);
            data['following'] = following;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          batch.update(doc.reference, data);
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error removing user from followers lists: $e");
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Logout error: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout gagal: ${e.toString()}")),
      );
    }
  }

  Widget _buildOption({
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          color: const Color(0xFFF8DCD2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.black,
                fontWeight: textColor == Colors.red
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4),
        centerTitle: false,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildOption(
            title: 'Logout',
            onTap: () => _showLogoutDialog(context),
          ),
          _buildOption(
            title: 'Hapus Akun Saya',
            onTap: () => _showDeleteDialog(context),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
