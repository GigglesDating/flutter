import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Sarah',
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
      'name': 'Sarah',
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

  int _currentIndex = 0;
  late AnimationController _cardController;
  Offset _cardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
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
            // Main Card with Info
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _cardOffset += details.delta;
                });
              },
              onPanEnd: (details) {
                if (_cardOffset.dx.abs() > 100) {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _profiles.length;
                    _cardOffset = Offset.zero;
                  });
                } else {
                  setState(() {
                    _cardOffset = Offset.zero;
                  });
                }
              },
              child: Transform.translate(
                offset: _cardOffset,
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_profiles[_currentIndex]['images'][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCardInfo(_currentIndex),
                      SizedBox(
                          height: size.height * 0.1), // Extra bottom spacing
                    ],
                  ),
                ),
              ),
            ),

            // Top Action Buttons
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(26),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new, // Flutter's native back icon
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(26),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/swipe/filters.svg',
                    width: 38,
                    height: 38,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(int index) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: screenSize.width * 0.05,
            right: screenSize.width * 0.05,
            bottom: screenSize.height * 0.005,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_profiles[index]['name']}, ${_profiles[index]['age']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.07,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: screenSize.width * 0.045,
                  ),
                  SizedBox(width: screenSize.width * 0.01),
                  Text(
                    _profiles[index]['location'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/swipe/bio.png',
                    width: screenSize.width * 0.075,
                    height: screenSize.width * 0.075,
                    color: Colors.white,
                  ),
                  SizedBox(width: screenSize.width * 0.025),
                  Expanded(
                    child: Text(
                      _profiles[index]['bio'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.04,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
