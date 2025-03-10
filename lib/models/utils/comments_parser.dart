import '../user_model.dart';
import 'package:flutter/foundation.dart';

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
      id: isReply ? json['reply_id'].toString() : json['comment_id'].toString(),
      text: json['text']?.toString() ?? '',
      timestamp: DateTime.parse(
          json['timestamp']?.toString() ?? DateTime.now().toIso8601String()),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      authorProfileId: json['author_profile_id']?.toString() ?? '',
      authorProfile:
          UserModel.fromJson(json['author_profile'] as Map<String, dynamic>),
      replyToCommentId: isReply ? json['replytocomment_id']?.toString() : null,
      replies: replies,
      contentId: json['content_id']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
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
    try {
      if (apiResponse['status'] != 'success' || apiResponse['data'] == null) {
        debugPrint('Invalid API response format: $apiResponse');
        throw Exception('Invalid API response format');
      }

      final data = apiResponse['data'] as Map<String, dynamic>;
      if (data['comments'] == null) {
        debugPrint('No comments found in data: $data');
        throw Exception('No comments data found in response');
      }

      final commentsList = data['comments'] as List;
      return {
        'status': 'success',
        'data': {
          'comments': parseCommentsList(commentsList),
          'total_comments':
              (data['total_comments'] as num?)?.toInt() ?? commentsList.length,
        }
      };
    } catch (e, stackTrace) {
      debugPrint('Error parsing API response: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('API Response: $apiResponse');
      rethrow;
    }
  }
}
