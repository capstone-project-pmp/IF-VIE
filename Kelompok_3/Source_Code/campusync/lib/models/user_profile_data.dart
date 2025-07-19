// models/user_profile_data.dart
class UserProfileData {
  final String uid;
  final String fullname;
  final String username;
  final String? bio;
  final String? photoUrl;
  final String? university;
  final String? prodi;
  final String? gender;
  final String? hobbies;
  final int? age;
  final List<String> followers;
  final List<String> following;

  UserProfileData({
    required this.uid,
    required this.fullname,
    required this.username,
    this.bio,
    this.photoUrl,
    this.university,
    this.prodi,
    this.gender,
    this.hobbies,
    this.age,
    required this.followers,
    required this.following,
  });

  factory UserProfileData.fromMap(Map<String, dynamic> map) {
    return UserProfileData(
      uid: map['uid'] ?? '',
      fullname: map['fullname'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      university: map['university'],
      prodi: map['prodi'],
      gender: map['gender'],
      hobbies: map['hobbies'],
      age: map['age'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'university': university,
      'prodi': prodi,
      'gender': gender,
      'hobbies': hobbies,
      'age': age,
      'followers': followers,
      'following': following,
    };
  }

  UserProfileData copyWith({
    String? uid,
    String? fullname,
    String? username,
    String? bio,
    String? photoUrl,
    String? university,
    String? prodi,
    String? gender,
    String? hobbies,
    int? age,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserProfileData(
      uid: uid ?? this.uid,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      university: university ?? this.university,
      prodi: prodi ?? this.prodi,
      gender: gender ?? this.gender,
      hobbies: hobbies ?? this.hobbies,
      age: age ?? this.age,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  @override
  String toString() {
    return 'UserProfileData(uid: $uid, fullname: $fullname, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileData && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
