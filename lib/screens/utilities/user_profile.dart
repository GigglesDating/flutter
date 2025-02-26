import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart'; // Add this import
import 'dart:ui'; // Add this import for ImageFilter
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Temporary user data - later will come from backend
  final Map<String, dynamic> userData = {
    'name': 'Kabir singh',
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
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userBio = userData['bio'];
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
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
                      // Report button
                      SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: _showReportSheet,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withAlpha(25),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rest of the content
                _buildProfileHeader(isDarkMode, size),
                _buildStats(isDarkMode, size),
                _buildBioSection(isDarkMode, size),
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
            vertical: size.height * 0.02,
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
            vertical: size.height * 0.02,
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
              Text(
                userBio,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: size.width * 0.035,
                ),
              ),
            ],
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
            vertical: size.height * 0.02,
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
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
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
    final sectionSpacing = size.height * 0.01; // Space between major sections

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spotify Section
          _buildSpotifyWidget(isDarkMode, size),

          SizedBox(height: sectionSpacing), // Consistent spacing

          // Posts Section
          SizedBox(
            height: size.width * 0.8,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: size.width * 0.04),
                  width: size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: Image.asset(
                            'assets/tempImages/posts/post${index + 1}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(
              height: sectionSpacing), // Consistent spacing_buildContentGrids

          // Reels Section
          SizedBox(
            height: size.width * 1.0,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: size.width * 0.04),
                  width: size.width * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Image.asset(
                            'assets/tempImages/reels/reel${index + 1}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _imageSourceOption({
  //   required IconData icon,
  //   required String title,
  //   required bool isDarkMode,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: isDarkMode
  //                 ? Colors.white.withAlpha(38)
  //                 : Colors.black.withAlpha(26),
  //           ),
  //           child: Icon(
  //             icon,
  //             size: 32,
  //             color: isDarkMode ? Colors.white : Colors.black,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             color: isDarkMode ? Colors.white : Colors.black,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final XFile? image = await _picker.pickImage(source: source);
  //     if (image != null) {
  //       final croppedFile = await ImageCropper().cropImage(
  //         sourcePath: image.path,
  //         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //         compressQuality: 90,
  //         uiSettings: [
  //           AndroidUiSettings(
  //             toolbarTitle: 'Crop Image',
  //             toolbarColor: Colors.black,
  //             toolbarWidgetColor: Colors.white,
  //             initAspectRatio: CropAspectRatioPreset.square,
  //             lockAspectRatio: true,
  //             hideBottomControls: true,
  //           ),
  //           IOSUiSettings(
  //             title: 'Crop Image',
  //             aspectRatioLockEnabled: true,
  //             resetAspectRatioEnabled: false,
  //             minimumAspectRatio: 1.0,
  //           ),
  //         ],
  //       );

  //       if (croppedFile != null) {
  //         setState(() {
  //           userData['profileImage'] = croppedFile.path;
  //         });
  //       }
  //     }
  //   } catch (error) {
  //     debugPrint('Error picking/cropping image: $error');
  //   }
  // }

  void _showReportSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
      ),
    );
  }
}
