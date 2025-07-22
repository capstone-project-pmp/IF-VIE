import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusync/screens/discover_screen.dart';
import 'package:campusync/screens/chat_list_screen.dart';
import 'package:campusync/screens/profile_screen.dart';
import 'package:campusync/screens/search_screen.dart';

const webScreenSize = 600;

/// Fungsi untuk mengembalikan daftar halaman utama
List<Widget> getHomeScreenItems() {
  return [
    const SearchScreen(),
    const DiscoverScreen(), // ✅ Ganti Home dengan DiscoverScreen
    const ChatListScreen(),
    _buildProfileScreenSafely(),
  ];
}

/// Hanya tampilkan profil jika user login
Widget _buildProfileScreenSafely() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return ProfileScreen(uid: user.uid);
  } else {
    return const Center(child: Text('User not logged in'));
  }
}
