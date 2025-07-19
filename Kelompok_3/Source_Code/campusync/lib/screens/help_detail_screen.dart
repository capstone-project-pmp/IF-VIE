import 'package:flutter/material.dart';

class HelpDetailScreen extends StatelessWidget {
  final String question;
  final String answer;

  const HelpDetailScreen({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAE6), // Soft pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4), // Blue header
        centerTitle: false,
        elevation: 0,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFE8C4D0), // Light pink background for question
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Answer text
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
