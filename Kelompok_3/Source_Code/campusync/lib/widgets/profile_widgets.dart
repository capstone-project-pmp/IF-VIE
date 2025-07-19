// widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile_data.dart';
import 'package:campusync/screens/university_search_screen.dart';
import 'package:campusync/screens/notification_screen.dart';
import 'package:campusync/screens/navigation_screen.dart';

class ProfileConstants {
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color lightPink = Color(0xFFF8BBD9);
  static const Color backgroundPink = Color(0xFFFDE7F3);
  static const Color cardPink = Color(0xFFE1BEE7);
  static const Color darkGrey = Color(0xFF424242);
  static const Color textGrey = Color(0xFF616161);
  static const double cardRadius = 20.0;
  static const double avatarSize = 100.0;
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isCurrentUser;

  const ProfileAppBar({Key? key, required this.isCurrentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF689DB4),
      elevation: 0,
      title: Row(
        children: const [
          Text(
            'Info Akun',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      centerTitle: false,
      leading: isCurrentUser
          ? null // Tidak tampilkan tombol back jika profil sendiri
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none,
              color: Colors.white, size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 26),
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
          icon: const Icon(Icons.menu, color: Colors.white, size: 26),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileCard extends StatelessWidget {
  final UserProfileData userData;
  final int followerCount;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback? onEditProfile;
  final VoidCallback? onFollowToggle;
  final VoidCallback? onChat;

  const ProfileCard({
    Key? key,
    required this.userData,
    required this.followerCount,
    required this.isCurrentUser,
    this.isFollowing = false,
    this.isFollowLoading = false,
    this.onEditProfile,
    this.onFollowToggle,
    this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ProfileConstants.screenPadding,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // COVER BACKGROUND
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 240,
                  color: Colors.grey[300],
                  child:
                      userData.photoUrl != null && userData.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: userData.photoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/default_avatar.png',
                              fit: BoxFit.cover),
                ),
              ),

              // FOTO PROFIL KOTAK 1:1 DI TENGAH ATAS (DI ATAS COVER)
              Positioned(
                top: 180 - ProfileConstants.avatarSize / 2,
                left: 16,
                child: Container(
                  width: ProfileConstants.avatarSize,
                  height: ProfileConstants.avatarSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: userData.photoUrl != null &&
                            userData.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: userData.photoUrl!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset('assets/default_avatar.png',
                            fit: BoxFit.cover),
                  ),
                ),
              ),

              // NAMA DAN USERNAME DI BAWAH KIRI COVER
              Positioned(
                bottom: 16,
                left: 16 + ProfileConstants.avatarSize + 12,
                right: isCurrentUser ? 100 : 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.fullname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                    Text(
                      '@${userData.username}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                      ),
                    ),
                  ],
                ),
              ),

              // TOMBOL EDIT HANYA UNTUK CURRENT USER DI KANAN BAWAH
              if (isCurrentUser)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildEditButton(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),

          // TOMBOL SUKAI DAN CHAT DI BAWAH STATISTIK
          if (!isCurrentUser) _buildActionButtonsRow(),

          // GARIS HORIZONTAL PEMBATAS
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label,
      {Color textColor = Colors.black}) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          userData.followers.length.toString(),
          'Yang Menyukaiku',
          textColor: Colors.black,
        ),
        _buildStatItem(
          userData.following.length.toString(),
          'Yang Kusuka',
          textColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildActionButton(
              icon: isFollowing ? Icons.favorite : Icons.favorite_border,
              text: isFollowing ? 'Batal Sukai' : 'Sukai',
              onPressed: onFollowToggle,
              isLoading: isFollowLoading,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildActionButton(
              icon: Icons.chat,
              text: 'Chat',
              onPressed: onChat,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing && text.contains('Batal')
            ? Colors.grey[600]
            : ProfileConstants.primaryPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildEditButton() {
    return FloatingActionButton(
      onPressed: onEditProfile,
      backgroundColor: const Color(0xFFDA75A5),
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final UserProfileData userData;

  const ProfileInfoCard({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: ProfileConstants.lightPink,
        borderRadius: BorderRadius.circular(ProfileConstants.cardRadius),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.info_outline, userData.bio ?? '-'),
          _buildInfoItem(Icons.school, userData.university ?? '-'),
          _buildInfoItem(Icons.book, userData.prodi ?? '-'),
          _buildInfoItem(Icons.wc, userData.gender ?? '-'),
          _buildInfoItem(Icons.interests, userData.hobbies ?? '-'),
          _buildInfoItem(Icons.cake, userData.age?.toString() ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ProfileConstants.textGrey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ProfileConstants.textGrey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: ProfileConstants.primaryPink,
      ),
    );
  }
}

class ProfileErrorState extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const ProfileErrorState({
    Key? key,
    this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: ProfileConstants.screenPadding,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ProfileConstants.lightPink,
          borderRadius: BorderRadius.circular(ProfileConstants.cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: ProfileConstants.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileConstants.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
