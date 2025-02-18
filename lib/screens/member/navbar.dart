import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import '../placeholder_template.dart';
import '../barrel.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => NavigationControllerState();
}

class NavigationControllerState extends State<NavigationController>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showNavBar = true;
  bool _isSOSActive = false;
  late Size size;
  double _rotationValue = 0.0;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _hideSystemBars();
    // Show nav bar by default
    _showNavBar = true;
    _startRotationTimer();
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

  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_showNavBar && mounted) {
        setState(() {
          _rotationValue = _rotationValue + 1; // Full rotation
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    // Restore system UI when disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                        vertical: size.height * 0.015,
                      ),
                      height: size.height * 0.075,
                      child: Stack(
                        children: [
                          // SVG Background
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/app/nav.svg',
                              fit: BoxFit.fill,
                              colorFilter: ColorFilter.mode(
                                isDarkMode ? Colors.black : Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          // Icons Row
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNavItem(0),
                                _buildNavItem(1),
                                _buildNavItem(2),
                                _buildNavItem(3),
                                _buildProfileItem(4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating SOS button
                    Positioned(
                      top: -(size.height *
                          0.02), // Adjust this value to move the button up/down
                      child: _buildSOSButton(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconSize = size.width * 0.1;

    if (index == 2) {
      return SizedBox(width: iconSize * 1.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? iconSize * 1.2 : iconSize,
      height: isSelected ? iconSize * 1.2 : iconSize,
      child: GestureDetector(
        onTap: () {
          if (_currentIndex != index) {
            // Only animate if we're switching to this tab
            setState(() {
              _rotationValue = _rotationValue + 1; // One full rotation
              _currentIndex = index;
            });

            // Reset rotation after animation
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentIndex == index) {
                setState(() => _rotationValue = 0);
              }
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode
                ? Colors.white.withAlpha(38)
                : Colors.black.withAlpha(26),
          ),
          child: Center(
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 500),
              turns: isSelected && _currentIndex == index ? _rotationValue : 0,
              child: SvgPicture.asset(
                getIconPath(index),
                width: iconSize * 0.55,
                height: iconSize * 0.55,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Colors.green
                      : (isDarkMode ? Colors.white : Colors.black),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(int index) {
    final isSelected = _currentIndex == index;
    final iconSize = size.width * 0.1; // Match nav item size

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: iconSize,
        height: iconSize,
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

  Widget _buildSOSButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleSOSPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isSOSActive ? size.width * 0.2 : size.width * 0.17,
        height: _isSOSActive ? size.width * 0.2 : size.width * 0.17,
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF121212)
              : const Color.fromARGB(239, 239, 241, 241),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(239, 20, 20, 20).withAlpha(77),
              blurRadius: size.width * 0.02,
              spreadRadius: size.width * 0.002,
              offset: Offset(0, size.width * 0.01),
            ),
          ],
        ),
        child: _isSOSActive
            ? ClipRRect(
                borderRadius: BorderRadius.circular(size.width * 0.17),
                child: OverflowBox(
                  maxWidth: size.width * 0.3,
                  maxHeight: size.width * 0.3,
                  child: Image.asset(
                    'assets/icons/nav_bar/sos.gif',
                    fit: BoxFit.cover,
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                  ),
                ),
              )
            : Center(
                child: SvgPicture.asset(
                  'assets/icons/nav_bar/sos.svg',
                  width: size.width * 0.13,
                  height: size.width * 0.13,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
      ),
    );
  }

  final List<({String label, Widget screen})> _navigationItems = [
    (label: 'Home', screen: const HomeTab()),
    (label: 'Swipe', screen: const SwipeScreen()),
    (
      label: 'SOS',
      screen: const PlaceholderScreen(screenName: 'SOS', message: 'SOS Screen'),
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

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      _showNavBar = index != 1;

      // Always ensure immersive mode
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [], // Hide both status and navigation bars
      );
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

  void _handleSOSPress() {
    if (_isSOSActive) {
      // If SOS is currently active, stop everything immediately
      Vibration.cancel();
      setState(() => _isSOSActive = false);
    } else {
      // Start new SOS sequence
      setState(() => _isSOSActive = true);

      Future.delayed(const Duration(milliseconds: 500), () async {
        while (_isSOSActive) {
          // S (... = 3 short vibrations)
          for (var i = 0; i < 3; i++) {
            if (!_isSOSActive) return; // Check before each vibration
            await Vibration.vibrate(duration: 200, amplitude: 255);
            await Future.delayed(const Duration(milliseconds: 200));
          }
          if (!_isSOSActive) return;
          await Future.delayed(const Duration(milliseconds: 400));

          // O (--- = 3 long vibrations)
          for (var i = 0; i < 3; i++) {
            if (!_isSOSActive) return; // Check before each vibration
            await Vibration.vibrate(duration: 500, amplitude: 255);
            await Future.delayed(const Duration(milliseconds: 200));
          }
          if (!_isSOSActive) return;
          await Future.delayed(const Duration(milliseconds: 400));

          // S (... = 3 short vibrations)
          for (var i = 0; i < 3; i++) {
            if (!_isSOSActive) return; // Check before each vibration
            await Vibration.vibrate(duration: 200, amplitude: 255);
            await Future.delayed(const Duration(milliseconds: 200));
          }

          if (!_isSOSActive) return;
          await Future.delayed(const Duration(seconds: 1));
        }
      });
    }
  }
}
