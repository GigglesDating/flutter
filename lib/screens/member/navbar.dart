import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../barrel.dart';

import '../placeholder_template.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: _navigationItems[_currentIndex].screen,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('home', 0),
              _buildNavItem('swipe', 1),
              _buildSOSButton(),
              _buildNavItem('reel', 3),
              _buildNavItem('profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconName, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconName == 'reel')
            SvgPicture.asset(
              isDarkMode
                  ? 'assets/dark/icons/$iconName.svg'
                  : 'assets/light/icons/$iconName.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? Theme.of(context).primaryColor
                    : isDarkMode
                        ? Colors.white60
                        : Colors.black54,
                BlendMode.srcIn,
              ),
            )
          else
            Image.asset(
              isDarkMode
                  ? 'assets/dark/icons/$iconName.png'
                  : 'assets/light/icons/$iconName.png',
              height: 24,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isDarkMode
                      ? Colors.white60
                      : Colors.black54,
            ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/dark/icons/sos.png'
              : 'assets/light/icons/sos.png',
          height: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  final List<({String label, Widget screen})> _navigationItems = [
    (
      label: 'Home',
      screen: const PlaceholderScreen(
        screenName: 'Home',
        message: 'Home Screen',
      ),
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
