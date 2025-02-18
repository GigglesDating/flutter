import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io' show Platform;
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
  bool _showEmojis = false;
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
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final availableHeight = mediaQuery.size.height - bottomPadding;
    final maxSheetHeight = availableHeight * 0.7;
    final minSheetHeight = availableHeight * 0.4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showEmojis
          ? maxSheetHeight
          : bottomPadding > 0
              ? maxSheetHeight
              : minSheetHeight,
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
                if (_showEmojis)
                  SizedBox(
                    height: widget.screenHeight * 0.35,
                    child: _buildEmojiPicker(),
                  ),
                _buildCommentInput(),
                // Extra padding for bottom safe area
                SizedBox(height: mediaQuery.padding.bottom),
              ],
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

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      textEditingController: _commentController,
      onEmojiSelected: (category, emoji) {
        setState(() {
          _commentController.text = _commentController.text + emoji.emoji;
        });
      },
      config: Config(
        height: 256,
        checkPlatformCompatibility: true,
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0),
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: const CategoryViewConfig(),
        bottomActionBarConfig: const BottomActionBarConfig(),
        searchViewConfig: const SearchViewConfig(),
      ),
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
          if (_replyingTo != null)
            Container(
              margin: EdgeInsets.only(right: widget.screenWidth * 0.02),
              padding: EdgeInsets.symmetric(
                horizontal: widget.screenWidth * 0.02,
                vertical: widget.screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.white.withAlpha(153)
                    : Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Replying to ${_replyingTo}',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.035,
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(153)
                          : Colors.black.withAlpha(153),
                    ),
                  ),
                  SizedBox(width: widget.screenWidth * 0.01),
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
                  IconButton(
                    onPressed: () => setState(() => _showEmojis = !_showEmojis),
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(153)
                          : Colors.black.withAlpha(153),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
            ),
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
