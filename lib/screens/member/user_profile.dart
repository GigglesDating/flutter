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
      appBar: _buildAppBar(isDarkMode, size),
      body: Stack(
        children: [
          // Blurred background
          _buildBackgroundImage(size),

          // Main content
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  _buildProfileHeader(isDarkMode, size),
                  _buildStats(isDarkMode, size),
                  _buildBioSection(isDarkMode, size),
                  _buildSpotifyWidget(isDarkMode, size),
                  _buildContentGrids(isDarkMode, size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, Size size) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.only(left: size.width * 0.02),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode
              ? Colors.white.withAlpha(80)
              : Colors.black.withAlpha(26),
        ),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: isDarkMode ? Colors.white : Colors.black,
            size: size.width * 0.06,
          ),
          onPressed: () {
            // TODO: Implement settings navigation
          },
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: size.width * 0.02),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode
                ? Colors.white.withAlpha(80)
                : Colors.black.withAlpha(26),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/profile/profile_pic_upload.svg',
              width: size.width * 0.06,
              height: size.width * 0.06,
              colorFilter: ColorFilter.mode(
                isDarkMode ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              // TODO: Implement profile picture upload
            },
          ),
        ),
      ],
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

          // Friend count heart icon overlay
          Positioned(
            top: size.width * 0.05,
            right: size.width * 0.15,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.width * 0.015,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: size.width * 0.045,
                  ),
                  SizedBox(width: size.width * 0.01),
                  Text(
                    '${userData['friendCount']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDarkMode, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
                isDarkMode, size, '${userData['stats']['posts']}', 'Posts'),
          ),
          Container(
            height: size.height * 0.04,
            width: 1,
            color: isDarkMode
                ? Colors.white.withAlpha(50)
                : Colors.black.withAlpha(26),
          ),
          Expanded(
            child: _buildStatItem(
                isDarkMode, size, '${userData['stats']['dates']}', 'Dates'),
          ),
          Container(
            height: size.height * 0.04,
            width: 1,
            color: isDarkMode
                ? Colors.white.withAlpha(50)
                : Colors.black.withAlpha(26),
          ),
          Expanded(
            child: _buildStatItem(
                isDarkMode, size, '${userData['stats']['rating']}', 'Rating'),
          ),
        ],
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
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withAlpha(20)
            : Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scrollable preferences
          SizedBox(
            height: size.height * 0.05,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPreferenceChip(isDarkMode, size, '👩 Female'),
                _buildPreferenceChip(isDarkMode, size, '🚭 Non-smoker'),
                _buildPreferenceChip(isDarkMode, size, '🍷 Social drinker'),
                _buildPreferenceChip(isDarkMode, size, '🎵 Music lover'),
                _buildPreferenceChip(isDarkMode, size, '🏃‍♀️ Active'),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Bio text
          GestureDetector(
            onTap: () {
              // TODO: Implement bio edit functionality
            },
            child: Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withAlpha(10)
                    : Colors.black.withAlpha(5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withAlpha(30)
                      : Colors.black.withAlpha(20),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      userData['bio'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: size.width * 0.035,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: isDarkMode
                        ? Colors.white.withAlpha(150)
                        : Colors.black.withAlpha(150),
                    size: size.width * 0.045,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(bool isDarkMode, Size size, String label) {
    return Container(
      margin: EdgeInsets.only(right: size.width * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.width * 0.015,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withAlpha(30)
            : Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: size.width * 0.035,
        ),
      ),
    );
  }

  Widget _buildSpotifyWidget(bool isDarkMode, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withAlpha(20)
            : Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Spotify Icon
          Container(
            padding: EdgeInsets.all(size.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/profile/spotify.png',
              width: size.width * 0.06,
              height: size.width * 0.06,
              color: Colors.white,
            ),
          ),

          SizedBox(width: size.width * 0.03),

          // Wave Animation and Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Anthem',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withAlpha(150)
                        : Colors.black.withAlpha(150),
                    fontSize: size.width * 0.035,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                // Placeholder Wave Animation
                Container(
                  height: size.height * 0.03,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      20,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        width: 3,
                        height: (index % 3 + 1) * 8.0,
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(100),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Connect Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.width * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
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
        ],
      ),
    );
  }

  Widget _buildContentGrids(bool isDarkMode, Size size) {
    // Temporary post data - will come from backend later
    final List<String> posts = [
      'assets/tempImages/posts/post1.png',
      'assets/tempImages/posts/post2.jpg',
      'assets/tempImages/posts/post3.png',
      'assets/tempImages/posts/post4.png',
    ];

    final List<String> reels = [
      'assets/tempImages/reels/reel1.png',
      'assets/tempImages/reels/reel2.jpg',
      'assets/tempImages/reels/reel3.png',
      'assets/tempImages/reels/reel4.png',
    ];

    return Column(
      children: [
        // Posts Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Posts',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              _buildGrid(isDarkMode, size, posts),
            ],
          ),
        ),

        // Reels Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reels',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              _buildGrid(isDarkMode, size, reels),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(bool isDarkMode, Size size, List<String> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: size.width * 0.03,
        mainAxisSpacing: size.width * 0.03,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            // Content Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withAlpha(30)
                      : Colors.black.withAlpha(20),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  items[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Like Count
            Positioned(
              top: size.width * 0.02,
              right: size.width * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.width * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: size.width * 0.035,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      '${Random().nextInt(100)}', // Temporary random likes
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
