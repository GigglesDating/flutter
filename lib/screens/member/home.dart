import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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
    },
    // Add more temp posts as needed
  ];

  File? _croppedImage;
  final ImagePicker _picker = ImagePicker();

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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.add_outlined,
              color: isDarkMode ? Colors.white : Colors.black,
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
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.messenger_outline_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStorySection(isDarkMode),
          const SizedBox(height: 20),
          Expanded(child: _buildFeedSection(isDarkMode)),
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
              radius: 30,
            ),
          ),
          Positioned(
            bottom: 3,
            right: 2,
            child: SizedBox(
              width: 24,
              height: 24,
              child: ElevatedButton(
                onPressed: () => showImageModalSheet(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: isDarkMode ? Colors.white24 : Colors.black12,
                ),
                child: Icon(
                  Icons.add,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 18,
                ),
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
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundImage: AssetImage(profile),
          radius: 30,
        ),
      ),
    );
  }

  Widget _buildFeedSection(bool isDarkMode) {
    return ListView.builder(
      itemCount: _tempPosts.length,
      itemBuilder: (context, index) {
        final post = _tempPosts[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(post['userImage']),
                ),
                title: Text(
                  'User Name',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  post['timeAgo'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                trailing: Icon(
                  Icons.more_vert,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Image.asset(
                post['image'],
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post['likes']} likes',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.comment_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post['comments']} comments',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['caption'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showImageModalSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Add Post',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 23),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModalOption(
                      'Camera',
                      'assets/icons/camera_icon.svg',
                      () => pickImage(ImageSource.camera),
                    ),
                    _buildModalOption(
                      'Gallery',
                      'assets/icons/gallery_icon.svg',
                      () => pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption(String label, String icon, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onTap();
            Navigator.pop(context);
          },
          child: Container(
            height: 91,
            width: 91,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withAlpha(100)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SvgPicture.asset(
                icon,
                width: 40,
                height: 36,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff575651),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> pickImage(ImageSource imageType) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: imageType);
      if (pickedImage != null) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Cropper',
            ),
          ],
        );

        if (croppedImage != null) {
          setState(() {
            _croppedImage = File(croppedImage.path);
          });
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
