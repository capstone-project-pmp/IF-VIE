import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campusync/resources/auth_methods.dart';
import 'package:campusync/utils/utils.dart';
import 'package:campusync/responsive/responsive_layout.dart';
import 'package:campusync/responsive/web_screen_layout.dart';
import 'package:campusync/responsive/mobile_screen_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusync/screens/edit_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      String res = await AuthMethods().signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;

      if (res == "Success" && user != null) {
        final token = await AuthMethods().getIdToken();
        debugPrint("🪪 Firebase Token: $token");
        debugPrint("✅ Logged in as UID: ${user.uid}");

        if (!mounted) return;

        final docRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();

        Map<String, dynamic> userData = {};

        if (doc.exists && doc.data() != null) {
          userData = doc.data()!;
        } else {
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'photoUrl': '',
            'username': '',
            'fullname': '',
            'createdAt': DateTime.now(),
          });
        }

        userData = (await docRef.get()).data()!;

        bool isProfileIncomplete = (userData['username'] == null ||
                userData['username'].toString().isEmpty) ||
            (userData['fullname'] == null ||
                userData['fullname'].toString().isEmpty) ||
            (userData['photoUrl'] == null ||
                userData['photoUrl'].toString().isEmpty);

        if (isProfileIncomplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(
                userData: userData,
                isFirstTimeSetup: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResponsiveLayout(
                webScreenLayout: const WebScreenLayout(),
                mobileScreenLayout: const MobileScreenLayout(),
              ),
            ),
          );
        }
      } else {
        showSnackBar("Login gagal: $res", context);
      }
    } catch (e) {
      showSnackBar("Terjadi kesalahan: ${e.toString()}", context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5e6e0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo - Circular Image from Assets
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/syc.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Welcome Text dengan Font Pacifico
                Text(
                  "Hello,",
                  style: GoogleFonts.pacifico(
                    fontSize: 42,
                    color: const Color(0xFF1f2937),
                    height: 1.2,
                  ),
                ),

                Text(
                  "Welcome to",
                  style: GoogleFonts.pacifico(
                    fontSize: 42,
                    color: const Color(0xFF1f2937),
                    height: 1.2,
                  ),
                ),

                Text(
                  "Sync!",
                  style: GoogleFonts.pacifico(
                    fontSize: 42,
                    color: const Color(0xFF1f2937),
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 120),

                // Login Button dengan Icon Google
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : loginWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd946ef),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google Icon
                              Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(0xFF4285f4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Login with Google',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
