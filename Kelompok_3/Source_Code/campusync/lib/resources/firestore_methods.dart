import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:campusync/resources/cloudinary_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Upload Post ke Firestore dan gambar ke Cloudinary
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    String category, // Menambahkan kategori sebagai parameter
  ) async {
    String res = 'Some error occurred';
    try {
      // Validasi deskripsi dan file
      if (description.trim().isEmpty || file.isEmpty) {
        return '❗ Deskripsi dan gambar tidak boleh kosong.';
      }

      // Upload gambar ke Cloudinary
      final photoUrl = await CloudinaryMethods().uploadImage(file, 'posts');
      if (photoUrl == null || photoUrl.isEmpty) {
        return '❗ Gagal upload gambar ke Cloudinary.';
      }

      final postId = const Uuid().v1(); // Menggunakan UUID untuk ID unik post

      // Membuat objek Post dan menyimpannya ke Firestore

      res = 'Success';
    } catch (e) {
      res = e.toString();
      print("🔥 uploadPost Error: $res");
    }
    return res;
  }

  /// ✅ Like atau Unlike sebuah post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final isLiked = likes.contains(uid);

      if (isLiked) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.arrayUnion([uid])
        });

        // ✅ Kirim notifikasi like
        final postSnap = await postRef.get();
        final postData = postSnap.data() as Map<String, dynamic>?;
        if (postData != null && postData['uid'] != uid) {
          final notif = {
            'type': 'like',
            'postId': postId,
            'fromUid': uid,
            'fromUsername': postData['username'],
            'fromPhotoUrl': postData['profImage'],
            'timestamp': Timestamp.now(),
            'isRead': false,
          };

          await _firestore
              .collection('users')
              .doc(postData['uid']) // Kirim ke pemilik post
              .collection('notifications')
              .add(notif);
        }
      }
    } catch (e) {
      print('⚠️ likePost Error: $e');
    }
  }

  /// ✅ Post komentar atau balasan komentar
  /// ✅ Post komentar atau balasan komentar
  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String username,
    String profilePic, {
    String? replyTo,
    String? replyToUsername,
    String? repliedUserId, // <=== tetap dipakai untuk reply
  }) async {
    String res = 'Some error occurred';
    try {
      if (text.trim().isEmpty) return "❗ Komentar tidak boleh kosong.";

      final commentId = const Uuid().v1();

      final commentData = {
        'commentId': commentId,
        'postId': postId,
        'uid': uid,
        'username': username,
        'profilePic': profilePic,
        'text': text.trim(),
        'datePublished': DateTime.now(),
        'replyTo': replyTo,
        'replyToUsername': replyToUsername,
      };

      // Simpan komentar
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(commentData);

      /// 🔔 Ambil UID pemilik post
      final postSnap = await _firestore.collection('posts').doc(postId).get();
      final postOwnerUid = postSnap['uid'];

      /// ✅ Notifikasi balasan komentar
      if (repliedUserId != null && repliedUserId != uid) {
        await _firestore
            .collection('users')
            .doc(repliedUserId)
            .collection('notifications')
            .add({
          'type': 'comment_reply',
          'postId': postId,
          'commentId': commentId,
          'fromUid': uid,
          'fromUsername': username,
          'fromPhotoUrl': profilePic,
          'text': text,
          'timestamp': Timestamp.now(),
          'isRead': false,
        });
      }

      /// ✅ Notifikasi komentar biasa
      if (postOwnerUid != uid &&
          (repliedUserId == null || repliedUserId == '')) {
        await _firestore
            .collection('users')
            .doc(postOwnerUid)
            .collection('notifications')
            .add({
          'type': 'comment',
          'postId': postId,
          'commentId': commentId,
          'fromUid': uid,
          'fromUsername': username,
          'fromPhotoUrl': profilePic,
          'text': text,
          'timestamp': Timestamp.now(),
          'isRead': false,
        });
      }

      res = 'Success';
    } catch (e) {
      res = e.toString();
      print('💬 postComment Error: $res');
    }
    return res;
  }

  /// ✅ Hapus komentar
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // Hapus komentar dari Firestore
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('🗑️ deleteComment Error: $e');
    }
  }

  /// ✅ Hapus post
  Future<void> deletePost(String postId) async {
    try {
      // Hapus post dari Firestore
      await _firestore.collection('posts').doc(postId).delete();
      // 🔄 Optional: Hapus juga gambar dari Cloudinary jika kamu menyimpan publicId-nya
    } catch (e) {
      print('🗑️ deletePost Error: $e');
    }
  }

  /// ✅ Follow / Unfollow user
  Future<void> followUser(String uid, String followId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final following =
          (userDoc.data()?['following'] as List?)?.cast<String>() ?? [];

      final currentUserRef = _firestore.collection('users').doc(uid);
      final followUserRef = _firestore.collection('users').doc(followId);

      if (following.contains(followId)) {
        // 🔁 Unfollow
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([followId])
        });
        await followUserRef.update({
          'followers': FieldValue.arrayRemove([uid])
        });
      } else {
        // ✅ Follow
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([followId])
        });
        await followUserRef.update({
          'followers': FieldValue.arrayUnion([uid])
        });

        // 🎯 Kirim notifikasi follow
        final fromData = userDoc.data();
        if (fromData != null) {
          final notif = {
            'type': 'follow',
            'fromUid': uid,
            'fromUsername': fromData['username'],
            'fromPhotoUrl': fromData['photoUrl'],
            'timestamp': Timestamp.now(),
            'isRead': false,
          };

          await _firestore
              .collection('users')
              .doc(followId)
              .collection('notifications')
              .add(notif);
        }
      }
    } catch (e) {
      print('👥 followUser Error: $e');
    }
  }
}
