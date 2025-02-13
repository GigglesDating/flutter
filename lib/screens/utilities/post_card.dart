import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isDarkMode;

  const PostCard({
    super.key,
    required this.post,
    required this.isDarkMode,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.06,
        top: screenHeight * 0.060,
      ),
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Center the main post container
          Center(
            child: GestureDetector(
              onDoubleTap: () {
                HapticFeedback.lightImpact();
                setState(() => isLiked = true);
                _animationController
                    .forward()
                    .then((_) => _animationController.reverse());
              },
              child: Container(
                width: screenWidth * 0.95,
                height: screenWidth * 1.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(widget.post['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Profile Picture Overlay
          Positioned(
            top: -(screenHeight *
                0.04), // 4% of screen height for overlay position
            left: screenWidth * 0.1, // 5% of screen width from left
            child: Container(
              padding: EdgeInsets.all(screenWidth *
                  0.008), // 0.8% of screen width for border padding
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.black.withAlpha(230)
                    : Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(
                    screenWidth * 0.09), // 7% of screen width for corner radius
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.065),
                child: Image.asset(
                  widget.post['userImage'],
                  width: screenWidth * 0.20, // 19% of screen width
                  height: screenWidth *
                      0.20, // 23% of screen width for vertical rectangle
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Vertical Action Bar
          Positioned(
            right: screenWidth * 0.05, // 3% of screen width from right
            bottom: screenWidth * 0.15, // 30% of screen width from bottom
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015, // 1.5% of screen height
                horizontal: screenWidth * 0.01, // 2% of screen width
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.black.withAlpha(230)
                    : Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(screenWidth * 0.08),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    iconPath: 'assets/icons/feed/like.svg',
                    color: isLiked
                        ? Colors.red
                        : (widget.isDarkMode
                            ? Colors.white.withAlpha(204)
                            : Colors.black.withAlpha(204)),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => isLiked = !isLiked);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildActionButton(
                    iconPath: 'assets/icons/feed/comment.svg',
                    onTap: () {},
                    color: widget.isDarkMode
                        ? Colors.white.withAlpha(204)
                        : Colors.black.withAlpha(204),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildActionButton(
                    iconPath: 'assets/icons/feed/share.svg',
                    onTap: () {},
                    color: widget.isDarkMode
                        ? Colors.white.withAlpha(204)
                        : Colors.black.withAlpha(204),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Button Builder with responsive sizes
  Widget _buildActionButton({
    required String iconPath,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withAlpha(38)
              : Colors.black.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: screenWidth * 0.065,
          height: screenWidth * 0.065,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
