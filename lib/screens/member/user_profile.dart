import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'dart:ui'; // Add this import for ImageFilter

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
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
                          // TODO: Implement settings navigation
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
                        onTap: () {
                          // TODO: Implement profile picture upload
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
                _buildStats(isDarkMode, size),
                _buildBioSection(isDarkMode, size),
                _buildSpotifyWidget(isDarkMode, size),
                _buildContentGrids(isDarkMode, size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(Size size) {
    return Container(
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Container - Controls the overall frame size
          Container(
            width: size.width * 1.0, // Controls width of oval
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
                top: Radius.elliptical(size.width * 0.4, size.width * 0.4),
                bottom: Radius.elliptical(size.width * 0.4, size.width * 0.4),
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
            top: size.width * 0.06, // Moved up to overlay profile picture edge
            right:
                size.width * 0.1, // Moved right to overlay profile picture edge
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: size.width * 0.11, // Reduced size
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
    );
  }

  Widget _buildStats(bool isDarkMode, Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30), // More rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              color: Colors.white.withAlpha(51),
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
                child: VerticalDivider(
                  color: Colors.white.withAlpha(51),
                  width: 1,
                ),
              ),
              _buildStatItem(
                  isDarkMode, size, '${userData['stats']['dates']}', 'Dates'),
              SizedBox(
                height: size.height * 0.04,
                child: VerticalDivider(
                  color: Colors.white.withAlpha(51),
                  width: 1,
                ),
              ),
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
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interests List
              SizedBox(
                height: size.width * 0.12,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildInterestChip('Female', '😊', isDarkMode, size),
                    _buildInterestChip('Non-smoker', '🚭', isDarkMode, size),
                    _buildInterestChip(
                        'Social drinker', '🍷', isDarkMode, size),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Bio Text
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withAlpha(26),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      userData['bio'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: size.width * 0.035,
                      ),
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

  Widget _buildInterestChip(
      String label, String emoji, bool isDarkMode, Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          margin: EdgeInsets.only(right: size.width * 0.02),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.width * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(26),
              width: 1,
            ),
          ),
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
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.035,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpotifyWidget(bool isDarkMode, Size size) {
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
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.green,
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
                  Positioned(
                    left: size.width * 0.08,
                    child: SvgPicture.asset(
                      'assets/icons/profile/sound_wave.svg',
                      height: size.width * 0.04,
                      width: size.width * 0.15,
                      colorFilter: ColorFilter.mode(
                        isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: size.width * 0.15),
              Text(
                'My Anthem',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentGrids(bool isDarkMode, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Posts Section
        Container(
          margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
          height: size.width * 0.7, // Height based on aspect ratio
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: size.width * 0.04),
                width: size.width * 0.4, // Width of post
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withAlpha(38)
                        : Colors.black.withAlpha(26),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Post Image with 4:5 aspect ratio
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
                    // Heart and likes count overlay
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: size.width * 0.07,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          Text(
                            '${Random().nextInt(100)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.02,
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
              );
            },
          ),
        ),

        // Reels Section
        Container(
          margin: EdgeInsets.only(top: size.height * 0.02),
          height: size.width * 0.7,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: size.width * 0.04),
                width: size.width * 0.3, // Smaller width for reels
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withAlpha(38)
                        : Colors.black.withAlpha(26),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Reel Thumbnail with 9:16 aspect ratio
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
                    // Play icon overlay
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: size.width * 0.08,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(100),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
