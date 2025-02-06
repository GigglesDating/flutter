import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../placeholder_template.dart';
import 'navbar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initializeAssets();
    }
  }

  Future<void> _initializeAssets() async {
    try {
      await Future.wait([
        precacheImage(
          const AssetImage('assets/light/bgs/loginbg.png'),
          context,
        ),
      ]);
    } catch (e) {
      debugPrint('Error loading assets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToScreen(String screenName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceholderScreen(
          screenName: screenName,
          message: '$screenName Screen',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: _buildAppBar(isDarkMode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStorySection(isDarkMode, isSmallScreen),
          const SizedBox(height: 20),
          Expanded(
            child: _buildFeedSection(isDarkMode, isSmallScreen),
          ),
        ],
      ),
      bottomNavigationBar: const NavigationController(),
    );
  }

  Widget _buildStorySection(bool isDarkMode, bool isSmallScreen) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: 12,
              left: index == 0 ? 0 : 0,
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/light/bgs/loginbg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Story ${index + 1}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedSection(bool isDarkMode, bool isSmallScreen) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkMode ? 60 : 20),
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
                    backgroundImage:
                        const AssetImage('assets/light/bgs/loginbg.png'),
                    radius: 20,
                  ),
                  title: Text(
                    'User ${index + 1}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '2 hours ago',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/light/bgs/loginbg.png',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Post caption ${index + 1}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      elevation: 0,
      leading: _buildAddButton(isDarkMode),
      actions: _buildActions(isDarkMode),
      centerTitle: true,
      title: _buildTitle(isDarkMode),
    );
  }

  Widget _buildAddButton(bool isDarkMode) {
    return IconButton(
      onPressed: () => _navigateToScreen('Add Story'),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.add_outlined,
          color: isDarkMode ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  List<Widget> _buildActions(bool isDarkMode) {
    return [
      IconButton(
        onPressed: () => _navigateToScreen('Notifications'),
        icon: Icon(
          Icons.notifications_outlined,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      IconButton(
        onPressed: () => _navigateToScreen('Messages'),
        icon: Icon(
          Icons.mail_outline,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    ];
  }

  Widget _buildTitle(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          isDarkMode
              ? 'assets/images/logodarktheme.png'
              : 'assets/images/logolighttheme.png',
          height: 24,
          width: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'iggles',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void showImageModalSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) => const PlaceholderScreen(
        screenName: 'Image Picker',
        message: 'Image Picker Modal',
      ),
    );
  }

  Future<void> pickImage(ImageSource imageType) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: imageType);
      if (pickedImage != null) {
        _navigateToScreen('Image Editor');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
