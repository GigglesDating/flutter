import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import '../barrel.dart';

// Define enum at the top level, before the class
enum SwipeDirection { left, right, up, none }

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Sarah Something',
      'age': 24,
      'location': 'Bangalore',
      'bio':
          'Adventure seeker & coffee lover. Always up for trying new things and meeting new people.',
      'images': [
        'assets/tempImages/users/usera/1.png',
        'assets/tempImages/users/usera/2.png',
        'assets/tempImages/users/usera/3.png',
        'assets/tempImages/users/usera/4.png',
      ],
    },
    {
      'name': 'Sarah Murray',
      'age': 24,
      'location': 'Bangalore',
      'bio':
          'Adventure seeker & coffee lover. Always up for trying new things and meeting new people.',
      'images': [
        'assets/tempImages/users/userb/1.png',
        'assets/tempImages/users/userb/2.png',
        'assets/tempImages/users/userb/3.png',
        'assets/tempImages/users/userb/4.png',
      ],
    },
    // Add more profiles as needed
  ];

  final CardSwiperController _cardSwiperController = CardSwiperController();
  bool _showImageTiles = false;
  int _currentIndex = 0;
  final Random _random = Random();
  List<Offset> _tilePlacements = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTilePlacements();
  }

  void _initializeTilePlacements() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    // Calculate the safe area (17.5% from top and bottom)
    final verticalSafeArea = size.height * 0.205;
    final horizontalSafeArea = size.width * 0.1;

    final availableHeight = size.height * 0.45; // Middle 65%
    final availableWidth = size.width * 0.8; // Middle 80%

    setState(() {
      _tilePlacements = List.generate(
        _profiles[_currentIndex]['images'].length - 1,
        (index) => Offset(
          horizontalSafeArea + _random.nextDouble() * availableWidth,
          verticalSafeArea + _random.nextDouble() * availableHeight,
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    setState(() {
      _showImageTiles = false;
      _currentIndex = currentIndex ?? _currentIndex;
    });

    switch (direction) {
      case CardSwiperDirection.top:
        // Navigate to profile
        break;
      case CardSwiperDirection.left:
        // Dislike
        break;
      case CardSwiperDirection.right:
        // Like
        break;
      default:
        break;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main Card Swiper
            CardSwiper(
              controller: _cardSwiperController,
              cardsCount: _profiles.length,
              padding: EdgeInsets.zero,
              allowedSwipeDirection:
                  AllowedSwipeDirection.only(up: true, right: true, left: true),
              onSwipe: _onSwipe,
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _showImageTiles = !_showImageTiles;
                      _currentIndex = index;
                      if (_showImageTiles) _initializeTilePlacements();
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: size.width,
                        height: size.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_profiles[index]['images'][0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildCardInfo(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Navigation Buttons at the top
            Positioned(
              top: MediaQuery.of(context).padding.top + size.height * 0.02,
              left: size.width * 0.04,
              right: size.width * 0.04,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () async {
                      // First, ensure we're in immersive mode
                      await SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky,
                        overlays: [],
                      );

                      if (!mounted) return;

                      // Then navigate with replacement
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const NavigationController(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.01),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withAlpha(26),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: size.width * 0.07,
                      ),
                    ),
                  ),
                  // Filter Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/swipe-filter');
                    },
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withAlpha(26),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/swipe/filters.svg',
                        width: size.width * 0.07,
                        height: size.width * 0.07,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showImageTiles) ..._buildImageTiles(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildImageTiles() {
    return List.generate(
      _profiles[_currentIndex]['images'].length - 1,
      (index) => Positioned(
        left: _tilePlacements[index].dx,
        top: _tilePlacements[index].dy,
        child: GestureDetector(
          onTap: () {
            setState(() {
              final temp = _profiles[_currentIndex]['images'][0];
              _profiles[_currentIndex]['images'][0] =
                  _profiles[_currentIndex]['images'][index + 1];
              _profiles[_currentIndex]['images'][index + 1] = temp;
              _showImageTiles = false;
            });
          },
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image:
                    AssetImage(_profiles[_currentIndex]['images'][index + 1]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo(int index) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added extra spacing at the top
        SizedBox(
            height: size.height *
                0.02), // Adjust this value as needed (2% of screen height)

        // Name and Age
        Center(
          child: Text(
            '${_profiles[index]['name']}, ${_profiles[index]['age']}',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.01), //0.007

        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on,
                color: Colors.white, size: size.width * 0.05),
            SizedBox(width: size.width * 0.02),
            Text(
              _profiles[index]['location'],
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Bio section
        SizedBox(height: size.height * 0.03),
        Row(
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/swipe/bio.png',
                width: size.width * 0.09, // .09
                height: size.width * 0.09, // .09
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text(
                _profiles[index]['bio'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Bottom spacing
        SizedBox(height: size.height * 0.05), //0.08
      ],
    );
  }
}
