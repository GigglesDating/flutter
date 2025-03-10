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
  final ProfileImages images;

  ProfileModel({
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
    required this.images,
  });

  // Main constructor from full API response
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
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
      images: ProfileImages.fromJson(data['images'] as Map<String, dynamic>),
    );
  }

  // Constructor for swipe view (minimal data)
  factory ProfileModel.fromSwipeView(Map<String, dynamic> json) {
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
      friendsCount: 0, // Not needed for swipe
      preferences: const {'min': 0, 'max': 0}, // Not needed for swipe
      rating: 0.0, // Not needed for swipe
      datesCount: 0, // Not needed for swipe
      postsCount: 0, // Not needed for swipe
      snipsCount: 0, // Not needed for swipe
      images: ProfileImages.fromJson(data['images'] as Map<String, dynamic>),
    );
  }

  // Constructor for user profile view (no preferences/orientation)
  factory ProfileModel.fromUserProfile(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel(
      profileId: data['profile_id'] as String,
      username: data['username'] as String,
      name: data['name'] as String,
      bio: data['bio'] as String,
      gender: data['gender'] as String,
      orientation: '', // Not shown in user profile
      age: data['age'] as int,
      location: data['location'] as String,
      interests: (data['interests'] as List<dynamic>).cast<String>(),
      friendsCount: data['friends_count'] as int,
      preferences: const {'min': 0, 'max': 0}, // Not shown in user profile
      rating: (data['rating'] as num).toDouble(),
      datesCount: data['dates_count'] as int,
      postsCount: data['posts_count'] as int,
      snipsCount: data['snips_count'] as int,
      images: ProfileImages.fromJson(data['images'] as Map<String, dynamic>),
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
      'images': images.toJson(),
    };
  }
}

class ProfileImages {
  final String profile;
  final List<String> mandate;
  final List<String> optional;

  ProfileImages({
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

  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'mandate': mandate,
      'optional': optional,
    };
  }
}
