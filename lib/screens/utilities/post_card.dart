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
  bool _showHeart = false;

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.02,
        top: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode
                ? Colors.white.withAlpha(10)
                : Colors.black.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Center the main post container
          Center(
            child: Hero(
              tag: 'post_${widget.post['image']}',
              child: GestureDetector(
                onDoubleTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    isLiked = !isLiked;
                    _showHeart = true;
                  });
                  _animationController.forward().then((_) {
                    _animationController.reverse().then((_) {
                      setState(() => _showHeart = false);
                    });
                  });
                },
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenWidth * 1.4,
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
          ),

          // Profile Picture Overlay
          Positioned(
            top: screenWidth * 0.04, // 3% from top
            left: screenWidth * 0.06, // 3% from left
            child: Container(
              padding: EdgeInsets.all(2), // Thin border padding
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDarkMode
                    ? Colors.black.withAlpha(230)
                    : Colors.white.withAlpha(230),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  widget.post['userImage'],
                  width: screenWidth * 0.12, // Smaller size
                  height: screenWidth * 0.12,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Post Description Overlay
          Positioned(
            left: screenWidth * 0.05,
            right: screenWidth * 0.2,
            bottom: screenWidth * 0.05,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.post['caption'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
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
                vertical: screenHeight * 0.012, // Reduced from 0.015
                horizontal: screenWidth * 0.008, // Reduced from 0.01
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
                    onTap: _showCommentsSheet,
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

          // Heart Animation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showHeart ? 1.0 : 0.0,
              child: Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: screenWidth * 0.3,
                  ),
                ),
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
        padding: EdgeInsets.all(screenWidth * 0.025),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withAlpha(38)
              : Colors.black.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: screenWidth * 0.055,
          height: screenWidth * 0.055,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Comments'),
            // Add your comments list here
          ],
        ),
      ),
    );
  }
}
