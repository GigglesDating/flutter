import 'user_model.dart';

class SnipModel {
  final String snipId;
  final VideoContent video;
  final String description;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String authorProfileId;
  final UserModel authorProfile;
  final List<String> commentIds;

  SnipModel({
    required this.snipId,
    required this.video,
    required this.description,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    required this.authorProfileId,
    required this.authorProfile,
    this.commentIds = const [],
  });

  factory SnipModel.fromJson(Map<String, dynamic> json) {
    return SnipModel(
      snipId: json['snip_id'] as String,
      video: VideoContent.fromJson(json['video'] as Map<String, dynamic>),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      authorProfileId: json['author_profile_id'] as String,
      authorProfile:
          UserModel.fromJson(json['author_profile'] as Map<String, dynamic>),
      commentIds: (json['comment_ids'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snip_id': snipId,
      'video': video.toJson(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'author_profile_id': authorProfileId,
      'author_profile': authorProfile.toJson(),
      'comment_ids': commentIds,
    };
  }

  // Parse snips list from API response
  static List<SnipModel> fromApiResponse(Map<String, dynamic> apiResponse) {
    final snipsJson = apiResponse['data']['snips'] as List<dynamic>;
    return snipsJson
        .map((json) => SnipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class VideoContent {
  final String url;
  final String thumbnailUrl;
  final int duration;
  final String quality;

  VideoContent({
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.quality,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: json['duration'] as int? ?? 0,
      quality: json['quality'] as String? ?? 'HD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'quality': quality,
    };
  }
}
