import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            style: TextStyle(
              color: textColor ?? Colors.black87,
              fontSize: 16,
              // ✅ Kursor jadi warna hitam
            ),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: hintText ?? label,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
