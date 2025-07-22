import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as model;
import 'cloudinary_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Ambil detail user saat ini
  Future<model.User> getUserDetails() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint("❌ No current user found.");
      throw Exception("No current user found.");
    }

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!doc.exists || doc.data() == null) {
        final defaultUser = model.User(
          username: currentUser.displayName ?? 'newuser',
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          photoUrl: currentUser.photoURL ?? '',
          bio: '',
          followers: [],
          following: [],
        );

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(defaultUser.toJson());

        debugPrint("✅ Created new user document for ${currentUser.uid}");
        return defaultUser;
      }

      return model.User.fromSnap(doc);
    } catch (e) {
      debugPrint("❌ Error getting user details: $e");
      rethrow;
    }
  }

  // ✅ Registrasi user baru
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occurred';

    try {
      if (email.trim().isEmpty ||
          password.trim().isEmpty ||
          username.trim().isEmpty ||
          bio.trim().isEmpty ||
          file.isEmpty) {
        return "Please fill all fields and select a profile picture.";
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? photoUrl =
          await CloudinaryMethods().uploadImage(file, 'profilePics');

      if (photoUrl == null || photoUrl.isEmpty) {
        return 'Failed to upload profile picture.';
      }

      model.User user = model.User(
        username: username,
        uid: cred.user!.uid,
        email: email,
        photoUrl: photoUrl,
        bio: bio,
        followers: [],
        following: [],
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toJson());

      debugPrint("✅ Registration successful for ${cred.user!.uid}");
      res = 'Success';
    } on FirebaseAuthException catch (err) {
      debugPrint("❌ FirebaseAuthException during signUp: ${err.code}");
      switch (err.code) {
        case 'weak-password':
          res = 'Password should be at least 6 characters';
          break;
        case 'invalid-email':
          res = 'The email address is badly formatted.';
          break;
        case 'email-already-in-use':
          res = 'The email address is already in use by another account.';
          break;
        default:
          res = err.message ?? 'Unexpected FirebaseAuth error.';
      }
    } catch (e) {
      debugPrint("❌ Error during sign up: $e");
      res = 'Registration error: ${e.toString()}';
    }

    return res;
  }

  // ✅ Login user email/password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        return "Please enter all fields.";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("✅ Email/Password login successful for $email");
      res = "Success";
    } on FirebaseAuthException catch (err) {
      debugPrint("❌ FirebaseAuthException during login: ${err.code}");
      switch (err.code) {
        case 'user-not-found':
          res = 'No user found with that email.';
          break;
        case 'wrong-password':
          res = 'Incorrect password.';
          break;
        case 'invalid-email':
          res = 'Invalid email address.';
          break;
        case 'network-request-failed':
          res = 'No internet connection. Please try again.';
          break;
        default:
          res = err.message ?? 'Unexpected error.';
      }
    } catch (e) {
      debugPrint("❌ Error during login: $e");
      res = 'Login error: ${e.toString()}';
    }

    return res;
  }

  // ✅ Login via Google (Gmail)
  Future<String> signInWithGoogle() async {
    String res = "Some error occurred";

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        debugPrint("⚠️ Google sign-in aborted by user");
        return 'Sign in aborted by user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        debugPrint("❌ Firebase sign-in failed: No user object");
        return "Firebase login failed";
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        final newUser = model.User(
          username: user.displayName ?? "Anonymous",
          uid: user.uid,
          email: user.email ?? "",
          photoUrl: user.photoURL ?? "",
          bio: "",
          followers: [],
          following: [],
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
        debugPrint(
            "✅ Created Firestore user from Google Sign-In: ${user.email}");
      } else {
        debugPrint("👤 User already exists in Firestore: ${user.email}");
      }

      res = "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException on Google Sign-In: ${e.message}");
      res = e.message ?? "Firebase Auth error during Google Sign-In";
    } catch (e) {
      debugPrint("❌ Error during Google Sign-In: $e");
      res = "Google Sign-In error: ${e.toString()}";
    }

    return res;
  }

  // ✅ Logout user (Firebase + Google)
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn
            .disconnect(); // << Wajib agar muncul pemilihan akun saat login lagi
      }
      await googleSignIn.signOut();
      await _auth.signOut();
      debugPrint("✅ User signed out successfully.");

      await _auth.signOut();
      debugPrint("✅ User signed out successfully.");
    } catch (e) {
      debugPrint("⚠️ Sign out error: ${e.toString()}");
    }
  }

  // ✅ Ambil ID Token Firebase (opsional untuk backend)
  Future<String?> getIdToken() async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      debugPrint("🪪 Retrieved ID Token.");
      return token;
    } catch (e) {
      debugPrint("⚠️ Failed to get ID token: ${e.toString()}");
      return null;
    }
  }
}
