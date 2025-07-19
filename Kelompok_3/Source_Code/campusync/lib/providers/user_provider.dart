import 'package:flutter/material.dart';
import 'package:campusync/resources/auth_methods.dart';
import 'package:campusync/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  // Getter aman, null-safe
  User? get user => _user;

  // Getter lama, optional: tetap bisa pakai kalau yakin tidak null
  User get getUser {
    if (_user == null) {
      throw Exception("User belum dimuat. Panggil refreshUser() dulu.");
    }
    return _user!;
  }

  // Fungsi untuk me-refresh user dari AuthMethods
  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
