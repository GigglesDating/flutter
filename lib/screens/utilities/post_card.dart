import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../barrel.dart';

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
  bool _showTextOverlay = false;
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
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withAlpha(25)
              : Colors.black.withAlpha(25),
          width: 0.25, // Post border thickness
        ),
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
      width: screenWidth * 0.95,
      height: screenWidth * 1.4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Center the main post container
          Center(
            child: Hero(
              tag: 'post_${widget.post['image']}',
              child: GestureDetector(
                onTap: () {
                  setState(() => _showTextOverlay = !_showTextOverlay);
                },
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

          // Overlays with IgnorePointer
          IgnorePointer(
            ignoring: true, // Make sure overlays don't intercept touches
            child: Stack(
              children: [
                // Profile Picture and Stats Overlay
                Positioned(
                  top: screenWidth * 0.04,
                  left: screenWidth * 0.06,
                  child: Row(
                    children: [
                      // Profile Picture
                      Container(
                        padding: EdgeInsets.all(2),
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
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Stats with animation
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showTextOverlay ? 1.0 : 0.0,
                        child: Container(
                          margin: EdgeInsets.only(left: screenWidth * 0.02),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? Colors.black.withAlpha(230)
                                : Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.isDarkMode
                                  ? Colors.white.withAlpha(38)
                                  : Colors.black.withAlpha(26),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: screenWidth * 0.04,
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '${widget.post['likes']}',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              Text(
                                ' | ',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              Text(
                                widget.post['timeAgo'],
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Post Description Overlay with fade animation only
                Positioned(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: screenWidth * 0.05,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showTextOverlay ? 1.0 : 0.0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final textSpan = TextSpan(
                          text: widget.post['caption'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withAlpha(255),
                            fontSize: screenWidth * 0.035,
                            height: 1.3,
                          ),
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: TextDirection.ltr,
                          maxLines: 2,
                        );
                        textPainter.layout(maxWidth: constraints.maxWidth);

                        final isMultiLine = textPainter.didExceedMaxLines;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.03,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(77),
                                Colors.black.withAlpha(179),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.post['username'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(255),
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              if (isMultiLine)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: screenWidth * 0.3,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      widget.post['caption'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(255),
                                        fontSize: screenWidth * 0.035,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenWidth * 0.02),
                                  child: Text(
                                    widget.post['caption'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(255),
                                      fontSize: screenWidth * 0.035,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons (outside IgnorePointer)
          Positioned(
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.15,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.018,
                vertical: screenWidth * 0.025,
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.black.withAlpha(230)
                    : Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Column(
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
                  SizedBox(height: screenHeight * 0.015),
                  _buildActionButton(
                    iconPath: 'assets/icons/feed/comment.svg',
                    onTap: _showCommentsSheet,
                    color: widget.isDarkMode
                        ? Colors.white.withAlpha(204)
                        : Colors.black.withAlpha(204),
                  ),
                  SizedBox(height: screenHeight * 0.015),
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
          if (_showHeart)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showHeart ? 1.0 : 0.0,
                child: Center(
                  child: ScaleTransition(
                    scale: _animation,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white.withAlpha(255),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentsSheet(
          isDarkMode: isDarkMode,
          post: widget.post,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),
      ),
    );
  }
}
