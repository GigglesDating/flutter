import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../barrel.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTabState();
}

class _SnipTabState extends State<SnipTab> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isTabMounted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _snips = [
    {
      'videoUrl': 'assets/videos/1.mp4',
      'userInfo': {
        'username': 'Sarah Something',
        'profileImage': 'assets/tempImages/users/user1.png',
        'description': 'This is my first snip! 🎉',
      }
    },
    {
      'videoUrl': 'assets/videos/2.mp4',
      'userInfo': {
        'username': 'John Doe',
        'profileImage': 'assets/tempImages/users/user2.png',
        'description': 'Check out this cool effect! ✨',
      }
    },
    {
      'videoUrl': 'assets/videos/3.mp4',
      'userInfo': {
        'username': 'Jane Smith',
        'profileImage': 'assets/tempImages/users/user3.png',
        'description': 'Having fun with Snips 🎵',
      }
    },
  ];

  @override
  void initState() {
    super.initState();
    _isTabMounted = true;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemCount: _snips.length,
            itemBuilder: (context, index) {
              if ((index - _currentPage).abs() > 1) {
                return const SizedBox.shrink();
              }

              return SnipCard(
                key: ValueKey('snip_$index'),
                videoUrl: _snips[index]['videoUrl'],
                userInfo: _snips[index]['userInfo'],
                isVisible: index == _currentPage,
                animation: _animation,
              );
            },
          ),
          // Add your header UI here
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
