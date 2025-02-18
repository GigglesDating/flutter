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
            // Main Card
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
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            // User Info Section
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_profiles[_currentIndex]['name']}, ${_profiles[_currentIndex]['age']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on, // Flutter's native location icon
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _profiles[_currentIndex]['location'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .info_outline, // Flutter's native info icon for bio
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _profiles[_currentIndex]['bio'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
