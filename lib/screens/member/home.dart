import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  // Keep the temp profile images for now
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
      _posts.clear(); // Clear existing posts when reloading
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');
      debugPrint('Loading initial posts for UUID: $uuid');

      if (uuid == null) {
        debugPrint('No UUID found, cannot load posts');
        setState(() => _isLoading = false);
        return;
      }

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getFeed(uuid: uuid);
      debugPrint('Initial feed response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        final feedData = response['data'];
        final posts = feedData['posts'] as List<dynamic>;
        debugPrint('Received ${posts.length} posts');

        setState(() {
          _posts.addAll(_formatPosts(posts));
          _hasMore = feedData['has_more'] ?? false;
          _currentPage = (feedData['next_page'] ?? 2) - 1;
          _isLoading = false;
        });
      } else {
        debugPrint('Error in response: ${response['message']}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');
      debugPrint('Loading more posts for page: ${_currentPage + 1}');

      if (uuid == null) {
        debugPrint('No UUID found, cannot load more posts');
        setState(() => _isLoading = false);
        return;
      }

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getFeed(
        uuid: uuid,
        page: _currentPage + 1,
      );
      debugPrint('More posts response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        final feedData = response['data'];
        final posts = feedData['posts'] as List<dynamic>;
        debugPrint('Received ${posts.length} more posts');

        setState(() {
          _posts.addAll(_formatPosts(posts));
          _hasMore = feedData['has_more'] ?? false;
          _currentPage = (feedData['next_page'] ?? (_currentPage + 2)) - 1;
          _isLoading = false;
        });
      } else {
        debugPrint('Error in response: ${response['message']}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading more posts: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _formatPosts(List<dynamic> posts) {
    debugPrint('Formatting posts: ${posts.length} posts received');
    return posts.map((post) {
      try {
        // Format timestamp for display
        final timestamp = DateTime.parse(post['timestamp']);
        final timeAgo = _getTimeAgo(timestamp);

        // Randomly select a profile picture from local assets for now
        final randomProfilePic = _tempUserProfiles[
            DateTime.now().millisecondsSinceEpoch % _tempUserProfiles.length];

        final formattedPost = {
          'image': post['s3 image url'],
          'isVideo': false, // Default to false for now
          'caption': post['description'] ?? '',
          'likes': post['likes_count'] ?? 0,
          'comments': post['comments_count'] ?? 0,
          'timeAgo': timeAgo,
          'userImage': randomProfilePic,
          'location': 'Bangalore', // Hardcoded for now
        };
        debugPrint('Formatted post: $formattedPost');
        return formattedPost;
      } catch (e) {
        debugPrint('Error formatting post: $e');
        // Return a default post structure if there's an error
        return {
          'image': '',
          'isVideo': false,
          'caption': 'Error loading post',
          'likes': 0,
          'comments': 0,
          'timeAgo': 'now',
          'userImage': _tempUserProfiles[0],
          'location': 'Unknown',
        };
      }
    }).toList();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  void _onScroll() {
    // Handle story section visibility
    if (_scrollController.offset > 20 && _showStories) {
      setState(() => _showStories = false);
    } else if (_scrollController.offset <= 20 && !_showStories) {
      setState(() => _showStories = true);
    }

    // Handle infinite scroll
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      debugPrint('Triggering load more posts');
      _loadMorePosts();
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
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No posts available',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: _loadInitialPosts,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialPosts,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return _buildLoadingIndicator();
          }
          return PostCard(
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
      child: const CircularProgressIndicator(),
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
