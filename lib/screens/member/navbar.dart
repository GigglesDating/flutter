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

class _NavigationControllerState extends State<NavigationController>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index > 2
              ? _tabController.index - 1
              : _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    // Restore system UI when disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _navigationItems.map((item) => item.screen).toList(),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: bottomPadding,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(
                size.width * 0.05,
                0,
                size.width * 0.05,
                size.height * 0.02,
              ),
              height: size.height * 0.08,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Navigation items
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor:
                        isDarkMode ? Colors.white54 : Colors.black45,
                    tabs: [
                      _buildTabWithIcon(Icons.home_outlined, 'Home', 0),
                      _buildTabWithSvg('swipe', 'Swipe', 1),
                      const Tab(icon: null, text: ''),
                      _buildTabWithSvg('snips', 'Reel', 3),
                      _buildTabWithIcon(Icons.person_outline, 'Profile', 4),
                    ],
                    onTap: (index) {
                      if (index == 2) {
                        // Handle SOS button tap
                        debugPrint('SOS Tapped');
                      } else {
                        setState(() {
                          _currentIndex = index > 2 ? index - 1 : index;
                        });
                      }
                    },
                  ),

                  // Centered SOS button
                  Positioned(
                    top: -20,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('SOS Button pressed');
                        // Handle SOS action
                      },
                      child: Container(
                        width: size.width * 0.14,
                        height: size.width * 0.14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withAlpha(100),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.sos_outlined,
                          color: Colors.white,
                          size: size.width * 0.08,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSelected = _currentIndex == index;

    return Tab(
      height: size.height * 0.07,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: size.width * 0.06,
            color: isSelected
                ? Theme.of(context).primaryColor
                : isDarkMode
                    ? Colors.white54
                    : Colors.black45,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: size.width * 0.03),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithSvg(String icon, String label, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSelected = _currentIndex == index;

    return Tab(
      height: size.height * 0.07,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/nav_bar/$icon.svg',
            height: size.width * 0.06,
            colorFilter: ColorFilter.mode(
              isSelected
                  ? Theme.of(context).primaryColor
                  : isDarkMode
                      ? Colors.white54
                      : Colors.black45,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: size.width * 0.03),
          ),
        ],
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
