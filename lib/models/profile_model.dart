import 'package:flutter/foundation.dart';

class ProfileModel {
  final String profileId;
  final String username;
  final String name;
  final String bio;
  final String gender;
  final String orientation;
  final int age;
  final String location;
  final List<String> interests;
  final int friendsCount;
  final Map<String, int> preferences;
  final double rating;
  final int datesCount;
  final int postsCount;
  final int snipsCount;
  final List<String> posts;
  final List<String> snips;
  final ProfileImages images;

  const ProfileModel({
    required this.profileId,
    required this.username,
    required this.name,
    required this.bio,
    required this.gender,
    required this.orientation,
    required this.age,
    required this.location,
    required this.interests,
    required this.friendsCount,
    required this.preferences,
    required this.rating,
    required this.datesCount,
    required this.postsCount,
    required this.snipsCount,
    required this.posts,
    required this.snips,
    required this.images,
  });

  // Parse profile data in background thread
  static Future<ProfileModel> parseInBackground(Map<String, dynamic> json) {
    return compute(_parseFullProfile, json);
  }

  // Main constructor for full profile data
  static ProfileModel _parseFullProfile(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel(
      profileId: data['profile_id'] as String,
      username: data['username'] as String,
      name: data['name'] as String,
      bio: data['bio'] as String,
      gender: data['gender'] as String,
      orientation: data['orientation'] as String,
      age: data['age'] as int,
      location: data['location'] as String,
      interests: (data['interests'] as List<dynamic>).cast<String>(),
      friendsCount: data['friends_count'] as int,
      preferences: Map<String, int>.from(data['preferences'] as Map),
      rating: (data['rating'] as num).toDouble(),
      datesCount: data['dates_count'] as int,
      postsCount: data['posts_count'] as int,
      snipsCount: data['snips_count'] as int,
      posts: (data['posts'] as List<dynamic>).cast<String>(),
      snips: (data['snips'] as List<dynamic>).cast<String>(),
      images: ProfileImages.fromJson(data['images'] as Map<String, dynamic>),
    );
  }

  // Constructor for swipe view (minimal data)
  static Future<ProfileModel> parseSwipeProfile(Map<String, dynamic> json) {
    return compute(_parseSwipeProfile, json);
  }

  static ProfileModel _parseSwipeProfile(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel(
      profileId: data['profile_id'] as String,
      username: data['username'] as String,
      name: data['name'] as String,
      bio: data['bio'] as String,
      gender: data['gender'] as String,
      orientation: data['orientation'] as String,
      age: data['age'] as int,
      location: data['location'] as String,
      interests: (data['interests'] as List<dynamic>).cast<String>(),
      friendsCount: 0,
      preferences: const {'min': 0, 'max': 0},
      rating: 0.0,
      datesCount: 0,
      postsCount: 0,
      snipsCount: 0,
      posts: const [],
      snips: const [],
      images:
          ProfileImages.fromSwipeJson(data['images'] as Map<String, dynamic>),
    );
  }

  // Constructor for user profile view
  static Future<ProfileModel> parseUserProfile(Map<String, dynamic> json) {
    return compute(_parseUserProfile, json);
  }

  static ProfileModel _parseUserProfile(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel(
      profileId: data['profile_id'] as String,
      username: '',
      name: data['name'] as String,
      bio: data['bio'] as String,
      gender: data['gender'] as String,
      orientation: '',
      age: data['age'] as int,
      location: data['location'] as String,
      interests: (data['interests'] as List<dynamic>).cast<String>(),
      friendsCount: data['friends_count'] as int,
      preferences: const {'min': 0, 'max': 0},
      rating: (data['rating'] as num).toDouble(),
      datesCount: data['dates_count'] as int,
      postsCount: data['posts_count'] as int,
      snipsCount: data['snips_count'] as int,
      posts: const [],
      snips: const [],
      images:
          ProfileImages.fromUserJson(data['images'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'username': username,
      'name': name,
      'bio': bio,
      'gender': gender,
      'orientation': orientation,
      'age': age,
      'location': location,
      'interests': interests,
      'friends_count': friendsCount,
      'preferences': preferences,
      'rating': rating,
      'dates_count': datesCount,
      'posts_count': postsCount,
      'snips_count': snipsCount,
      'posts': posts,
      'snips': snips,
      'images': images.toJson(),
    };
  }
}

class ProfileImages {
  final String profile;
  final List<String> mandate;
  final List<String> optional;

  const ProfileImages({
    required this.profile,
    required this.mandate,
    required this.optional,
  });

  factory ProfileImages.fromJson(Map<String, dynamic> json) {
    return ProfileImages(
      profile: json['profile'] as String,
      mandate: (json['mandate'] as List<dynamic>).cast<String>(),
      optional: (json['optional'] as List<dynamic>).cast<String>(),
    );
  }

  // For swipe view - only needed images
  factory ProfileImages.fromSwipeJson(Map<String, dynamic> json) {
    final optionalImages = (json['optional'] as List<dynamic>).cast<String>();
    return ProfileImages(
      profile: json['profile'] as String,
      mandate: (json['mandate'] as List<dynamic>).cast<String>(),
      optional: optionalImages.take(2).toList(), // Take max 2 optional images
    );
  }

  // For user profile - only profile image
  factory ProfileImages.fromUserJson(Map<String, dynamic> json) {
    return ProfileImages(
      profile: json['profile'] as String,
      mandate: const [],
      optional: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'mandate': mandate,
      'optional': optional,
    };
  }
}
