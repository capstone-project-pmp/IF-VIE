// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import '../models/user_profile_data.dart';
import '../widgets/profile_widgets.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver, RouteAware {
  ProfileState _state = ProfileState();
  String? _currentUserUid;
  Timer? _debounceTimer;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes if RouteObserver is available
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      // routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _authSubscription?.cancel();
    _userDataSubscription?.cancel();
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen
    print('ProfileScreen: didPopNext - refreshing data');
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('ProfileScreen: App resumed - refreshing data');
      _loadData();
    }
  }

  void _initializeAuth() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _navigateToLogin();
      } else {
        _currentUserUid = user.uid;
        _setupUserDataStream();
      }
    });
  }

  void _setupUserDataStream() {
    // Cancel existing subscription
    _userDataSubscription?.cancel();

    // Set up real-time listener for user data
    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots()
        .listen(
      (DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          try {
            final userData = UserProfileData.fromMap(
                snapshot.data() as Map<String, dynamic>);

            // Check if current user is following this profile
            final isFollowing = _currentUserUid != null &&
                userData.followers.contains(_currentUserUid);

            print(
                'ProfileScreen: Real-time update - isFollowing: $isFollowing');
            print('ProfileScreen: Followers: ${userData.followers}');
            print('ProfileScreen: Current user: $_currentUserUid');

            setState(() {
              _state = _state.copyWith(
                isLoading: false,
                userData: userData,
                isFollowing: isFollowing,
                error: null,
                // Reset loading state ketika mendapat update dari Firestore
                isFollowLoading: false,
              );
            });
          } catch (e) {
            print('Error parsing user data: $e');
            setState(() {
              _state = _state.copyWith(
                isLoading: false,
                error: 'Error parsing user data: ${e.toString()}',
                isFollowLoading: false,
              );
            });
          }
        } else if (!snapshot.exists && mounted) {
          setState(() {
            _state = _state.copyWith(
              isLoading: false,
              error: 'User tidak ditemukan',
              isFollowLoading: false,
            );
          });
        }
      },
      onError: (error) {
        print('Error listening to user data: $error');
        if (mounted) {
          setState(() {
            _state = _state.copyWith(
              isLoading: false,
              error: 'Error loading profile: ${error.toString()}',
              isFollowLoading: false,
            );
          });
          _showSnackBar('Error loading profile: ${error.toString()}');
        }
      },
    );
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final userData = await _loadUserData();

      if (!mounted) return;

      if (userData == null) {
        _showErrorAndPop('User tidak ditemukan');
        return;
      }

      final isFollowing = _currentUserUid != null &&
          userData.followers.contains(_currentUserUid);

      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          userData: userData,
          isFollowing: isFollowing,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            error: 'Error loading profile: ${e.toString()}',
          );
        });
        _showSnackBar('Error loading profile: ${e.toString()}');
      }
    }
  }

  Future<UserProfileData?> _loadUserData() async {
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get(const GetOptions(source: Source.server));

    if (!userSnap.exists) return null;

    return UserProfileData.fromMap(userSnap.data()!);
  }

  void _showErrorAndPop(String message) {
    _showSnackBar(message);
    Navigator.pop(context, true);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      showSnackBar(message, context);
    }
  }

  void _handleFollowAction() {
    if (_state.isFollowLoading || _currentUserUid == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      _executeFollowAction,
    );
  }

  Future<void> _executeFollowAction() async {
    if (!mounted || _state.userData == null || _currentUserUid == null) return;

    print(
        'ProfileScreen: Executing follow action - current isFollowing: ${_state.isFollowing}');

    setState(() {
      _state = _state.copyWith(isFollowLoading: true);
    });

    try {
      // Panggil followUser method
      await FirestoreMethods().followUser(
        _currentUserUid!,
        _state.userData!.uid,
      );
      print('ProfileScreen: Follow action executed');

      // Jangan update state secara manual, biarkan stream listener yang handle
      // karena stream akan otomatis update ketika data berubah di Firestore

      // Hanya update loading state saja
      if (mounted) {
        // Loading state akan direset oleh stream listener
        // jadi kita tidak perlu set isFollowLoading = false di sini
      }
    } catch (e) {
      print('ProfileScreen: Follow action error: $e');
      if (mounted) {
        setState(() {
          _state = _state.copyWith(isFollowLoading: false);
        });
        _showSnackBar('Error following user: ${e.toString()}');
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Error logging out: ${e.toString()}');
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_state.userData == null) return;

    print('ProfileScreen: Navigating to edit profile...');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: _state.userData!.toMap()),
      ),
    );

    print('ProfileScreen: Returned from edit profile with result: $result');

    if (result == true && mounted) {
      print('ProfileScreen: Forcing data refresh...');

      // Force refresh dengan beberapa metode
      setState(() {
        _state = _state.copyWith(isLoading: true);
      });

      // Tambahkan delay kecil untuk memastikan Firestore ter-update
      await Future.delayed(const Duration(milliseconds: 500));

      // Force reload dari server
      await _loadData();

      // Re-setup stream untuk memastikan real-time updates
      _setupUserDataStream();
    }
  }

  void _navigateToChat() {
    if (_currentUserUid == null) return;

    final chatId = _currentUserUid!.compareTo(widget.uid) < 0
        ? '$_currentUserUid\_${widget.uid}'
        : '${widget.uid}\_$_currentUserUid';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId),
      ),
    );
  }

  // Method untuk force refresh (bisa dipanggil dari luar)
  void forceRefresh() {
    print('ProfileScreen: Force refresh requested');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = _currentUserUid == widget.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7F3),
      appBar: ProfileAppBar(isCurrentUser: isCurrentUser),
      body: _buildBody(isCurrentUser),
    );
  }

  Widget _buildBody(bool isCurrentUser) {
    if (_state.isLoading) {
      return const ProfileLoadingState();
    }

    if (_state.error != null) {
      return ProfileErrorState(
        error: _state.error,
        onRetry: _loadData,
      );
    }

    if (_state.userData == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ProfileConstants.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ProfileCard(
              userData: _state.userData!,
              followerCount: _state.userData!.followers.length,
              isCurrentUser: isCurrentUser,
              isFollowing: _state.isFollowing,
              isFollowLoading: _state.isFollowLoading,
              onEditProfile: isCurrentUser ? _navigateToEditProfile : null,
              onFollowToggle: !isCurrentUser ? _handleFollowAction : null,
              onChat: !isCurrentUser ? _navigateToChat : null,
            ),
            const SizedBox(height: 16),
            ProfileInfoCard(userData: _state.userData!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileState {
  final bool isLoading;
  final bool isFollowLoading;
  final UserProfileData? userData;
  final bool isFollowing;
  final String? error;

  ProfileState({
    this.isLoading = false,
    this.isFollowLoading = false,
    this.userData,
    this.isFollowing = false,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isFollowLoading,
    UserProfileData? userData,
    bool? isFollowing,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      userData: userData ?? this.userData,
      isFollowing: isFollowing ?? this.isFollowing,
      error: error ?? this.error,
    );
  }
}
