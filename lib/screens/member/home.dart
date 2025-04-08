import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../services/cache_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isError = false;
  String _errorMessage = '';

  // Track loading states
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;

  // Story profiles list
  final List<String> _tempUserProfiles = [
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
  ];

  final ScrollController _scrollController = ScrollController();
  final bool _showStories = true;
  File? _croppedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Delay initial load to allow UI to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPosts();
      _checkAuthentication();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
        _isInitialLoading = true;
        _errorMessage = '';
      });

      final uuid = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('user_uuid'));

      if (uuid == null) {
        throw Exception('User UUID not found');
      }

      // Use compute to move heavy operations off the main thread
      final result = await compute(_loadPostsInBackground, {
        'page': _currentPage,
        'uuid': uuid,
      });

      if (!mounted) return;

      if (result['error'] == true) {
        setState(() {
          _isError = true;
          _errorMessage = result['errorMessage'] as String;
          _isLoading = false;
          _isInitialLoading = false;
        });
        return;
      }

      final posts = result['posts'] as List<PostModel>;

      setState(() {
        _posts.addAll(posts);
        _isLoading = false;
        _isInitialLoading = false;
        _isError = false;
        _errorMessage = '';
      });

      // Preload author images and comments for the loaded posts
      _preloadPostResources(posts);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load posts: $e';
        _isLoading = false;
        _isInitialLoading = false;
      });
    }
  }

  // Background function to load posts
  static Future<Map<String, dynamic>> _loadPostsInBackground(
      Map<String, dynamic> params) async {
    try {
      final posts =
          await _fetchPosts(params['page'] as int, params['uuid'] as String);
      return {
        'posts': posts,
        'error': false,
        'errorMessage': '',
      };
    } catch (e) {
      debugPrint('Error loading posts in background: $e');
      return {
        'posts': <PostModel>[],
        'error': true,
        'errorMessage': e.toString(),
      };
    }
  }

  // Static method to fetch posts
  static Future<List<PostModel>> _fetchPosts(int page, String uuid) async {
    try {
      // Check cache first
      try {
        final cachedPosts =
            await CacheService.getCachedData('feed_posts_$page');
        if (cachedPosts != null) {
          debugPrint('Using cached posts for page $page');
          return PostModel.fromApiResponse({
            'status': 'success',
            'data': cachedPosts,
          });
        }
      } catch (e) {
        debugPrint('Error accessing cache: $e');
        // Continue to fetch fresh data if cache fails
      }

      // Fetch fresh data
      debugPrint('Fetching fresh posts for page $page');
      final response = await ThinkProvider().getFeed(
        uuid: uuid,
        page: page,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final posts = PostModel.fromApiResponse(response);

        // Try to cache the posts, but don't fail if caching fails
        try {
          await CacheService.cacheData(
            key: 'feed_posts_$page',
            data: response['data'],
            duration: const Duration(minutes: 15),
          );
          debugPrint('Cached posts for page $page');
        } catch (e) {
          debugPrint('Error caching posts: $e');
          // Continue even if caching fails
        }

        return posts;
      } else {
        throw Exception(response['message'] ?? 'Failed to load posts');
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Use compute to move heavy operations off the main thread
    await compute(_loadPostsInBackground, {
      'page': _currentPage,
      'uuid': await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('user_uuid')),
    }).then((result) {
      if (!mounted) return;

      final posts = result['posts'] as List<PostModel>;
      setState(() {
        _posts.addAll(posts);
        _isLoadingMore = false;
        _hasMore = posts.isNotEmpty;
      });

      // Preload resources for the newly loaded posts
      _preloadPostResources(posts);
    });
  }

  // Preload resources for posts (author images, comments, comment author images)
  void _preloadPostResources(List<PostModel> posts) {
    // Use a microtask to avoid blocking the UI thread
    Future.microtask(() async {
      try {
        // Get the first 5 posts (or fewer if less than 5 posts are available)
        final postsToPreload = posts.take(5).toList();
        final authorIds = <String>{};
        final authorImageUrls = <String>{};

        // Collect all author information first
        for (final post in postsToPreload) {
          // Collect author information
          if (post.authorProfileId.isNotEmpty) {
            authorIds.add(post.authorProfileId);
          }
          if (post.authorProfile.profileImage.isNotEmpty) {
            authorImageUrls.add(post.authorProfile.profileImage);
          }
        }

        // Process in parallel using compute
        final futures = <Future<void>>[];

        // Preload author images
        if (authorImageUrls.isNotEmpty) {
          futures.add(compute(_preloadAuthorImages, authorImageUrls.toList()));
        }

        // Pre-cache author profiles
        if (authorIds.isNotEmpty) {
          futures.add(
              compute(_precacheAuthorProfilesInBackground, authorIds.toList()));
        }

        // Preload comments for each post
        for (final post in postsToPreload) {
          futures.add(compute(_preloadCommentsInBackground, {
            'postId': post.postId,
            'uuid': await SharedPreferences.getInstance()
                .then((prefs) => prefs.getString('user_uuid')),
          }));
        }

        // Wait for all operations to complete
        await Future.wait(futures);
      } catch (e) {
        debugPrint('Error preloading post resources: $e');
      }
    });
  }

  // Background function to preload author images
  static Future<void> _preloadAuthorImages(List<String> imageUrls) async {
    try {
      debugPrint('Preloading ${imageUrls.length} author images');
      await CacheService.preloadMedia(
        thumbnailUrls: imageUrls,
        priority: CachePriority.high,
      );
    } catch (e) {
      debugPrint('Error preloading author images: $e');
    }
  }

  // Background function to pre-cache author profiles
  static Future<void> _precacheAuthorProfilesInBackground(
      List<String> authorIds) async {
    try {
      debugPrint('Pre-caching ${authorIds.length} author profiles');
      final uuid = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('user_uuid'));

      if (uuid == null) {
        throw Exception('User UUID not found');
      }

      // Batch fetch author profiles
      final response = await ThinkProvider().fetchAuthorProfiles(
        uuid: uuid,
        authorIds: authorIds,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final profiles = response['data']['profiles'] as List;
        for (final profile in profiles) {
          final authorId = profile['author_id'] as String;
          await CacheService.cacheData(
            key: 'author_profile_$authorId',
            data: profile,
            duration: const Duration(hours: 1), // Cache for 1 hour
          );
        }
      }
    } catch (e) {
      debugPrint('Error pre-caching author profiles: $e');
    }
  }

  // Background function to preload comments
  static Future<void> _preloadCommentsInBackground(
      Map<String, dynamic> params) async {
    try {
      final postId = params['postId'] as String;
      final uuid = params['uuid'] as String;

      final cacheKey = 'post_comments_$postId';

      // Check memory cache first
      final memoryCachedComments =
          await CacheService.getCachedData('${cacheKey}_memory');
      if (memoryCachedComments != null) {
        debugPrint('Using memory cached comments for post $postId');
        _preloadCommentAuthorImagesInBackground(memoryCachedComments);
        return;
      }

      // Check disk cache
      final cachedComments = await CacheService.getCachedData(cacheKey);
      if (cachedComments != null) {
        debugPrint('Using disk cached comments for post $postId');
        _preloadCommentAuthorImagesInBackground(cachedComments);
        return;
      }

      // Fetch fresh comments
      debugPrint('Fetching fresh comments for post $postId');
      final response = await ThinkProvider().fetchComments(
        uuid: uuid,
        contentType: 'post',
        contentId: postId,
        page: 1,
        pageSize: 10,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        // Cache the comments in both memory and disk
        final comments = response['data']['comments'] as List;
        await CacheService.cacheData(
          key: '${cacheKey}_memory',
          data: comments,
          duration: const Duration(minutes: 5), // Short memory cache
        );

        await CacheService.cacheData(
          key: cacheKey,
          data: response['data'],
          duration: const Duration(minutes: 15),
        );

        // Preload comment author images
        _preloadCommentAuthorImagesInBackground(comments);
      }
    } catch (e) {
      debugPrint('Error preloading comments for post ${params['postId']}: $e');
    }
  }

  // Background function to preload comment author images
  static void _preloadCommentAuthorImagesInBackground(List<dynamic> comments) {
    try {
      // Extract unique author image URLs
      final authorImageUrls = comments
          .where((comment) =>
              comment['author'] != null &&
              comment['author']['image_url'] != null &&
              comment['author']['image_url'].toString().isNotEmpty)
          .map((comment) => comment['author']['image_url'].toString())
          .toSet() // Remove duplicates
          .toList();

      if (authorImageUrls.isNotEmpty) {
        debugPrint(
            'Preloading ${authorImageUrls.length} comment author images');
        CacheService.preloadMedia(
          thumbnailUrls: authorImageUrls,
          priority: CachePriority.medium,
        );
      }

      // Also preload reply author images
      final replyAuthorImageUrls = comments
          .expand((comment) => (comment['replies'] as List? ?? []))
          .where((reply) =>
              reply['author'] != null &&
              reply['author']['image_url'] != null &&
              reply['author']['image_url'].toString().isNotEmpty)
          .map((reply) => reply['author']['image_url'].toString())
          .toSet() // Remove duplicates
          .toList();

      if (replyAuthorImageUrls.isNotEmpty) {
        debugPrint(
            'Preloading ${replyAuthorImageUrls.length} reply author images');
        CacheService.preloadMedia(
          thumbnailUrls: replyAuthorImageUrls,
          priority: CachePriority.low,
        );
      }
    } catch (e) {
      debugPrint('Error preloading comment author images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use a more efficient approach for the feed section
    Widget feedSection;
    if (_isInitialLoading) {
      feedSection = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_isError) {
      feedSection = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialPosts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else {
      feedSection = RefreshIndicator(
        onRefresh: _loadInitialPosts,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + 1,
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return _hasMore
                  ? _buildLoadingIndicator()
                  : _buildEndOfFeedIndicator(isDarkMode);
            }

            return PostCard(
              key: ValueKey('post_${_posts[index].postId}'),
              post: _posts[index],
              isDarkMode: isDarkMode,
            );
          },
        ),
      );
    }

    // Build the app bar once to avoid rebuilding it on every frame
    final appBar = AppBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => showImageModalSheet(),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode
                ? Colors.white.withAlpha(38)
                : Colors.black.withAlpha(26),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/feed/plus.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isDarkMode ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 28),
          Image.asset(
            isDarkMode ? 'assets/dark/favicon.png' : 'assets/light/favicon.png',
            height: 24,
            width: 24,
          ),
          const Text('iggles'),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
          },
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/feed/notifications.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/feed/messenger.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Build the story section only if needed
    final storySection = _showStories
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 85,
            child: _buildStorySection(isDarkMode),
          )
        : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: appBar,
      body: Column(
        children: [
          storySection,
          Expanded(
            child: feedSection,
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAddStoryButton(isDarkMode),
          ..._tempUserProfiles
              .map((profile) => _buildStoryItem(profile, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildAddStoryButton(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          width: 65,
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
              width: 1,
            ),
            image: const DecorationImage(
              image: AssetImage('assets/tempImages/users/user1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 6, // Adjusted from center
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.white : Colors.black,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 20,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(String profile, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withAlpha(100),
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          backgroundImage: AssetImage(profile),
          radius: 35,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (_isLoadingMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Loading more posts...',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEndOfFeedIndicator(bool isDarkMode) {
    debugPrint('Building end of feed indicator');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/app/posts_exhaustion.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> showImageModalSheet() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          maxWidth: 1080,
          maxHeight: 1080,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Story',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Crop Story',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _croppedImage = File(croppedFile.path);
            // Add the cropped image to stories
            _tempUserProfiles.insert(1, _croppedImage!.path);
          });
        }
      }
    } catch (error) {
      debugPrint('Error picking/cropping image: $error');
    }
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('user_uuid');
    if (uuid == null) {
      debugPrint('User not authenticated, navigating to login');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // Initialize CacheService
//   Future<void> _initializeCacheService() async {
//     // No need to initialize CacheService here as it's already initialized in main.dart
//     // This method is kept for backward compatibility
//     debugPrint('CacheService initialization check in HomeTab');
//   }
// }

// class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
//   @override
//   (int, int)? get data => (2, 3);

//   @override
//   String get name => '2x3 (customized)';
// }

// class AppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, 0);
//     path.lineTo(0, size.height);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height - 20,
//       size.width,
//       size.height,
//     );
//     path.lineTo(size.width, 0);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
