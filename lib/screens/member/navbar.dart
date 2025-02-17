import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import '../placeholder_template.dart';
import '../barrel.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => NavigationControllerState();
}

class NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;
  bool _showNavBar = true;

  @override
  void initState() {
    super.initState();
    _hideSystemBars();
    // Show nav bar by default
    _showNavBar = true;
  }

  void _hideSystemBars() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // This hides both status bar and navigation bar
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI when disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Only show nav bar if not on SwipeScreen
    _showNavBar = _currentIndex != 1; // 1 is the index for SwipeScreen

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            // Main content
            IndexedStack(
              index: _currentIndex,
              children: _navigationItems.map((item) => item.screen).toList(),
            ),

            // Navigation bar with SOS button
            if (_showNavBar)
              Positioned(
                bottom: bottomPadding,
                left: 0,
                right: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Main navigation bar
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.02,
                      ),
                      height: size.height * 0.08,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: NavBarClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withAlpha(230)
                                    : Colors.black.withAlpha(230),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(26),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNavItem(0),
                              _buildNavItem(1),
                              _buildNavItem(2),
                              _buildNavItem(3),
                              _buildProfileItem(4),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Floating SOS button with final positioning
                    Positioned(
                      top: -(size.height * 0.005),
                      child: GestureDetector(
                        onTap: () => debugPrint('SOS Button pressed'),
                        child: Container(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(240, 113, 234, 242),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(239, 20, 20, 20)
                                    .withAlpha(77),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/nav_bar/sos.gif',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define icon paths based on index
    String getIconPath(int index) {
      switch (index) {
        case 0:
          return 'assets/icons/nav_bar/home.svg';
        case 1:
          return 'assets/icons/nav_bar/swipe.svg';
        case 3:
          return 'assets/icons/nav_bar/snips.svg';
        default:
          return 'assets/icons/nav_bar/home.svg';
      }
    }

    // Skip rendering for index 2 as it's handled by the floating SOS button
    if (index == 2) {
      return const SizedBox(width: 60);
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Colors.black : Colors.white,
        ),
        child: Center(
          child: SvgPicture.asset(
            getIconPath(index),
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              isSelected
                  ? Colors.green
                  : (isDarkMode ? Colors.white : Colors.black),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/tempImages/users/user1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  final List<({String label, Widget screen})> _navigationItems = [
    (
      label: 'Home',
      screen: const HomeTab(),
    ),
    (
      label: 'Swipe',
      screen: const SwipeScreen(),
    ),
    (
      label: 'SOS',
      screen: const PlaceholderScreen(
        screenName: 'SOS',
        message: 'SOS Screen',
      ),
    ),
    (
      label: 'Reel',
      screen: const PlaceholderScreen(
        screenName: 'Reel',
        message: 'Reel Screen',
      ),
    ),
    (
      label: 'Profile',
      screen: const PlaceholderScreen(
        screenName: 'Profile',
        message: 'Profile Screen',
      ),
    ),
  ];

  void _updateSystemUI(int index) {
    if (index == 1) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      _showNavBar = index != 1;
      _updateSystemUI(index);
    });
  }

  void hideNavBar() {
    setState(() {
      _showNavBar = false;
    });
  }

  void showNavBar() {
    setState(() {
      _showNavBar = true;
    });
  }
}

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Calculate dimensions
    final width = size.width;
    final height = size.height;
    final center = width / 2;
    final cutoutRadius = 35.0;

    // Start from top-left
    path.moveTo(0, 0);

    // Line to start of left curve
    path.lineTo(center - cutoutRadius, 0);

    // Create the curved cutout using quadratic bezier curves
    // Left curve
    path.quadraticBezierTo(
        center - cutoutRadius / 2,
        height / 3, // control point
        center - cutoutRadius / 2,
        height // end point
        );

    // Bottom curve
    path.quadraticBezierTo(
        center,
        height - 5, // control point
        center + cutoutRadius / 2,
        height // end point
        );

    // Right curve
    path.quadraticBezierTo(
        center + cutoutRadius / 2,
        height / 3, // control point
        center + cutoutRadius,
        0 // end point
        );

    // Complete the shape
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
