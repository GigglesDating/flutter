import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../barrel.dart';
import 'dart:async';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isDarkMode;
  final VoidCallback? onMoreTap;
  final bool showProfileImage;

  const PostCard({
    super.key,
    required this.post,
    required this.isDarkMode,
    this.onMoreTap,
    this.showProfileImage = true,
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
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    if (!mounted ||
        widget.post['media'] == null ||
        widget.post['media']['source'] == null) {
      return;
    }

    precacheImage(
      CachedNetworkImageProvider(widget.post['media']['source']),
      context,
    );

    if (widget.showProfileImage &&
        widget.post['author_profile'] != null &&
        widget.post['author_profile']['profile_image'] != null) {
      precacheImage(
        CachedNetworkImageProvider(
            widget.post['author_profile']['profile_image']),
        context,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartTimer?.cancel();
    // Clear cached images
    if (widget.post['media'] != null &&
        widget.post['media']['source'] != null) {
      CachedNetworkImage.evictFromCache(widget.post['media']['source']);
    }
    if (widget.showProfileImage &&
        widget.post['author_profile'] != null &&
        widget.post['author_profile']['profile_image'] != null) {
      CachedNetworkImage.evictFromCache(
          widget.post['author_profile']['profile_image']);
    }
    super.dispose();
  }

  bool get _hasContent {
    return widget.post['description']?.isNotEmpty == true;
  }

  void _handleDoubleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      isLiked = !isLiked;
      _showHeart = true;
    });

    // Cancel existing timer if any
    _heartTimer?.cancel();

    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        // Use timer for cleanup to avoid setState after dispose
        _heartTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showHeart = false);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          width: 0.25,
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
              tag: 'post_${widget.post['post_id']}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    setState(() => _showTextOverlay = !_showTextOverlay),
                onDoubleTap: _handleDoubleTap,
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenWidth * 1.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.post['media']['source'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) {
                        debugPrint('Error loading image: $error');
                        return Container(
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Force image reload
                                  CachedNetworkImage.evictFromCache(url);
                                  setState(() {});
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      },
                      httpHeaders: const {
                        'Accept': 'image/*',
                        'Cache-Control': 'max-age=3600',
                      },
                      memCacheWidth: (screenWidth * 0.95).toInt(),
                      memCacheHeight: (screenWidth * 1.4).toInt(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlays with RepaintBoundary for better performance
          if (_showTextOverlay)
            RepaintBoundary(
              child: Stack(
                children: [
                  // Profile Picture and Stats Overlay
                  if (widget.showProfileImage)
                    Positioned(
                      top: screenWidth * 0.04,
                      left: screenWidth * 0.06,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
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
                              child: CachedNetworkImage(
                                imageUrl: widget.post['author_profile']
                                    ['profile_image'],
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                                memCacheWidth: (screenWidth * 0.12).toInt(),
                                memCacheHeight: (screenWidth * 0.12).toInt(),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
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
                                  '${widget.post['likes_count']} likes',
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  _getTimeAgo(
                                      DateTime.parse(widget.post['timestamp'])),
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
                          widget.post['description'],
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

          // Action buttons with RepaintBoundary
          Positioned(
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.15,
            child: RepaintBoundary(
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
          ),

          // Heart Animation with RepaintBoundary
          if (_showHeart)
            RepaintBoundary(
              child: Positioned.fill(
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
            ),

          // Three dots button
          Positioned(
            top: screenWidth * 0.04,
            right: screenWidth * 0.06,
            child: GestureDetector(
              onTap: () {
                if (widget.onMoreTap != null) {
                  widget.onMoreTap!();
                } else {
                  _showReportSheet();
                }
              },
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  size: screenWidth * 0.055,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
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
    final isLikeButton = iconPath.contains('like.svg');

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
          colorFilter: isLikeButton
              ? ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
    );
  }

  void _showCommentsSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Prepare comments data structure
    final Map<String, dynamic> postWithComments = {
      ...widget.post,
      'comments': widget.post['comments'] ?? [],
      'replies': widget.post['replies'] ?? [],
      'id': widget.post['post_id'],
      'type': 'post',
      'url': widget.post['media']?['source'],
      'author_profile': {
        'username': widget.post['author_profile']?['name'] ?? 'Unknown',
        'profile_image': widget.post['author_profile']?['profile_image'],
      },
    };

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
          post: postWithComments,
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

  // Helper method to format timestamp
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
