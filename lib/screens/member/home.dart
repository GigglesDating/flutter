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
  final int _preloadDistance = 2;
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
  bool _showStories = true;
  File? _croppedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialPosts();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isInitialLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) {
        throw Exception('No UUID found');
      }

      debugPrint('🔍 Checking cache for initial posts...');
      // Check cache first
      final cachedPosts =
          await CacheService.getCachedData('feed_posts_initial');
      if (cachedPosts != null) {
        debugPrint('✅ Cache hit! Using cached posts');
        final posts = PostModel.fromApiResponse({
          'status': 'success',
          'data': cachedPosts,
        });

        setState(() {
          _posts.addAll(posts);
          _isLoading = false;
          _isInitialLoading = false;
        });

        // Preload media for cached posts
        debugPrint('🖼️ Preloading media for ${posts.length} cached posts');
        _preloadPostResources(posts);

        // Fetch fresh data in background
        debugPrint('🔄 Fetching fresh posts in background');
        _fetchFreshPosts(uuid);
        return;
      }

      debugPrint('❌ Cache miss, fetching fresh posts');
      await _fetchFreshPosts(uuid);
    } catch (e) {
      debugPrint('❌ Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoading = false;
          _isError = true;
          _errorMessage = 'Failed to load posts. Please try again.';
        });
      }
    }
  }

  Future<void> _fetchFreshPosts(String uuid) async {
    try {
      debugPrint('Fetching fresh posts for UUID: $uuid');

      // Use compute for the API call and initial processing
      final response = await compute(
        (uuid) => ThinkProvider().getFeed(uuid: uuid),
        uuid,
      );
      debugPrint('Raw API response: $response');

      if (!mounted) return;

      if (response['status'] == 'success' && response['data'] != null) {
        debugPrint('Response status: success');
        debugPrint('Posts data: ${response['data']['posts']}');

        // Use compute for parsing posts to keep it off main thread
        final newPosts = await compute(
          (response) => PostModel.fromApiResponse(response),
          response,
        );
        debugPrint('Parsed ${newPosts.length} posts');

        // Cache the posts
        await CacheService.cacheData(
          key: 'feed_posts_initial',
          data: response['data'],
          duration: const Duration(minutes: 15),
        );

        setState(() {
          _posts.clear();
          _posts.addAll(newPosts);
          _hasMore = response['data']['has_more'] ?? false;
          _currentPage = 1;
          _isLoading = false;
          _isInitialLoading = false;
        });

        // Preload resources for visible and next few posts
        _preloadPostResources(newPosts);
      } else {
        debugPrint('Error response: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to load posts');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _fetchFreshPosts: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoading = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
      rethrow;
    }
  }

  void _preloadPostResources(List<PostModel> posts) async {
    final videoUrls = <String>[];
    final thumbnailUrls = <String>[];

    debugPrint('📦 Starting resource preload for ${posts.length} posts');

    for (var i = 0; i < posts.length && i < _preloadDistance + 5; i++) {
      final post = posts[i];

      // Add media URLs for preloading
      if (post.media.type == 'video') {
        videoUrls.add(post.media.source);
        debugPrint('🎥 Added video for preload: ${post.media.source}');
      } else {
        thumbnailUrls.add(post.media.source);
        debugPrint('🖼️ Added image for preload: ${post.media.source}');
      }

      // Add profile image for preloading
      thumbnailUrls.add(post.authorProfile.profileImage);
      debugPrint(
          '👤 Added profile image for preload: ${post.authorProfile.profileImage}');

      // Preload comments if not already loaded
      final commentsCacheKey = 'comments_${post.postId}_1';
      final cachedComments = await CacheService.getCachedData(commentsCacheKey);
      if (cachedComments == null && post.commentIds.isNotEmpty) {
        debugPrint('💬 Preloading comments for post: ${post.postId}');
        _preloadComments(post.postId);
      } else if (cachedComments != null) {
        debugPrint('✅ Using cached comments for post: ${post.postId}');
      }
    }

    // Get cache stats before preload
    final beforeStats = await CacheService.getCacheStats();
    debugPrint('📊 Cache stats before preload: $beforeStats');

    // Preload media using CacheService
    debugPrint('🚀 Starting media preload');
    debugPrint('📹 Videos to preload: ${videoUrls.length}');
    debugPrint('🖼️ Images to preload: ${thumbnailUrls.length}');

    await CacheService.preloadMedia(
      videoUrls: videoUrls,
      thumbnailUrls: thumbnailUrls,
      priority: CachePriority.high,
    );

    // Get cache stats after preload
    final afterStats = await CacheService.getCacheStats();
    debugPrint('📊 Cache stats after preload: $afterStats');
  }

  Future<void> _preloadComments(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');
      if (uuid == null) return;

      final response = await ThinkProvider().fetchComments(
        uuid: uuid,
        contentId: postId,
        contentType: 'post',
        page: 1,
        pageSize: 10,
      );

      if (response['status'] == 'success') {
        await CacheService.cacheData(
          key: 'comments_${postId}_1',
          data: response['data'],
          duration: const Duration(minutes: 30),
        );
      }
    } catch (e) {
      debugPrint('Error preloading comments for post $postId: $e');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoading = true;
      _isLoadingMore = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) {
        throw Exception('No UUID found');
      }

      debugPrint('Loading more posts for page: ${_currentPage + 1}');

      // Create a properly typed map for compute parameters
      final params = {
        'uuid': uuid as String,
        'page': (_currentPage + 1) as int,
      };

      final response = await compute(
        (Map<String, dynamic> params) => ThinkProvider().getFeed(
          uuid: params['uuid'] as String,
          page: params['page'] as int,
        ),
        params,
      );
      debugPrint('Load more response: $response');

      if (!mounted) return;

      if (response['status'] == 'success' && response['data'] != null) {
        final newPosts = await compute(
          (Map<String, dynamic> response) =>
              PostModel.fromApiResponse(response),
          response,
        );
        debugPrint('Loaded ${newPosts.length} more posts');

        setState(() {
          if (newPosts.isEmpty) {
            _hasMore = false;
          } else {
            _posts.addAll(newPosts);
            _hasMore = response['data']['has_more'] ?? false;
            _currentPage += 1;
          }
          _isLoading = false;
          _isLoadingMore = false;
        });

        _preloadPostResources(newPosts);
      } else {
        throw Exception(response['message'] ?? 'Failed to load more posts');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading more posts: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (e.toString().contains('No more posts')) {
            _hasMore = false;
          }
        });
      }
    }
  }

  void _onScroll() {
    // Handle story section visibility
    if (_scrollController.offset > 20 && _showStories) {
      setState(() => _showStories = false);
    } else if (_scrollController.offset <= 20 && !_showStories) {
      setState(() => _showStories = true);
    }

    // Debug prints
    debugPrint('Scroll position: ${_scrollController.position.pixels}');
    debugPrint(
        'Max scroll extent: ${_scrollController.position.maxScrollExtent}');
    debugPrint('hasMore: $_hasMore');
    debugPrint('isLoading: $_isLoading');
    debugPrint('Posts length: ${_posts.length}');

    // Handle infinite scroll with better threshold
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.85) {
      debugPrint('Triggering load more posts');
      _loadMorePosts();
    }

    // Check if we've reached the end
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_hasMore &&
        !_isLoading) {
      debugPrint('Reached end of feed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
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
              isDarkMode
                  ? 'assets/dark/favicon.png'
                  : 'assets/light/favicon.png',
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
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showStories ? 85 : 0,
            child: _buildStorySection(isDarkMode),
          ),
          Expanded(
            child: _buildFeedSection(isDarkMode),
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

  Widget _buildFeedSection(bool isDarkMode) {
    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isError) {
      return Center(
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
    }

    return RefreshIndicator(
      onRefresh: _loadInitialPosts,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length +
            1, // Always add one more item for either loading or end indicator
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            debugPrint('Rendering last item. hasMore: $_hasMore');
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
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 20,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
