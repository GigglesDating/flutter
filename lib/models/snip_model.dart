// import 'user_model.dart';

// class SnipModel {
//   final String snipId;
//   final VideoContent video;
//   final String description;
//   final DateTime timestamp;
//   final int likesCount;
//   final int commentsCount;
//   final String authorProfileId;
//   final UserModel authorProfile;
//   final List<String> commentIds;

//   SnipModel({
//     required this.snipId,
//     required this.video,
//     required this.description,
//     required this.timestamp,
//     required this.likesCount,
//     required this.commentsCount,
//     required this.authorProfileId,
//     required this.authorProfile,
//     this.commentIds = const [],
//   });

//   factory SnipModel.fromJson(Map<String, dynamic> json) {
//     return SnipModel(
//       snipId: json['snip_id'] as String,
//       video: VideoContent.fromJson(json['video'] as Map<String, dynamic>),
//       description: json['description'] as String,
//       timestamp: DateTime.parse(json['timestamp'] as String),
//       likesCount: json['likes_count'] as int? ?? 0,
//       commentsCount: json['comments_count'] as int? ?? 0,
//       authorProfileId: json['author_profile_id'] as String,
//       authorProfile:
//           UserModel.fromJson(json['author_profile'] as Map<String, dynamic>),
//       commentIds: (json['comment_ids'] as List<dynamic>?)
//               ?.map((e) => e as String)
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'snip_id': snipId,
//       'video': video.toJson(),
//       'description': description,
//       'timestamp': timestamp.toIso8601String(),
//       'likes_count': likesCount,
//       'comments_count': commentsCount,
//       'author_profile_id': authorProfileId,
//       'author_profile': authorProfile.toJson(),
//       'comment_ids': commentIds,
//     };
//   }

//   // Parse snips list from API response
//   static List<SnipModel> fromApiResponse(Map<String, dynamic> apiResponse) {
//     final snipsJson = apiResponse['data']['snips'] as List<dynamic>;
//     return snipsJson
//         .map((json) => SnipModel.fromJson(json as Map<String, dynamic>))
//         .toList();
//   }

//   // Helper method to check if there are more snips to load
//   static bool hasMoreSnips(Map<String, dynamic> apiResponse) {
//     return apiResponse['data']['has_more'] as bool? ?? false;
//   }

//   // Helper method to get the next page token
//   static String? getNextPage(Map<String, dynamic> apiResponse) {
//     return apiResponse['data']['next_page'] as String?;
//   }
// }

// class VideoContent {
//   final String source;
//   final String? thumbnail;

//   VideoContent({
//     required this.source,
//     this.thumbnail,
//   });

//   factory VideoContent.fromJson(Map<String, dynamic> json) {
//     return VideoContent(
//       source: json['source'] as String,
//       thumbnail: json['thumbnail'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'source': source,
//       'thumbnail': thumbnail,
//     };
//   }
// }
