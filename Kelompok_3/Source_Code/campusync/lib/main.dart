import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'package:campusync/providers/user_provider.dart';
import 'package:campusync/screens/login_screen.dart';
import 'package:campusync/screens/edit_profile_screen.dart';
import 'package:campusync/responsive/mobile_screen_layout.dart';
import 'package:campusync/responsive/responsive_layout.dart';
import 'package:campusync/responsive/web_screen_layout.dart';
import 'package:campusync/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DevicePreview hanya aktif saat di Web dan mode Debug
  // Tidak akan aktif di mobile Android atau iOS
  if (kIsWeb && kDebugMode) {
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const CampusyncApp(),
      ),
    );
  } else {
    runApp(const CampusyncApp());
  }
}

class CampusyncApp extends StatelessWidget {
  const CampusyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Hanya aktif DevicePreview di web dan debug mode
    final bool isWebWithPreview = kIsWeb && kDebugMode;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'TukarIn App',
        debugShowCheckedModeBanner: false,
        // Hanya gunakan DevicePreview properties jika di web
        useInheritedMediaQuery: isWebWithPreview,
        builder: isWebWithPreview ? DevicePreview.appBuilder : null,
        locale: isWebWithPreview ? DevicePreview.locale(context) : null,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF689DB4),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                final user = snapshot.data!;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return const Center(
                          child: Text('Gagal memuat data user'));
                    }

                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;

                    final isProfileIncomplete = userData == null ||
                        (userData['fullname'] == null ||
                            userData['fullname'].toString().trim().isEmpty) ||
                        (userData['prodi'] == null ||
                            userData['prodi'].toString().trim().isEmpty);

                    if (isProfileIncomplete) {
                      return EditProfileScreen(userData: userData ?? {});
                    }

                    return const ResponsiveLayout(
                      webScreenLayout: WebScreenLayout(),
                      mobileScreenLayout: MobileScreenLayout(),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
