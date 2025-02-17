import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../utilities/post_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> _tempUserProfiles = [
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
  ];

  final List<Map<String, dynamic>> _tempPosts = [
    {
      'image': 'assets/tempImages/posts/post1.png',
      'isVideo': false,
      'caption': 'Beautiful day!',
      'likes': 123,
      'comments': 45,
      'timeAgo': '3h ago',
      'userImage': 'assets/tempImages/users/user2.jpg',
      'userName': 'Sarah Parker',
      'location': 'New York, USA',
    },
    {
      'image': 'assets/tempImages/posts/post3.png',
      'isVideo': true,
      'caption': 'Amazing sunset at the beach! 🌅 #sunset #beach #vibes',
      'likes': 456,
      'comments': 89,
      'timeAgo': '5h ago',
      'userImage': 'assets/tempImages/users/user3.jpg',
      'userName': 'Mike Johnson',
      'location': 'Miami Beach, FL',
    },
  ];

  final ScrollController _scrollController = ScrollController();
  bool _showStories = true;
  File? _croppedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    print("InitState: _tempPosts length: ${_tempPosts.length}"); // Debug print
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && _showStories) {
      setState(() => _showStories = false);
    } else if (_scrollController.offset <= 20 && !_showStories) {
      setState(() => _showStories = true);
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
          _buildMyStory(isDarkMode),
          ..._tempUserProfiles
              .map((profile) => _buildStoryItem(profile, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildMyStory(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/tempImages/users/user1.jpg'),
              radius: 35,
            ),
          ),
          Positioned(
            bottom: 3,
            right: 2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white
                        .withAlpha(51) // 0.2 opacity for better visibility
                    : Colors.black
                        .withAlpha(38), // 0.15 opacity for better visibility
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.black,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
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
    print(
        "Building feed section with ${_tempPosts.length} posts"); // Debug print
    return ListView.builder(
      controller: _scrollController,
      itemCount: _tempPosts.length,
      itemBuilder: (context, index) {
        print("Building post card at index $index"); // Debug print
        return PostCard(
          post: _tempPosts[index],
          isDarkMode: isDarkMode,
        );
      },
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
