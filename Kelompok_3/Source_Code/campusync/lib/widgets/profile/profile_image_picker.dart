import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final Uint8List? imageData;
  final VoidCallback onTap;
  final bool isEditable;

  const ProfileImagePicker({
    Key? key,
    this.imageData,
    required this.onTap,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 120.0; // ✅ Ukuran foto profil diperbesar
    const double innerSize = size - 6; // Margin 3 dari semua sisi

    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: _buildImage(innerSize),
              ),
            ),
          ),
          if (isEditable)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(double size) {
    if (imageData != null) {
      return Image.memory(
        imageData!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }

    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
