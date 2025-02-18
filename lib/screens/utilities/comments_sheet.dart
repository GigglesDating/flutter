import 'package:flutter/material.dart';
import 'dart:ui';

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

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyingTo;

  final List<Map<String, dynamic>> _comments = [
    {
      'id': '1',
      'user': 'Sarah Parker',
      'userImage': 'assets/tempImages/users/user2.jpg',
      'text': 'Beautiful shot! 😍',
      'likes': 12,
      'timeAgo': '2h ago',
      'replies': [
        {
          'id': '2',
          'user': 'John Doe',
          'userImage': 'assets/tempImages/users/user1.jpg',
          'text': 'Thanks Sarah! 🙏',
          'likes': 3,
          'timeAgo': '1h ago',
        }
      ],
    },
    {
      'id': '3',
      'user': 'Mike Wilson',
      'userImage': 'assets/tempImages/users/user3.jpg',
      'text':
          'The lighting in this photo is absolutely perfect! What camera did you use?',
      'likes': 8,
      'timeAgo': '1h ago',
      'replies': [],
    },
    {
      'id': '4',
      'user': 'Emma Thompson',
      'userImage': 'assets/tempImages/users/user4.jpg',
      'text': 'This location looks amazing! Where was this taken? 🌟',
      'likes': 15,
      'timeAgo': '45m ago',
      'replies': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final topPadding = mediaQuery.padding.top;

    // Calculate available space
    final availableHeight = screenSize.height - bottomPadding - topPadding;
    final maxSheetHeight = availableHeight * 0.8;
    final minSheetHeight = availableHeight * 0.5;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _replyingTo = null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: bottomPadding > 0 ? maxSheetHeight * 0.8 : minSheetHeight,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.black.withAlpha(240)
                    : Colors.white.withAlpha(240),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: widget.screenWidth * 0.04,
                        bottom: widget.screenWidth * 0.02,
                      ),
                      width: widget.screenWidth * 0.1,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(77)
                            : Colors.black.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildHeader(),
                  Expanded(
                    child: _buildCommentsList(),
                  ),
                  _buildCommentInput(),
                  // Extra padding for bottom safe area
                  SizedBox(height: mediaQuery.padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode
                ? Colors.white.withAlpha(38)
                : Colors.black.withAlpha(26),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: widget.screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            '${_comments.length}',
            style: TextStyle(
              fontSize: widget.screenWidth * 0.04,
              color: widget.isDarkMode
                  ? Colors.white.withAlpha(153)
                  : Colors.black.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.04),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _CommentItem(
          comment: comment,
          isDarkMode: widget.isDarkMode,
          onReply: (commentId) {
            setState(() => _replyingTo = commentId);
          },
          screenWidth: widget.screenWidth,
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(widget.screenWidth * 0.04),
      child: Column(
        children: [
          if (_replyingTo != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.screenWidth * 0.04,
                vertical: widget.screenWidth * 0.02,
              ),
              child: Row(
                children: [
                  Text(
                    'Replying',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(153)
                          : Colors.black.withAlpha(153),
                    ),
                  ),
                  SizedBox(width: widget.screenWidth * 0.02),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: Icon(
                      Icons.close,
                      size: widget.screenWidth * 0.04,
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(153)
                          : Colors.black.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.screenWidth * 0.04,
              vertical: widget.screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.black : Colors.white,
              border: Border.all(
                color: widget.isDarkMode ? Colors.white : Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(153)
                            : Colors.black.withAlpha(153),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(width: widget.screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      // Add comment/reply logic here
                      setState(() {
                        if (_replyingTo != null) {
                          // Add reply
                          final commentIndex = _comments
                              .indexWhere((c) => c['id'] == _replyingTo);
                          if (commentIndex != -1) {
                            _comments[commentIndex]['replies'] ??= [];
                            _comments[commentIndex]['replies'].add({
                              'id': DateTime.now().toString(),
                              'user': 'Current User',
                              'userImage':
                                  'assets/tempImages/users/current_user.jpg',
                              'text': _commentController.text,
                              'likes': 0,
                              'timeAgo': 'just now',
                            });
                          }
                        } else {
                          // Add new comment
                          _comments.add({
                            'id': DateTime.now().toString(),
                            'user': 'Current User',
                            'userImage':
                                'assets/tempImages/users/current_user.jpg',
                            'text': _commentController.text,
                            'likes': 0,
                            'timeAgo': 'just now',
                            'replies': [],
                          });
                        }
                      });
                      _commentController.clear();
                      _replyingTo = null;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(widget.screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: widget.isDarkMode ? Colors.black : Colors.white,
                      size: widget.screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final bool isDarkMode;
  final Function(String) onReply;
  final double screenWidth;

  const _CommentItem({
    required this.comment,
    required this.isDarkMode,
    required this.onReply,
    required this.screenWidth,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Right swipe detected - always reply to primary comment
          widget.onReply(widget.comment['id']);
        }
      },
      onDoubleTap: () {
        setState(() => isLiked = !isLiked);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: widget.screenWidth * 0.02),
        padding: EdgeInsets.all(widget.screenWidth * 0.03),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withAlpha(13)
              : Colors.black.withAlpha(7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Main comment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: widget.screenWidth * 0.04,
                  backgroundImage: AssetImage(widget.comment['userImage']),
                ),
                SizedBox(width: widget.screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.comment['user'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.comment['timeAgo'],
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white.withAlpha(153)
                                      : Colors.black.withAlpha(153),
                                  fontSize: widget.screenWidth * 0.035,
                                ),
                              ),
                              SizedBox(width: widget.screenWidth * 0.02),
                              GestureDetector(
                                onTap: () => setState(() => isLiked = !isLiked),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: widget.screenWidth * 0.035,
                                      color: isLiked
                                          ? Colors.red
                                          : (widget.isDarkMode
                                              ? Colors.white.withAlpha(153)
                                              : Colors.black.withAlpha(153)),
                                    ),
                                    SizedBox(width: widget.screenWidth * 0.01),
                                    Text('${widget.comment['likes']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: widget.screenWidth * 0.01),
                      Text(
                        widget.comment['text'],
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Replies with indent
            if (widget.comment['replies'] != null)
              ...widget.comment['replies']
                  .map<Widget>((reply) => Container(
                        margin: EdgeInsets.only(
                          left: widget.screenWidth * 0.1,
                          top: widget.screenWidth * 0.02,
                        ),
                        child: _ReplyItem(
                          reply: reply,
                          isDarkMode: widget.isDarkMode,
                          screenWidth: widget.screenWidth,
                          parentCommentId: widget.comment['id'],
                          onReply: widget.onReply,
                        ),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class _ReplyItem extends StatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDarkMode;
  final double screenWidth;
  final String parentCommentId;
  final Function(String) onReply;

  const _ReplyItem({
    required this.reply,
    required this.isDarkMode,
    required this.screenWidth,
    required this.parentCommentId,
    required this.onReply,
  });

  @override
  State<_ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<_ReplyItem> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // When swiping on a reply, trigger reply to parent comment
          widget.onReply(widget.parentCommentId);
        }
      },
      onDoubleTap: () {
        setState(() => isLiked = !isLiked);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: widget.screenWidth * 0.02),
        padding: EdgeInsets.all(widget.screenWidth * 0.03),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withAlpha(13)
              : Colors.black.withAlpha(7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Reply content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: widget.screenWidth * 0.04,
                  backgroundImage: AssetImage(widget.reply['userImage']),
                ),
                SizedBox(width: widget.screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.reply['user'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.reply['timeAgo'],
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white.withAlpha(153)
                                      : Colors.black.withAlpha(153),
                                  fontSize: widget.screenWidth * 0.035,
                                ),
                              ),
                              SizedBox(width: widget.screenWidth * 0.02),
                              GestureDetector(
                                onTap: () => setState(() => isLiked = !isLiked),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: widget.screenWidth * 0.035,
                                      color: isLiked
                                          ? Colors.red
                                          : (widget.isDarkMode
                                              ? Colors.white.withAlpha(153)
                                              : Colors.black.withAlpha(153)),
                                    ),
                                    SizedBox(width: widget.screenWidth * 0.01),
                                    Text('${widget.reply['likes']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: widget.screenWidth * 0.01),
                      Text(
                        widget.reply['text'],
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
