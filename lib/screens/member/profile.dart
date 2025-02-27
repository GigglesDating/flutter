import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_player/video_player.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Temporary user data - later will come from backend
  final Map<String, dynamic> userData = {
    'name': 'Anna Joseph',
    'location': 'Bangalore',
    'profileImage': 'assets/tempImages/users/user1.jpg',
    'friendCount': 27,
    'stats': {
      'posts': 250,
      'dates': 32,
      'rating': 4.5,
    },
    'bio':
        'I can make your coffee healthier. Will probably beat you at go-carting and prefer sunset over sunrise anytime',
  };

  late String userBio;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userBio = userData['bio'];
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    // Don't restore system bars when leaving screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Blurred background
          _buildBackgroundImage(size),

          // Main content with scrolling app bar
          SingleChildScrollView(
            child: Column(
              children: [
                // Custom scrolling app bar
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: size.width * 0.04,
                    right: size.width * 0.04,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Settings icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode
                                ? Colors.white.withAlpha(38)
                                : Colors.black.withAlpha(26),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/profile/settings.svg',
                            width: size.width * 0.05,
                            height: size.width * 0.05,
                            colorFilter: ColorFilter.mode(
                              isDarkMode ? Colors.white : Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      // Profile upload button
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode
                                ? Colors.white.withAlpha(38)
                                : Colors.black.withAlpha(26),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/profile/upload.svg',
                            width: size.width * 0.05,
                            height: size.width * 0.05,
                            colorFilter: ColorFilter.mode(
                              isDarkMode ? Colors.white : Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rest of the content
                _buildProfileHeader(isDarkMode, size),
                _buildContentGrids(isDarkMode, size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            userData['profileImage'],
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.black.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.04,
      ),
      child: Column(
        children: [
          // Main Container - Controls the overall frame size
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * .7, // Controls width of oval
                height: size.width * 0.9, // Controls height of oval
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  // This BorderRadius controls the oval shape of the container
                  borderRadius: BorderRadius.vertical(
                    // Top curve of the oval - adjust multipliers to change shape
                    top: Radius.elliptical(
                      size.width * 0.8, // Horizontal curve at top
                      size.width * 0.8, // Vertical curve at top
                    ),
                    // Bottom curve of the oval - adjust multipliers to change shape
                    bottom: Radius.elliptical(
                      size.width * 0.8, // Horizontal curve at bottom
                      size.width *
                          0.8, // Vertical curve at bottom - larger value makes it more elongated
                    ),
                  ),
                  // Border styling
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withAlpha(80)
                        : Colors.black.withAlpha(26),
                    width: 2,
                  ),
                ),
                // ClipRRect ensures the image follows the same shape as the container
                child: ClipRRect(
                  // This must match the container's BorderRadius exactly
                  borderRadius: BorderRadius.vertical(
                    top: Radius.elliptical(size.width * 0.8, size.width * 0.8),
                    bottom:
                        Radius.elliptical(size.width * 0.8, size.width * 0.8),
                  ),
                  child: Image.asset(
                    userData['profileImage'],
                    fit: BoxFit.cover, // Controls how image fills the space
                    // You can adjust alignment to control which part of image is visible
                    // alignment: Alignment.topCenter,  // Uncomment to focus on top of image
                  ),
                ),
              ),

              // Heart icon with friend count overlay - positioned half in/out of profile picture
              Positioned(
                top: size.width *
                    0.76, // Moved up to overlay profile picture edge
                right: size.width *
                    0.1, // Moved right to overlay profile picture edge
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LikedAccounts(),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: size.width * 0.13, // Reduced size
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      Text(
                        '${userData['friendCount']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width *
                              0.035, // Adjusted text size to match smaller heart
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Name and Location
          SizedBox(height: size.height * 0.02),
          Text(
            userData['name'],
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: size.width * 0.04,
              ),
              SizedBox(width: size.width * 0.01),
              Text(
                userData['location'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: size.width * 0.035,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDarkMode, Size size) {
    final glassColor =
        isDarkMode ? Colors.white.withAlpha(30) : Colors.white.withAlpha(150);

    final borderColor =
        isDarkMode ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                  isDarkMode, size, '${userData['stats']['posts']}', 'Posts'),
              SizedBox(
                  height: size.height * 0.04,
                  child: VerticalDivider(color: borderColor)),
              _buildStatItem(
                  isDarkMode, size, '${userData['stats']['dates']}', 'Dates'),
              SizedBox(
                  height: size.height * 0.04,
                  child: VerticalDivider(color: borderColor)),
              _buildStatItem(
                  isDarkMode, size, '${userData['stats']['rating']}', 'Rating'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      bool isDarkMode, Size size, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withAlpha(180)
                : Colors.black.withAlpha(180),
            fontSize: size.width * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(bool isDarkMode, Size size) {
    final glassColor =
        isDarkMode ? Colors.white.withAlpha(30) : Colors.white.withAlpha(150);

    final borderColor =
        isDarkMode ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51);

    final textColor = isDarkMode ? Colors.white : Colors.black;

    final secondaryTextColor =
        isDarkMode ? Colors.white.withAlpha(180) : Colors.black.withAlpha(180);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * 0.08,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildInterestChip('Female', '😊', textColor, size),
                    _buildInterestChip('Non-smoker', '🚭', textColor, size),
                    _buildInterestChip('Social drinker', '🍷', textColor, size),
                    _buildInterestChip('Foodie', '🍕', textColor, size),
                    _buildInterestChip('Travel', '✈️', textColor, size),
                    _buildInterestChip('Music', '🎵', textColor, size),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              GestureDetector(
                onTap: () => _showBioEditSheet(context, isDarkMode, size),
                child: Text(
                  userBio,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: size.width * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBioEditSheet(BuildContext context, bool isDarkMode, Size size) {
    final TextEditingController bioController =
        TextEditingController(text: userBio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: size.width * 0.04,
              right: size.width * 0.04,
              top: size.width * 0.04,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withAlpha(230)
                  : Colors.white.withAlpha(230),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withAlpha(51)
                    : Colors.black.withAlpha(51),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size.width * 0.15,
                  height: 4,
                  margin: EdgeInsets.only(bottom: size.width * 0.04),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withAlpha(38)
                        : Colors.black.withAlpha(26),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TextField(
                  controller: bioController,
                  maxLines: 4,
                  maxLength: 350,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: size.width * 0.035,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write about yourself...',
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withAlpha(128)
                          : Colors.black.withAlpha(128),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withAlpha(51)
                            : Colors.black.withAlpha(51),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withAlpha(51)
                            : Colors.black.withAlpha(51),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          userBio = bioController.text;
                          // Update the userData map as well if needed
                          userData['bio'] = userBio;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(
      String label, String emoji, Color textColor, Size size) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.04),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: size.width * 0.04),
          ),
          SizedBox(width: size.width * 0.02),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: size.width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyWidget(bool isDarkMode, Size size) {
    final glassColor =
        isDarkMode ? Colors.white.withAlpha(30) : Colors.white.withAlpha(150);

    final borderColor =
        isDarkMode ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51);

    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Spotify Icon
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: Color(0xFF1DB954),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/profile/spotify.svg',
                  width: size.width * 0.06,
                  height: size.width * 0.06,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              // Sound Wave
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: SvgPicture.asset(
                    'assets/icons/profile/sound_wave.svg',
                    height: size.width * 0.04,
                    fit: BoxFit.fitWidth,
                    colorFilter: ColorFilter.mode(
                      textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // Connect Button
              SizedBox(
                height: size.width * 0.08,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Spotify connection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                    ),
                  ),
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentGrids(bool isDarkMode, Size size) {
    // Define consistent spacing values
    final baseSpacing = size.height * 0.03;
    final largerSpacing = baseSpacing * 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Section (modify _buildStats to remove its vertical margin)
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildStats(isDarkMode, size),
        ),

        SizedBox(height: baseSpacing),

        // Bio Section (modify _buildBioSection to remove its vertical margin)
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildBioSection(isDarkMode, size),
        ),

        SizedBox(height: baseSpacing),

        // Spotify Section (modify _buildSpotifyWidget to remove its vertical margin)
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildSpotifyWidget(isDarkMode, size),
        ),

        SizedBox(height: largerSpacing),

        // Posts Section
        SizedBox(
          height: size.width * 0.8,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _showPostOverlay(context, index, isDarkMode),
              child: Hero(
                tag: 'post_profile_$index',
                child: Container(
                  margin: EdgeInsets.only(right: size.width * 0.04),
                  width: size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: Image.asset(
                        'assets/tempImages/posts/post${index + 1}.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: largerSpacing),

        // Reels Section
        SizedBox(
          height: size.width * .9,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) =>
                _buildReelThumbnail(index, size, isDarkMode),
          ),
        ),

        // Increase bottom padding to prevent cutoff
        SizedBox(height: size.height * 0.12), // Increased from 0.02 to 0.12
      ],
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _imageSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            userData['profileImage'] = croppedFile.path;
          });
        }
      }
    } catch (error) {
      debugPrint('Error picking/cropping image: $error');
    }
  }

  void _showPostOverlay(BuildContext context, int index, bool isDarkMode) {
    final Map<String, dynamic> postData = {
      'image': 'assets/tempImages/posts/post${index + 1}.png',
      'isVideo': false,
      'caption': '',
      'likes': 0,
      'comments': 0,
      'timeAgo': '',
      'userImage': userData['profileImage'],
      'userName': userData['name'],
      'location': userData['location'],
    };

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 100),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0 && index > 0) {
                Navigator.pop(context);
                _showPostOverlay(context, index - 1, isDarkMode);
              } else if (details.primaryVelocity! < 0 && index < 5) {
                Navigator.pop(context);
                _showPostOverlay(context, index + 1, isDarkMode);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Post Card with custom more button handler
                SizedBox(
                  width: size.width * 0.95,
                  height: size.width * 1.4,
                  child: PostCard(
                    post: postData,
                    isDarkMode: isDarkMode,
                    onMoreTap: () => _showDeletePostDialog(context, index),
                  ),
                ),

                // Navigation indicators
                if (index > 0)
                  Positioned(
                    left: size.width * 0.02,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white.withValues(alpha: 128),
                      size: 24,
                    ),
                  ),
                if (index < 5)
                  Positioned(
                    right: size.width * 0.02,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withValues(alpha: 128),
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this new method to handle post deletion
  void _showDeletePostDialog(BuildContext context, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Delete Post?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle post deletion here
              // TODO: Implement actual deletion logic
              Navigator.pop(context); // Close delete dialog
              Navigator.pop(context); // Close post overlay
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to handle video initialization with error catching
  Future<VideoPlayerController> _initializeVideoController(
      String videoPath) async {
    final controller = VideoPlayerController.asset(videoPath);
    try {
      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('Video initialization error: $e');
      // Create a fallback controller with lower quality settings
      final fallbackController = VideoPlayerController.asset(
        videoPath,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      await fallbackController.initialize();
      return fallbackController;
    }
  }

  // Update the _getVideoThumbnail method
  Future<String?> _getVideoThumbnail(String videoPath) async {
    try {
      final controller = await _initializeVideoController(videoPath);
      await controller.seekTo(const Duration(milliseconds: 100));
      await controller.pause();
      controller.dispose();
      return videoPath;
    } catch (e) {
      debugPrint('Thumbnail generation error: $e');
      return null;
    }
  }

  // Update the reels section
  Widget _buildReelThumbnail(int index, Size size, bool isDarkMode) {
    final String videoPath = 'assets/video/${(index % 3) + 1}.mp4';

    return FutureBuilder<String?>(
      future: _getVideoThumbnail(videoPath),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () => _showReelOverlay(context, index, isDarkMode),
          child: Container(
            margin: EdgeInsets.only(right: size.width * 0.04),
            width: size.width * 0.55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: snapshot.hasData
                        ? VideoPlayer(
                            VideoPlayerController.asset(snapshot.data!)
                              ..initialize())
                        : Container(color: Colors.black),
                  ),
                ),
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: size.width * 0.1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReelOverlay(BuildContext context, int index, bool isDarkMode) {
    final videoAssets = [
      'assets/video/1.mp4',
      'assets/video/2.mp4',
      'assets/video/3.mp4',
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 128),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video Container
              Container(
                width: size.width,
                height: size.height * 0.77,
                color: Colors.black,
                child: ReelCard(
                  videoPath: videoAssets[index % 3],
                  isDarkMode: isDarkMode,
                  index: index,
                  onNext: index < 5
                      ? () {
                          Navigator.pop(context);
                          _showReelOverlay(context, index + 1, isDarkMode);
                        }
                      : null,
                  onPrevious: index > 0
                      ? () {
                          Navigator.pop(context);
                          _showReelOverlay(context, index - 1, isDarkMode);
                        }
                      : null,
                ),
              ),

              // Navigation indicators
              if (index > 0)
                Positioned(
                  left: size.width * 0.02,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withValues(alpha: 128),
                    size: 24,
                  ),
                ),
              if (index < 5)
                Positioned(
                  right: size.width * 0.02,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 128),
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
