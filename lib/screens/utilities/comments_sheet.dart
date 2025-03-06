import 'package:flutter/material.dart';

class CommentsSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final comments = post['comments'] as List<dynamic>;
    final replies = post['replies'] as List<dynamic>;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Comments list
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              itemBuilder: (context, index) {
                final comment = comments[index];
                // Get replies for this comment
                final commentReplies = replies
                    .where(
                        (reply) => reply['comment_id'] == comment['comment_id'])
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment
                    _buildCommentItem(comment),
                    // Replies
                    if (commentReplies.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.12),
                        child: Column(
                          children: commentReplies
                              .map((reply) => _buildReplyItem(reply))
                              .toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Comment input field
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(comment['user_image']),
            radius: screenWidth * 0.04,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['comment_by'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  comment['comment_text'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  comment['timestamp'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(reply['user_image']),
            radius: screenWidth * 0.035,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply['reply_by'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  reply['reply_text'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  reply['timestamp'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
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
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white24 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // TODO: Implement comment posting
            },
          ),
        ],
      ),
    );
  }
}
