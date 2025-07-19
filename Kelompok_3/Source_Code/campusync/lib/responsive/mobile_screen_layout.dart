import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusync/utils/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  final int initialPage;

  const MobileScreenLayout({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout>
    with TickerProviderStateMixin {
  late int _page;
  late PageController pageController;
  late String currentUserId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Improved color scheme with better visibility
  static const Color inactiveColor =
      Color(0xFF1F2937); // Darker gray for better visibility
  static const Color activeColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color navBarBg = Color(0xFF4A90A4);
  static const Color shadowColor = Color(0x1A000000);

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    pageController = PageController(initialPage: _page);
    currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    if (_page != page) {
      setState(() {
        _page = page;
      });

      pageController.jumpToPage(page);
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  void onPageChanged(int page) {
    if (_page != page) {
      setState(() => _page = page);
    }
  }

  Widget _buildNavIcon(String imagePath, int index) {
    bool isActive = _page == index;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Transform.scale(
            scale: isActive ? _scaleAnimation.value : 1.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity:
                  isActive ? 1.0 : 0.85, // Increased opacity for inactive icons
              child: Image.asset(
                imagePath,
                width: 32, // Slightly larger for better visibility
                height: 32,
                color: isActive ? activeColor : inactiveColor,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem(String imagePath, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => navigationTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 75, // Match the container height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavIcon(imagePath, index),
              const SizedBox(height: 6),
              // Active indicator with better visibility
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: _page == index ? 24 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Enhanced background with subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor,
                  Color(0xFFEDF2F7),
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // PageView Content
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: onPageChanged,
            children: getHomeScreenItems(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarBg,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 75, // Slightly increased height for better proportions
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavigationItem('assets/icons/home.png', 0),
                _buildNavigationItem('assets/icons/search.png', 1),
                _buildNavigationItem('assets/icons/notification.png', 2),
                _buildNavigationItem('assets/icons/profile.png', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
