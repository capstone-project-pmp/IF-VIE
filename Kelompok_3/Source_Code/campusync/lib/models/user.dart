import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  static User fromSnap(DocumentSnapshot snap) {
    final data = snap.data();
    if (data == null) {
      throw Exception('Snapshot data is null');
    }

    final snapshot = data as Map<String, dynamic>;

    return User(
      username:
          snapshot["username"] ?? 'Unknown', // Fallback jika username kosong
      uid: snapshot["uid"] ?? '',
      email: snapshot["email"] ?? '',
      photoUrl: snapshot["photoUrl"] ?? '', // Fallback jika photoUrl kosong
      bio: snapshot["bio"] ?? '', // Fallback jika bio kosong
      followers: List.from(
          snapshot["followers"] ?? []), // Fallback jika followers kosong
      following: List.from(
          snapshot["following"] ?? []), // Fallback jika following kosong
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
      };
}
