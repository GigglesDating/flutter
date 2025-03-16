import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../barrel.dart';
import 'dart:async';
import 'dart:ui';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDarkMode;
  final VoidCallback? onMoreTap;
  final bool showProfileImage;
  final bool isProfileView;
  final VoidCallback? onPostTap;
  final double? customWidth;
  final double? customHeight;

  const PostCard({
    super.key,
    required this.post,
    required this.isDarkMode,
    this.onMoreTap,
    this.showProfileImage = true,
    this.isProfileView = false,
    this.onPostTap,
    this.customWidth,
    this.customHeight,
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
  CancellationToken? _imageCancellationToken;

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
    _preloadImages();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.media.source != widget.post.media.source ||
        oldWidget.post.authorProfile.profileImage !=
            widget.post.authorProfile.profileImage) {
      _preloadImages();
    }
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;

    // Cancel any ongoing preload
    _imageCancellationToken?.cancel();
    _imageCancellationToken = CancellationToken();

    try {
      // Preload main post image
      if (widget.post.media.source.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(widget.post.media.source);
        await precacheImage(
          CachedNetworkImageProvider(
            widget.post.media.source,
            cacheKey: '${widget.post.media.source}_post_main',
          ),
          context,
          onError: (e, stackTrace) {
            debugPrint('Error preloading post image: $e');
          },
        );
      }

      // Preload profile image if needed
      if (widget.showProfileImage &&
          widget.post.authorProfile.profileImage.isNotEmpty) {
        await precacheImage(
          CachedNetworkImageProvider(
            widget.post.authorProfile.profileImage,
            cacheKey: '${widget.post.authorProfile.profileImage}_post_profile',
          ),
          context,
          onError: (e, stackTrace) {
            debugPrint('Error preloading profile image: $e');
          },
        );
      }
    } catch (e) {
      debugPrint('Error in preloading images: $e');
    }
  }

  @override
  void dispose() {
    _imageCancellationToken?.cancel();
    _animationController.dispose();
    _heartTimer?.cancel();

    // Clear cached images with specific cache keys
    if (widget.post.media.source.isNotEmpty) {
      CachedNetworkImage.evictFromCache(
        widget.post.media.source,
        cacheKey: '${widget.post.media.source}_post_main',
      );
    }
    if (widget.showProfileImage &&
        widget.post.authorProfile.profileImage.isNotEmpty) {
      CachedNetworkImage.evictFromCache(
        widget.post.authorProfile.profileImage,
        cacheKey: '${widget.post.authorProfile.profileImage}_post_profile',
      );
    }
    super.dispose();
  }

  bool get _hasContent {
    return widget.post.description.isNotEmpty;
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

    // Use custom dimensions if provided, otherwise use default
    final cardWidth = widget.customWidth ?? screenWidth * 0.95;
    final cardHeight = widget.customHeight ?? screenWidth * 1.4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: widget.isProfileView ? 0 : screenHeight * 0.02,
        top: widget.isProfileView ? 0 : screenHeight * 0.02,
        right: widget.isProfileView ? screenWidth * 0.05 : 0,
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
      width: cardWidth,
      height: cardHeight,
      child: GestureDetector(
        onTap: widget.onPostTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Center the main post container
            Center(
              child: Hero(
                tag: 'post_${widget.post.postId}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.isProfileView
                      ? widget.onPostTap
                      : () =>
                          setState(() => _showTextOverlay = !_showTextOverlay),
                  onDoubleTap: _handleDoubleTap,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.post.media.source,
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
                        memCacheWidth: (cardWidth).toInt(),
                        memCacheHeight: (cardHeight).toInt(),
                        maxWidthDiskCache: 1080,
                        maxHeightDiskCache: 1920,
                        cacheKey: '${widget.post.media.source}_post_main',
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
                        top: cardWidth * 0.04,
                        left: cardWidth * 0.06,
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
                                  imageUrl:
                                      widget.post.authorProfile.profileImage,
                                  width: cardWidth * 0.12,
                                  height: cardWidth * 0.12,
                                  fit: BoxFit.cover,
                                  memCacheWidth: (cardWidth * 0.24).toInt(),
                                  memCacheHeight: (cardWidth * 0.24).toInt(),
                                  maxWidthDiskCache: 300,
                                  maxHeightDiskCache: 300,
                                  cacheKey:
                                      '${widget.post.authorProfile.profileImage}_post_profile',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    strokeWidth: 2,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person),
                                  httpHeaders: const {
                                    'Accept': 'image/*',
                                    'Cache-Control': 'max-age=3600',
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: cardWidth * 0.03),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardWidth * 0.03,
                                vertical: cardWidth * 0.015,
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
                                    '${widget.post.likesCount} likes',
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: cardWidth * 0.035,
                                    ),
                                  ),
                                  SizedBox(width: cardWidth * 0.02),
                                  Text(
                                    _getTimeAgo(widget.post.timestamp),
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 14,
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
                            horizontal: cardWidth * 0.04,
                            vertical: cardWidth * 0.03,
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
                            widget.post.description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: cardWidth * 0.04,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Action buttons with RepaintBoundary
            if (!widget.isProfileView)
              Positioned(
                right: cardWidth * 0.04,
                bottom: cardWidth * 0.15,
                child: RepaintBoundary(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardWidth * 0.018,
                      vertical: cardWidth * 0.025,
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
                          size: cardWidth * 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Three dots button
            if (!widget.isProfileView)
              Positioned(
                top: cardWidth * 0.04,
                right: cardWidth * 0.06,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onMoreTap != null) {
                      widget.onMoreTap!();
                    } else {
                      _showReportSheet();
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        padding: EdgeInsets.all(cardWidth * 0.015),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white.withAlpha(38)
                              : Colors.black.withAlpha(38),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: cardWidth * 0.045,
                          color: Colors.white.withAlpha(230),
                        ),
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
    debugPrint('Opening comments for Post ID: ${widget.post.postId}');
    debugPrint('Post Comment IDs: ${widget.post.commentIds}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        isDarkMode: widget.isDarkMode,
        contentId: widget.post.postId,
        contentType: 'post',
        commentIds: widget.post.commentIds,
        authorProfile: widget.post.authorProfile,
        screenHeight: MediaQuery.of(context).size.height,
        screenWidth: MediaQuery.of(context).size.width,
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
        post: widget.post.toJson(),
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
      builder: (context) => ReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
        reportType: ReportType.content,
        contentType: 'post',
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

class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}
