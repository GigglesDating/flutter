import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:math';
import '../barrel.dart';
import 'dart:ui';

// Define enum at the top level, before the class
enum SwipeDirection { left, right, up, none }

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with API data for user profiles
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

  // At the top of the class, add these constants
  final double tileWidth = 130.0; // Base width
  final double tileHeight =
      170.0; // To maintain 13:17 ratio (130 * 17/13 ≈ 170)

  @override
  void initState() {
    super.initState();
    // TODO: Implement API call to fetch initial profiles
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTilePlacements();
  }

  void _initializeTilePlacements() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    // Calculate safe areas
    final verticalSafeArea = size.height * 0.205;

    // Calculate horizontal boundaries
    final leftBoundary = size.width * 0.05; // 5% from left
    final rightBoundary = size.width * 0.95 - tileWidth; // 5% from right

    // Calculate vertical boundaries (keeping existing 65% middle area)
    final topBoundary = verticalSafeArea;
    final bottomBoundary = size.height - verticalSafeArea - tileHeight;

    setState(() {
      _tilePlacements = List.generate(
        _profiles[_currentIndex]['images'].length - 1,
        (index) => Offset(
          leftBoundary + _random.nextDouble() * (rightBoundary - leftBoundary),
          topBoundary + _random.nextDouble() * (bottomBoundary - topBoundary),
        ),
      );
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final swipedProfile = _profiles[previousIndex];

    switch (direction) {
      case CardSwiperDirection.left:
        // Always load next profile on left swipe
        setState(() {
          _showImageTiles = false;
          _currentIndex = currentIndex ?? _currentIndex;
        });
        break;

      case CardSwiperDirection.top:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfile()),
        ).then((_) {
          // Keep same profile when returning from profile view
          setState(() {
            _currentIndex = previousIndex;
          });
        });
        break;

      case CardSwiperDirection.right:
        Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PromptsScreen(profile: swipedProfile),
          ),
        ).then((shouldChangeProfile) {
          if (shouldChangeProfile == true) {
            // Change profile if:
            // 1. User selected a prompt
            // 2. User sent custom message
            // 3. User reported the profile
            setState(() {
              _showImageTiles = false;
              _currentIndex = currentIndex ?? _currentIndex;
            });
          } else {
            // Keep same profile if:
            // 1. User hit back button
            setState(() {
              _currentIndex = previousIndex;
              _showImageTiles = true; // Show tiles again for same profile
            });
          }
        });
        break;

      case CardSwiperDirection.bottom:
        // Handle bottom swipe - for now, treat it like left swipe
        setState(() {
          _showImageTiles = false;
          _currentIndex = currentIndex ?? _currentIndex;
        });
        break;

      case CardSwiperDirection.none:
        // Handle the none case
        setState(() {
          _currentIndex = previousIndex;
        });
        break;
    }
    return true;
  }

  void _handleReportComplete() {
    // Close report sheet and move to next profile
    Navigator.pop(context);
    _cardSwiperController.swipe(CardSwiperDirection.left);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Card Swiper
          CardSwiper(
            controller: _cardSwiperController,
            cardsCount: _profiles.length,
            padding: EdgeInsets.zero,
            allowedSwipeDirection: AllowedSwipeDirection.only(
              up: true,
              right: true,
              left: true,
            ),
            onSwipe: _onSwipe,
            cardBuilder: (
              context,
              index,
              percentThresholdX,
              percentThresholdY,
            ) {
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
                    // Main profile image
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
                    // Show tiles for current card only
                    if (_showImageTiles && index == _currentIndex)
                      ...(_buildImageTiles()),
                    // Card info overlay
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
                  onTap: () {
                    // Use the new navigation method
                    NavigationController.navigateToTab(context, 0);
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withAlpha(51),
                      enableDrag: true,
                      isDismissible: true,
                      useSafeArea: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.9,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 15,
                                sigmaY: 15,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor.withAlpha(128),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: SwipeFilterPage(),
                              ),
                            ),
                          ),
                        ),
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
                      Icons.tune,
                      color: Colors.white,
                      size: size.width * 0.07,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImageTiles() {
    return List.generate(
      _profiles[_currentIndex]['images'].length - 1,
      (index) => Positioned(
        left: _tilePlacements[index].dx,
        top: _tilePlacements[index].dy,
        child: Draggable(
          feedback: Container(
            width: tileWidth,
            height: tileHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(
                  _profiles[_currentIndex]['images'][index + 1],
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Container(
              width: tileWidth,
              height: tileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    _profiles[_currentIndex]['images'][index + 1],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          onDragEnd: (details) {
            setState(() {
              _tilePlacements[index] = Offset(
                details.offset.dx,
                details.offset.dy - MediaQuery.of(context).padding.top,
              );
            });
          },
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
              width: tileWidth,
              height: tileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    _profiles[_currentIndex]['images'][index + 1],
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
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
        SizedBox(height: size.height * 0.02),

        // Name and Age with Report Button (new combined row)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Report Button
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ReportSheet(
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                    screenWidth: size.width,
                    reportType: ReportType.user,
                    onReportComplete: _handleReportComplete,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(size.width * 0.01),
                margin: EdgeInsets.only(right: size.width * 0.02),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(26),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: size.width * 0.07,
                ),
              ),
            ),
            // Name and Age Text
            Text(
              '${_profiles[index]['name']}, ${_profiles[index]['age']}',
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01), //0.007
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white,
              size: size.width * 0.05,
            ),
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
