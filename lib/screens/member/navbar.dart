import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isSmallScreen = size.width < 375; // For iPhone SE and similar

    return Scaffold(
      body: _navigationItems[_currentIndex].screen,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: size.width * 0.05, // Responsive padding
          right: size.width * 0.05,
          bottom: bottomPadding + (isSmallScreen ? 5 : 10),
        ),
        child: Container(
          height: isSmallScreen ? 55 : 65, // Adjust height for small screens
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withAlpha(77)
                    : Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('home', 0, 'Home'),
                  _buildNavItem('swipe', 1, 'Swipe'),
                  SizedBox(width: isSmallScreen ? 20 : 30),
                  _buildNavItem('reel', 3, 'Reel'),
                  _buildNavItem('profile', 4, 'Profile'),
                ],
              ),
              Positioned(
                top: isSmallScreen ? -15 : -20,
                left: 0,
                right: 0,
                child: Center(child: _buildSOSButton(isSmallScreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconName, int index, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: isSmallScreen ? 40 : 50,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 6 : 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName == 'reel')
              SvgPicture.asset(
                'assets/${isDarkMode ? 'dark' : 'light'}/icons/$iconName.svg',
                height: isSmallScreen ? 20 : 24,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Theme.of(context).primaryColor
                      : isDarkMode
                          ? Colors.white.withAlpha(153)
                          : Colors.black.withAlpha(128),
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                _getIconData(iconName),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isDarkMode
                        ? Colors.white.withAlpha(153)
                        : Colors.black.withAlpha(128),
                size: isSmallScreen ? 20 : 24,
              ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isDarkMode
                        ? Colors.white.withAlpha(153)
                        : Colors.black.withAlpha(128),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(bool isSmallScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Handle SOS button tap
      },
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .primaryColor
                  .withAlpha(isDarkMode ? 102 : 77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.sos_outlined,
          color: Colors.white,
          size: isSmallScreen ? 25 : 30,
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      case 'swipe':
        return Icons.swipe_outlined;
      case 'profile':
        return Icons.person_outline;
      default:
        return Icons.circle_outlined;
    }
  }
}
