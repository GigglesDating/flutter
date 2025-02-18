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
      onTap: () {
        // Dismiss keyboard when tapping outside input
        if (_commentController.text.isEmpty) {
          FocusScope.of(context).unfocus();
        }
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
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: widget.isDarkMode
                ? Colors.white.withAlpha(153)
                : Colors.black.withAlpha(153),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.screenWidth * 0.04,
                vertical: widget.screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.white.withAlpha(153)
                    : Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(20),
              ),
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
          ),
          SizedBox(width: widget.screenWidth * 0.02),
          IconButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                // Add comment logic
                _commentController.clear();
                setState(() => _replyingTo = null);
              }
            },
            icon: Icon(
              Icons.send_rounded,
              color: _commentController.text.isEmpty
                  ? (widget.isDarkMode
                      ? Colors.white.withAlpha(153)
                      : Colors.black.withAlpha(153))
                  : Theme.of(context).primaryColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.04,
            backgroundImage: AssetImage(comment['userImage']),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['user'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      comment['timeAgo'],
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withAlpha(153)
                            : Colors.black.withAlpha(153),
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  comment['text'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Row(
                  children: [
                    Text(
                      '${comment['likes']} likes',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withAlpha(153)
                            : Colors.black.withAlpha(153),
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    GestureDetector(
                      onTap: () => onReply(comment['id']),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white.withAlpha(153)
                              : Colors.black.withAlpha(153),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
                if (comment['replies'] != null && comment['replies'].isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenWidth * 0.02,
                      left: screenWidth * 0.04, // Indent replies
                    ),
                    child: Column(
                      children: [
                        for (var reply in comment['replies'])
                          _CommentItem(
                            comment: reply,
                            isDarkMode: isDarkMode,
                            onReply: onReply,
                            screenWidth: screenWidth,
                          ),
                      ],
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
