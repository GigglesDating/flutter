import '../user_model.dart';

class Comment {
  final String id;
  final String text;
  final DateTime timestamp;
  final int likesCount;
  final String authorProfileId;
  final UserModel authorProfile;
  final String? replyToCommentId;
  final List<Comment> replies;
  final String contentId;
  final String contentType;

  Comment({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.likesCount,
    required this.authorProfileId,
    required this.authorProfile,
    this.replyToCommentId,
    this.replies = const [],
    required this.contentId,
    required this.contentType,
  });

  // Parse a single comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json, {bool isReply = false}) {
    final replies = isReply
        ? const <Comment>[]
        : (json['replies'] as List?)
                ?.map((reply) => Comment.fromJson(reply as Map<String, dynamic>,
                    isReply: true))
                .toList() ??
            const [];

    return Comment(
      id: isReply ? json['reply_id'] as String : json['comment_id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      authorProfileId: json['author_profile_id'] as String,
      authorProfile:
          UserModel.fromJson(json['author_profile'] as Map<String, dynamic>),
      replyToCommentId: isReply ? json['replytocomment_id'] as String : null,
      replies: replies,
      contentId: json['content_id'] as String,
      contentType: json['content_type'] as String,
    );
  }

  // Convert comment to JSON
  Map<String, dynamic> toJson({bool isReply = false}) {
    return {
      if (isReply) 'reply_id': id else 'comment_id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likes_count': likesCount,
      'author_profile_id': authorProfileId,
      'author_profile': authorProfile.toJson(),
      if (isReply && replyToCommentId != null)
        'replytocomment_id': replyToCommentId,
      'content_id': contentId,
      'content_type': contentType,
      if (!isReply)
        'replies': replies.map((r) => r.toJson(isReply: true)).toList(),
    };
  }

  // Helper method to parse a list of comments
  static List<Comment> parseCommentsList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Comment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Parse the complete comments API response
  static Map<String, dynamic> parseFromApi(Map<String, dynamic> apiResponse) {
    if (apiResponse['status'] != 'success' || apiResponse['data'] == null) {
      throw Exception(apiResponse['message'] ?? 'Failed to parse comments');
    }

    final data = apiResponse['data'];

    return {
      'status': 'success',
      'data': {
        'comments': parseCommentsList(data['comments'] as List? ?? []),
        'total_comments': data['total_comments'] as int? ?? 0,
      }
    };
  }
}
