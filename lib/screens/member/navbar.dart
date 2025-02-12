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
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _hideSystemBars();
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
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withAlpha(230)
                          : Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0),
                        _buildNavItem(1),
                        SizedBox(
                            width: size.width * 0.15), // Space for SOS button
                        _buildNavItem(3),
                        _buildProfileItem(4),
                      ],
                    ),
                  ),

                  // Floating SOS button with final positioning
                  Positioned(
                    top: -(size.height *
                        0.005), // Updated to the optimal position
                    child: Container(
                      width: size.width * 0.15,
                      height: size.width * 0.15,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5C0E5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA5C0E5).withAlpha(77),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => debugPrint('SOS Button pressed'),
                          customBorder: const CircleBorder(),
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: size.width * 0.06,
                          ),
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
        case 2:
          return 'assets/icons/nav_bar/snips.svg';
        default:
          return 'assets/icons/nav_bar/home.svg'; // fallback
      }
    }

    // For SOS button specifically
    if (index == 3) {
      return Image.asset(
        'assets/icons/nav_bar/sos.gif',
        width: 40,
        height: 40,
        color: isDarkMode ? Colors.white : const Color.fromARGB(255, 255, 0, 0),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: SvgPicture.asset(
        getIconPath(index),
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(
          isSelected
              ? Colors.green
              : (isDarkMode ? Colors.white : Colors.black),
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildProfileItem(int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 35,
        height: 35,
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
      screen: const PlaceholderScreen(
        screenName: 'Swipe',
        message: 'Swipe Screen',
      ),
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
}
