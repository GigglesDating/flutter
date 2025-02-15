import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'navbar.dart';
import 'dart:math';

// Move ImageTile class outside
class ImageTile {
  final String imagePath;
  final double x;
  final double y;
  final double rotation;

  ImageTile({
    required this.imagePath,
    required this.x,
    required this.y,
    required this.rotation,
  });
}

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _dummyImages = [
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
  ];

  int _currentImageIndex = 0;
  bool _showImageTiles = false;
  bool _showSwipeIndicator = false;
  String _swipeDirection = '';
  late AnimationController _guideController;
  bool _showGuide = true;

  final List<ImageTile> _imageTiles = [];
  bool _showTiles = false;

  @override
  void initState() {
    super.initState();
    _guideController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Hide guide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showGuide = false);
      }
    });
  }

  @override
  void dispose() {
    // Restore system UI and nav bar when disposing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (context.mounted) {
      final navigationState =
          context.findAncestorStateOfType<NavigationControllerState>();
      if (navigationState != null) {
        navigationState.showNavBar();
      }
    }
    super.dispose();
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx > 10) {
      _showSwipeIndicator = true;
      _swipeDirection = 'right';
    } else if (details.delta.dx < -10) {
      _showSwipeIndicator = true;
      _swipeDirection = 'left';
    } else if (details.delta.dy < -10) {
      _showSwipeIndicator = true;
      _swipeDirection = 'up';
    }
    setState(() {});

    // Hide indicator after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSwipeIndicator = false;
          _swipeDirection = '';
        });
      }
    });
  }

  void _generateImageTiles() {
    _imageTiles.clear();
    final random = Random();

    for (int i = 1; i < _dummyImages.length; i++) {
      _imageTiles.add(
        ImageTile(
          imagePath: _dummyImages[i],
          x: random.nextDouble() * 0.6 - 0.3,
          y: random.nextDouble() * 0.45 - 0.225,
          rotation: (random.nextDouble() - 0.5) * 0.5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!_showTiles) _generateImageTiles();
          setState(() => _showTiles = !_showTiles);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              _dummyImages[_currentImageIndex],
              fit: BoxFit.cover,
            ),

            // Image Tiles
            if (_showTiles)
              ...List.generate(_imageTiles.length, (index) {
                final tile = _imageTiles[index];
                return Positioned(
                  left: size.width * (0.5 + tile.x) - (size.width * 0.25),
                  top: size.height * (0.5 + tile.y) - (size.width * 0.25),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final tempImage = _dummyImages[_currentImageIndex];
                        _dummyImages[_currentImageIndex] = tile.imagePath;
                        _dummyImages[_dummyImages.indexOf(tile.imagePath)] =
                            tempImage;
                        _showTiles = false;
                      });
                      HapticFeedback.mediumImpact();
                    },
                    child: Transform.rotate(
                      angle: tile.rotation,
                      child: Container(
                        width: size.width * 0.5,
                        height: size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(tile.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // User Name Overlay
            Positioned(
              bottom: size.height * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(179),
                      ],
                    ),
                  ),
                  child: Text(
                    'Dhwani Tripati, 26',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(128),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Navigation Bar
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () {
                        // Restore system UI
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);
                        // Navigate back to home
                        if (context.mounted) {
                          final navigationState =
                              context.findAncestorStateOfType<
                                  NavigationControllerState>();
                          if (navigationState != null) {
                            navigationState.setState(() {
                              navigationState.setCurrentIndex(0);
                            });
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Filter Button
                    IconButton(
                      onPressed: null, // Disabled for now
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Swipe Indicators
            if (_showSwipeIndicator)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showSwipeIndicator ? 1.0 : 0.0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      _swipeDirection.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Gesture Guide
            if (_showGuide) _buildGestureGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureGuide() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _showGuide ? 1.0 : 0.0,
      child: Stack(
        children: [
          // Right swipe guide
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height * 0.5,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: const Offset(1, 0),
              ).animate(_guideController),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Left swipe guide
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.5,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: const Offset(-1, 0),
              ).animate(_guideController),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Up swipe guide
          Positioned(
            bottom: 100,
            left: MediaQuery.of(context).size.width * 0.5 - 20,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: const Offset(0, -1),
              ).animate(_guideController),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
