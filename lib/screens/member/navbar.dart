import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    // Use a small fixed padding instead of system navigation height
    const bottomSafeArea = 8.0;

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
              bottom: bottomSafeArea,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Main navigation bar
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
                    ),
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.home_outlined, 0),
                        _buildNavItem(Icons.group_outlined, 1),
                        const SizedBox(width: 48),
                        _buildNavItem(Icons.movie_outlined, 3),
                        _buildProfileItem(4),
                      ],
                    ),
                  ),

                  // Floating SOS button
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5C0E5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA5C0E5).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            debugPrint('SOS Button pressed');
                          },
                          customBorder: const CircleBorder(),
                          child: const Center(
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 30,
                            ),
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

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      onPressed: () => setState(() => _currentIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        size: 28,
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
