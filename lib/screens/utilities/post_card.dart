import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../barrel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isDarkMode;
  final VoidCallback? onMoreTap;

  const PostCard({
    super.key,
    required this.post,
    required this.isDarkMode,
    this.onMoreTap,
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

  bool get _hasContent {
    return widget.post['caption']?.isNotEmpty == true;
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
      height: screenWidth * 1.4, // Current ratio (approximately 1:1.47)
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
                  height:
                      screenWidth * 1.4, // Current ratio (approximately 1:1.47)
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _buildMediaContent(),
                  ),
                ),
              ),
            ),
          ),

          // Overlays with IgnorePointer
          IgnorePointer(
            ignoring: false, // Make sure overlays don't intercept touches
            child: Stack(
              children: [
                // Profile Picture and Stats Overlay
                if (_showTextOverlay)
                  Positioned(
                    top: screenWidth * 0.04,
                    left: screenWidth * 0.06,
                    child: Row(
                      children: [
                        // Profile Picture
                        _buildProfileImage(),
                        SizedBox(width: screenWidth * 0.03),
                        // Post Stats
                        Container(
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
                              Text(
                                '${widget.post['likes']} likes',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                widget.post['timeAgo'],
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white.withAlpha(179)
                                      : Colors.black.withAlpha(179),
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Description Overlay (at bottom)
                if (_showTextOverlay && _hasContent)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
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
                      child: Text(
                        widget.post['caption'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                        ),
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
                    onTap: _showShareSheet,
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

          // Three dots button (always visible)
          Positioned(
            top: screenWidth * 0.04,
            right: screenWidth * 0.06,
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                if (widget.onMoreTap != null) {
                  widget.onMoreTap!();
                } else {
                  _showReportSheet();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final mediaUrl = widget.post['media']['source'] ?? '';
    final thumbnailUrl = widget.post['media']['thumbnail'];
    final isVideo = widget.post['media']['type'] == 'video';

    debugPrint('Building media content:');
    debugPrint('Media URL: $mediaUrl');
    debugPrint('Thumbnail URL: $thumbnailUrl');
    debugPrint('Is Video: $isVideo');

    if (isVideo) {
      return VideoLoader(
        videoUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 1.4,
        fit: BoxFit.cover,
        autoPlay: false,
        looping: true,
        showControls: true,
        loadingWidget: Center(
          child: CircularProgressIndicator(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load video',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ImageLoader(
      imageUrl: mediaUrl,
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 1.4,
      fit: BoxFit.cover,
      loadingWidget: Center(
        child: CircularProgressIndicator(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      errorWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    debugPrint(
        'Building profile image with data: ${widget.post['author_profile']}');
    final authorProfile =
        widget.post['author_profile'] as Map<String, dynamic>?;
    final String? profileImageUrl = authorProfile?['profile_image'];

    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      debugPrint('No profile image URL found');
      return const CircleAvatar(
        radius: 20,
        child: Icon(Icons.person),
      );
    }

    debugPrint('Loading profile image from: $profileImageUrl');
    return CachedNetworkImage(
      imageUrl: profileImageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
        radius: 20,
      ),
      placeholder: (context, url) => const CircleAvatar(
        radius: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading profile image: $error');
        return const CircleAvatar(
          radius: 20,
          child: Icon(Icons.person),
        );
      },
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

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      builder: (context) => ShareSheet(
        isDarkMode: widget.isDarkMode,
        post: widget.post,
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  void _showReportSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
      ),
    );
  }
}
