import 'user_model.dart';

class PostModel {
  final String postId;
  final MediaContent media;
  final String description;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String authorProfileId;
  final UserModel authorProfile;
  final List<String> commentIds;

  PostModel({
    required this.postId,
    required this.media,
    required this.description,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    required this.authorProfileId,
    required this.authorProfile,
    this.commentIds = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['post_id']?.toString() ?? '',
      media: MediaContent.fromJson(json['media'] as Map<String, dynamic>),
      description: json['description']?.toString() ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      authorProfileId: json['author_profile_id']?.toString() ?? '',
      authorProfile:
          UserModel.fromJson(json['author_profile'] as Map<String, dynamic>),
      commentIds:
          (json['comment_ids'] as List?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'media': media.toJson(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'author_profile_id': authorProfileId,
      'author_profile': authorProfile.toJson(),
      'comment_ids': commentIds,
    };
  }

  // Parse posts list from API response
  static List<PostModel> fromApiResponse(Map<String, dynamic> apiResponse) {
    final postsJson = apiResponse['data']['posts'] as List<dynamic>;
    return postsJson
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class MediaContent {
  final String type;
  final String source;

  MediaContent({
    required this.type,
    required this.source,
  });

  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      type: json['type'] as String,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'source': source,
    };
  }
}
