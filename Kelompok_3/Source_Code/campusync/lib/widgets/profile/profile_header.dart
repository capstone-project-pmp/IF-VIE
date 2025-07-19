import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:campusync/widgets/profile/profile_image_picker.dart';

class ProfileHeader extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController bioController;
  final Uint8List? imageData;
  final String? imageUrl;
  final VoidCallback onImageTap;

  const ProfileHeader({
    Key? key,
    required this.nameController,
    required this.bioController,
    this.imageData,
    this.imageUrl,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double profileImageSize = 120.0;

    return Column(
      children: [
        // AppBar tanpa tombol kembali dan titik tiga
        AppBar(
          backgroundColor: const Color(0xFF689DB4),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Konten profil
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF5E6D3),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: profileImageSize,
                    height: profileImageSize,
                    child: ProfileImagePicker(
                      imageData: imageData,
                      onTap: onImageTap,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A5C9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.black, // ✅ Kursor hitam
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: 'Enter your name',
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 12), // Jarak antara nama dan bio lebih kecil
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8C5D1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: bioController,
                      maxLines: 2,
                      cursorColor: Colors.black, // ✅ Kursor hitam
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        hintText: 'Describe something',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black26,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
