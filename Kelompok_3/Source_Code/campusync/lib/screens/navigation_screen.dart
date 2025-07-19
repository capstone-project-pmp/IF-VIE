import 'package:flutter/material.dart';
import 'package:campusync/screens/friend_list_screen.dart';
import 'package:campusync/screens/settings_screen.dart';
import 'package:campusync/screens/help_center_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAE6), // Soft pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4), // Blue header
        centerTitle: false,
        title: const Text(
          'Navigasi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(context, 'Teman', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendListScreen()),
              );
            }),
            const SizedBox(height: 16),
            _buildMenuButton(context, 'Pengaturan', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),
            const SizedBox(height: 16),
            _buildMenuButton(context, 'Pusat Bantuan', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD7759E), // Pink button
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
