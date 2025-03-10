import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import '../../models/utils/comments_parser.dart';
import '../../network/think.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsSheet extends StatefulWidget {
  final bool isDarkMode;
  final String contentId;
  final String contentType;
  final List<String> commentIds;
  final UserModel authorProfile;
  final double screenHeight;
  final double screenWidth;

  const CommentsSheet({
    super.key,
    required this.isDarkMode,
    required this.contentId,
    required this.contentType,
    required this.commentIds,
    required this.authorProfile,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyingToCommentId;
  String? _replyingToUsername;
  final Map<String, bool> _likedComments = {};
  final Map<String, bool> _likedReplies = {};
  bool _showHeart = false;
  AnimationController? _animationController;
  Animation<double>? _animation;

  // State variables for comments
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) {
        throw Exception('No UUID found');
      }

      debugPrint('CommentsSheet - Loading comments with:');
      debugPrint('  UUID: $uuid');
      debugPrint('  Content ID: ${widget.contentId}');
      debugPrint('  Content Type: ${widget.contentType}');
      debugPrint('  Comment IDs available: ${widget.commentIds}');

      final response = await ThinkProvider().fetchComments(
        uuid: uuid,
        contentId: widget.contentId,
        contentType: widget.contentType,
      );

      debugPrint('CommentsSheet - API Response:');
      debugPrint(response.toString());

      if (!mounted) return;

      final parsedData = Comment.parseFromApi(response);
      setState(() {
        _comments = parsedData['data']['comments'] as List<Comment>;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading comments: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keyboard when tapping outside input
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: widget.screenHeight * 0.7,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(widget.screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '${_comments.length}',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: _loadComments,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : _comments.isEmpty
                          ? Center(
                              child: Text(
                                'No comments yet.\nBe the first to comment!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                  fontSize: widget.screenWidth * 0.04,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _comments.length,
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.screenWidth * 0.04),
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Comment with swipe actions
                                    GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        if (details.primaryDelta! > 0 &&
                                            details.primaryDelta! < 20) {
                                          setState(() {
                                            _replyingToCommentId = comment.id;
                                            _replyingToUsername =
                                                comment.authorProfile.name;
                                          });
                                        } else if (details.primaryDelta! < 0 &&
                                            _replyingToCommentId ==
                                                comment.id) {
                                          _cancelReply();
                                        }
                                      },
                                      onDoubleTap: () {
                                        HapticFeedback.mediumImpact();
                                        setState(() {
                                          _likedComments[comment.id] =
                                              !(_likedComments[comment.id] ??
                                                  false);
                                          if (_likedComments[comment.id] ??
                                              false) {
                                            _showHeartAnimation();
                                          }
                                        });
                                      },
                                      child: _buildCommentItem(comment),
                                    ),
                                    // Replies
                                    if (comment.replies.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: widget.screenWidth * 0.12),
                                        child: Column(
                                          children: comment.replies
                                              .map((reply) => GestureDetector(
                                                    onHorizontalDragUpdate:
                                                        (details) {
                                                      if (details.primaryDelta! >
                                                              0 &&
                                                          details.primaryDelta! <
                                                              20) {
                                                        setState(() {
                                                          _replyingToCommentId =
                                                              comment.id;
                                                          _replyingToUsername =
                                                              comment
                                                                  .authorProfile
                                                                  .name;
                                                        });
                                                      } else if (details
                                                                  .primaryDelta! <
                                                              0 &&
                                                          _replyingToCommentId ==
                                                              comment.id) {
                                                        _cancelReply();
                                                      }
                                                    },
                                                    onDoubleTap: () {
                                                      HapticFeedback
                                                          .mediumImpact();
                                                      setState(() {
                                                        _likedReplies[
                                                                reply.id] =
                                                            !(_likedReplies[
                                                                    reply.id] ??
                                                                false);
                                                        if (_likedReplies[
                                                                reply.id] ??
                                                            false) {
                                                          _showHeartAnimation();
                                                        }
                                                      });
                                                    },
                                                    child:
                                                        _buildReplyItem(reply),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
            ),

            // Replying to indicator
            if (_replyingToCommentId != null)
              GestureDetector(
                onTap: _cancelReply,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.screenWidth * 0.04,
                    vertical: widget.screenWidth * 0.02,
                  ),
                  color: widget.isDarkMode
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Replying to $_replyingToUsername',
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: widget.screenWidth * 0.035,
                        ),
                      ),
                      Icon(
                        Icons.close,
                        size: 16,
                        color:
                            widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

            // Comment input field
            _buildCommentInput(),

            // Heart Animation with RepaintBoundary
            if (_showHeart)
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showHeart ? 1.0 : 0.0,
                    child: Center(
                      child: ScaleTransition(
                        scale: _animation!,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white.withAlpha(255),
                          size: widget.screenWidth * 0.3,
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

  Widget _buildCommentItem(Comment comment) {
    final authorProfile = comment.authorProfile;
    final profileImage = authorProfile.profileImage;
    final name = authorProfile.name;
    final text = comment.text;
    final timestamp = comment.timestamp;
    final likesCount = comment.likesCount;
    final commentId = comment.id;
    final isLiked = _likedComments[commentId] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: widget.screenWidth * 0.04,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: profileImage,
                width: widget.screenWidth * 0.08,
                height: widget.screenWidth * 0.08,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: widget.screenWidth * 0.05,
                  color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ),
          SizedBox(width: widget.screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${_getTimeAgo(timestamp)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(widget.screenWidth * 0.015),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(38)
                            : Colors.black.withAlpha(26),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: widget.screenWidth * 0.045,
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(204)
                            : Colors.black.withAlpha(204),
                      ),
                    ),
                  ],
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: widget.screenWidth * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$likesCount likes',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _likedComments[commentId] =
                              !(_likedComments[commentId] ?? false);
                        });
                      },
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLiked
                            ? Colors.red
                            : (widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    final authorProfile = reply.authorProfile;
    final profileImage = authorProfile.profileImage;
    final name = authorProfile.name;
    final text = reply.text;
    final timestamp = reply.timestamp;
    final likesCount = reply.likesCount;
    final replyId = reply.id;
    final isLiked = _likedReplies[replyId] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: widget.screenWidth * 0.035,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: profileImage,
                width: widget.screenWidth * 0.07,
                height: widget.screenWidth * 0.07,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: widget.screenWidth * 0.045,
                  color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ),
          SizedBox(width: widget.screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${_getTimeAgo(timestamp)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(widget.screenWidth * 0.015),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(38)
                            : Colors.black.withAlpha(26),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: widget.screenWidth * 0.045,
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(204)
                            : Colors.black.withAlpha(204),
                      ),
                    ),
                  ],
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: widget.screenWidth * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$likesCount likes',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _likedReplies[replyId] =
                              !(_likedReplies[replyId] ?? false);
                        });
                      },
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLiked
                            ? Colors.red
                            : (widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(widget.screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDarkMode ? Colors.white24 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Handle comment/reply posting here
              _commentController.clear();
              _commentFocusNode.unfocus();
              if (_replyingToCommentId != null) {
                setState(() {
                  _replyingToCommentId = null;
                  _replyingToUsername = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _showHeartAnimation() {
    _animationController?.forward();
    setState(() {
      _showHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController?.reverse().then((_) {
          setState(() {
            _showHeart = false;
          });
        });
      }
    });
  }
}
