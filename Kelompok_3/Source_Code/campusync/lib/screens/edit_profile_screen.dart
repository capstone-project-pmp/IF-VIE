// lib/screens/edit_profile_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusync/responsive/responsive_layout.dart';
import 'package:campusync/responsive/web_screen_layout.dart';
import 'package:campusync/responsive/mobile_screen_layout.dart';
import 'package:campusync/resources/cloudinary_methods.dart';
import 'package:campusync/utils/utils.dart';
import 'package:campusync/widgets/profile/profile_header.dart';
import 'package:campusync/widgets/profile/custom_text_field.dart';
import 'package:campusync/widgets/profile/custom_dropdown.dart';
import 'package:campusync/widgets/profile/university_autocomplete.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isFirstTimeSetup;

  const EditProfileScreen({
    Key? key,
    required this.userData,
    this.isFirstTimeSetup = false,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _universityController = TextEditingController();

  Uint8List? _newImage;
  bool _isSaving = false;
  bool _isLoading = true;

  String? _selectedUniversity;
  String? _selectedGender;
  String? _selectedProdi;
  String? _selectedHobby;

  List<String> _universityList = [];
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan', 'Lainnya'];
  List<String> _prodiOptions = [];
  List<String> _hobbyOptions = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      // Load data secara parallel
      await Future.wait([
        _loadProdiOptions(),
        _loadUniversities(),
        _loadHobbies(),
      ]);

      await _refreshUserData();
      _initializeFields();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error initializing data: $e');
      _showMessage('Gagal memuat data', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snap.exists) {
      widget.userData.addAll(snap.data()!);
    }
  }

  Future<void> _loadProdiOptions() async {
    try {
      final response = await rootBundle.loadString('assets/prodi.json');
      final data = jsonDecode(response);
      _prodiOptions = List<String>.from(data.map((e) => e['nama_prodi']));
      _prodiOptions.sort();
    } catch (e) {
      debugPrint('Error loading prodi: $e');
    }
  }

  Future<void> _loadHobbies() async {
    try {
      final response = await rootBundle.loadString('assets/hobbies.json');
      final data = jsonDecode(response);
      _hobbyOptions = List<String>.from(data.map((e) => e['nama_hobi']));
      _hobbyOptions.sort();
    } catch (e) {
      debugPrint('Error loading hobbies: $e');
    }
  }

  Future<void> _loadUniversities() async {
    try {
      final response = await rootBundle.loadString('assets/universities.json');
      final data = jsonDecode(response);
      _universityList = List<String>.from(data.map((e) => e['nama_institusi']));
    } catch (e) {
      debugPrint('Error loading universities: $e');
    }
  }

  void _initializeFields() {
    _nameController.text = widget.userData['fullname'] ?? '';
    _usernameController.text = widget.userData['username'] ?? '';
    _bioController.text = widget.userData['bio'] ?? '';
    _ageController.text = widget.userData['age']?.toString() ?? '';
    _selectedGender = widget.userData['gender'];
    _selectedProdi = widget.userData['prodi'];
    _selectedUniversity = widget.userData['university'];
    _selectedHobby = widget.userData['hobbies'];

    // Validate selections
    if (!_genderOptions.contains(_selectedGender)) _selectedGender = null;
    if (!_prodiOptions.contains(_selectedProdi)) _selectedProdi = null;
    if (!_universityList.contains(_selectedUniversity))
      _selectedUniversity = null;
    if (!_hobbyOptions.contains(_selectedHobby)) _selectedHobby = null;

    _universityController.text = _selectedUniversity ?? '';
  }

  Future<void> _selectImage() async {
    try {
      final img = await pickImage(ImageSource.gallery);
      if (img != null) {
        setState(() => _newImage = img);
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      _showMessage('Gagal memilih gambar', isError: true);
    }
  }

  // ✅ Fungsi untuk mengecek apakah photoUrl adalah Google URL
  bool _isGooglePhotoUrl(String? photoUrl) {
    if (photoUrl == null) return false;
    return photoUrl.contains('googleusercontent.com') ||
        photoUrl.contains('google.com') ||
        photoUrl.contains('lh3.googleusercontent.com') ||
        photoUrl.contains('lh4.googleusercontent.com') ||
        photoUrl.contains('lh5.googleusercontent.com') ||
        photoUrl.contains('lh6.googleusercontent.com');
  }

  // ✅ Fungsi untuk mendapatkan safe photo URL (non-Google)
  String? _getSafePhotoUrl() {
    final photoUrl = widget.userData['photoUrl'];
    if (_isGooglePhotoUrl(photoUrl)) {
      return null; // Jangan gunakan Google URL
    }
    return photoUrl;
  }

  // Fungsi untuk menentukan apakah ini benar-benar first time setup
  bool _isReallyFirstTimeSetup() {
    // Cek apakah user sudah memiliki data profil lengkap
    final hasFullProfile = widget.userData['fullname'] != null &&
        widget.userData['username'] != null &&
        widget.userData['bio'] != null &&
        widget.userData['university'] != null &&
        widget.userData['prodi'] != null &&
        widget.userData['gender'] != null &&
        widget.userData['hobbies'] != null &&
        widget.userData['age'] != null &&
        _getSafePhotoUrl() != null; // ✅ Gunakan safe photo URL

    return widget.isFirstTimeSetup || !hasFullProfile;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty ||
        _selectedUniversity == null ||
        _selectedProdi == null ||
        _selectedGender == null ||
        _selectedHobby == null ||
        _ageController.text.trim().isEmpty ||
        (_isReallyFirstTimeSetup() &&
            _newImage == null &&
            _getSafePhotoUrl() == null)) {
      // ✅ Gunakan safe photo URL
      _showMessage('Semua data wajib diisi dan upload foto profil!',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String? photoUrl = _getSafePhotoUrl(); // ✅ Gunakan safe photo URL

      if (_newImage != null) {
        photoUrl =
            await CloudinaryMethods().uploadImage(_newImage!, 'profilePics');
      }

      // Update user data
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullname': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'photoUrl': photoUrl,
        'university': _selectedUniversity,
        'prodi': _selectedProdi,
        'gender': _selectedGender,
        'hobbies': _selectedHobby,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'profileCompleted': true,
      });

      // Update posts with new profile info
      final posts = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (final doc in posts.docs) {
        await doc.reference.update({
          'username': _usernameController.text.trim(),
          'profImage': photoUrl,
        });
      }

      // Show success message
      _showMessage('Profil berhasil disimpan!');

      // Improved navigation handling
      await _handleNavigation();
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _showMessage('Gagal menyimpan perubahan', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;

    // Tunggu sebentar untuk memastikan data tersimpan
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (_isReallyFirstTimeSetup()) {
      // Untuk first time setup, navigate ke home dengan clear stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webScreenLayout: const WebScreenLayout(initialPage: 0),
            mobileScreenLayout: const MobileScreenLayout(initialPage: 0),
          ),
        ),
        (route) => false,
      );
    } else {
      // Untuk edit biasa, pop dengan delay
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _universityController.dispose();
    _newImage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: _isReallyFirstTimeSetup()
          ? null
          : AppBar(
              backgroundColor: const Color(0xFFF5E6D3),
              elevation: 0,
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ProfileHeader(
              nameController: _nameController,
              bioController: _bioController,
              imageData: _newImage,
              imageUrl: _getSafePhotoUrl(), // ✅ Gunakan safe photo URL
              onImageTap: _selectImage,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5E6D3),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _usernameController,
                        label: 'Username',
                        backgroundColor: const Color(0xFFE8A5C9),
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? 'Username harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      UniversityAutocomplete(
                        controller: _universityController,
                        universities: _universityList,
                        onSelected: (selection) {
                          setState(() {
                            _selectedUniversity = selection;
                            _universityController.text = selection;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedUniversity = value;
                          });
                        },
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? 'Universitas harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      CustomDropdown(
                        label: 'Program Studi',
                        value: _selectedProdi,
                        items: _prodiOptions,
                        backgroundColor: const Color(0xFFB8C5D1),
                        onChanged: (value) =>
                            setState(() => _selectedProdi = value),
                        validator: (value) => value == null
                            ? 'Program Studi harus dipilih'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      CustomDropdown(
                        label: 'Gender',
                        value: _selectedGender,
                        items: _genderOptions,
                        backgroundColor: const Color(0xFFE8A5C9),
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                        validator: (value) =>
                            value == null ? 'Gender harus dipilih' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomDropdown(
                        label: 'Hobby',
                        value: _selectedHobby,
                        items: _hobbyOptions,
                        backgroundColor: const Color(0xFFB8C5D1),
                        onChanged: (value) =>
                            setState(() => _selectedHobby = value),
                        validator: (value) =>
                            value == null ? 'Hobby harus dipilih' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _ageController,
                        label: 'Age',
                        backgroundColor: const Color(0xFFE8A5C9),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true)
                            return 'Umur harus diisi';
                          final age = int.tryParse(value!);
                          if (age == null || age <= 0)
                            return 'Umur harus berupa angka positif';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
