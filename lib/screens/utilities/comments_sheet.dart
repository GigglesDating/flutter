import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentsSheet extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic> post;
  final double screenHeight;
  final double screenWidth;

  const CommentsSheet({
    super.key,
    required this.isDarkMode,
    required this.post,
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
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
    final comments = widget.post['comments'] as List<dynamic>? ?? [];
    final replies = widget.post['replies'] as List<dynamic>? ?? [];
    final commentsCount = widget.post['comments_count'] ?? 0;

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
                    '$commentsCount',
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
              child: comments.isEmpty
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
                      itemCount: comments.length,
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.04),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final commentReplies = replies
                            .where((reply) =>
                                reply['replytocomment_id'] ==
                                comment['comment_id'])
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Comment with swipe actions
                            GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                if (details.primaryDelta! > 0 &&
                                    details.primaryDelta! < 20) {
                                  // Right swipe to start reply
                                  setState(() {
                                    _replyingToCommentId =
                                        comment['comment_id'];
                                    _replyingToUsername =
                                        comment['author_profile']['name'];
                                  });
                                } else if (details.primaryDelta! < 0 &&
                                    _replyingToCommentId ==
                                        comment['comment_id']) {
                                  // Left swipe to cancel reply if we're replying to this comment
                                  _cancelReply();
                                }
                              },
                              onDoubleTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  final commentId = comment['comment_id'];
                                  _likedComments[commentId] =
                                      !(_likedComments[commentId] ?? false);
                                  if (_likedComments[commentId] ?? false) {
                                    _showHeartAnimation();
                                  }
                                });
                              },
                              child: _buildCommentItem(comment),
                            ),
                            // Replies
                            if (commentReplies.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: widget.screenWidth * 0.12),
                                child: Column(
                                  children: commentReplies
                                      .map((reply) => GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              if (details.primaryDelta! > 0 &&
                                                  details.primaryDelta! < 20) {
                                                // Right swipe on reply - start replying to parent comment
                                                setState(() {
                                                  _replyingToCommentId =
                                                      comment['comment_id'];
                                                  _replyingToUsername =
                                                      comment['author_profile']
                                                          ['name'];
                                                });
                                              } else if (details.primaryDelta! <
                                                      0 &&
                                                  _replyingToCommentId ==
                                                      comment['comment_id']) {
                                                // Left swipe on reply - cancel if replying to parent comment
                                                _cancelReply();
                                              }
                                            },
                                            onDoubleTap: () {
                                              HapticFeedback.mediumImpact();
                                              setState(() {
                                                final replyId =
                                                    reply['reply_id'];
                                                _likedReplies[replyId] =
                                                    !(_likedReplies[replyId] ??
                                                        false);
                                                if (_likedReplies[replyId] ??
                                                    false) {
                                                  _showHeartAnimation();
                                                }
                                              });
                                            },
                                            child: _buildReplyItem(reply),
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final authorProfile = comment['author_profile'];
    final profileImage = authorProfile['profile_image'];
    final name = authorProfile['name'];
    final text = comment['text'] ?? '';
    final timestamp = comment['timestamp'];
    final likesCount = comment['likes_count'];
    final commentId = comment['comment_id'];
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
              child: profileImage != null
                  ? CachedNetworkImage(
                      imageUrl: profileImage,
                      width: widget.screenWidth * 0.08,
                      height: widget.screenWidth * 0.08,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    )
                  : const Icon(Icons.person),
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
                          '• ${_getTimeAgo(DateTime.parse(timestamp))}',
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

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    final authorProfile = reply['author_profile'];
    final profileImage = authorProfile['profile_image'];
    final name = authorProfile['name'];
    final text = reply['text'] ?? '';
    final timestamp = reply['timestamp'];
    final likesCount = reply['likes_count'];
    final replyId = reply['reply_id'];
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
              child: profileImage != null
                  ? CachedNetworkImage(
                      imageUrl: profileImage,
                      width: widget.screenWidth * 0.07,
                      height: widget.screenWidth * 0.07,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    )
                  : const Icon(Icons.person),
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
                          '• ${_getTimeAgo(DateTime.parse(timestamp))}',
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
