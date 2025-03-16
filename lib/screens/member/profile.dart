import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Initialize empty user data map - will be populated from API
  final Map<String, dynamic> userData = {
    'name': '',
    'location': '',
    'profileImage': '',
    'friendCount': 0,
    'stats': {
      'posts': 0,
      'dates': 0,
      'rating': 0.0,
    },
    'bio': '',
  };

  late String userBio;
  final ImagePicker _picker = ImagePicker();
  List<SnipModel> _userSnips = [];
  bool _isLoadingSnips = false;
  bool _hasSnipsError = false;
  List<PostModel> _userPosts = [];
  bool _isLoadingPosts = false;
  bool _hasPostsError = false;

  @override
  void initState() {
    super.initState();
    userBio = ''; // Will be updated from API
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    _loadProfileData();
    _loadUserSnips();
    _loadUserPosts(); // Load posts
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

  Future<void> _loadProfileData() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) throw Exception('No UUID found');

      final response =
          await ThinkProvider().fetchProfile(uuid: uuid, profileId: '000');
      final profile = await ProfileModel.parseUserProfile(response);

      if (mounted) {
        setState(() {
          userData['name'] = profile.name;
          userData['age'] = profile.age;
          userData['location'] = profile.location;
          userData['bio'] = profile.bio;
          userBio = profile.bio; // Update userBio from API
          userData['friendCount'] = profile.friendsCount;
          userData['profileImage'] = profile.images.profile;
          userData['interests'] = profile.interests;
          userData['gender'] = profile.gender;
          userData['stats'] = {
            'posts': profile.postsCount,
            'dates': profile.datesCount,
            'rating': profile.rating,
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _loadUserSnips() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSnips = true;
      _hasSnipsError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) throw Exception('No UUID found');

      final response =
          await ThinkProvider().getSnips(uuid: uuid, profileId: '000');
      final snipsResponse = SnipsResponse.fromApiResponse(response);

      if (mounted) {
        setState(() {
          _userSnips = snipsResponse.snips;
          _isLoadingSnips = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user snips: $e');
      if (mounted) {
        setState(() {
          _isLoadingSnips = false;
          _hasSnipsError = true;
        });
      }
    }
  }

  Future<void> _loadUserPosts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingPosts = true;
      _hasPostsError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) throw Exception('No UUID found');

      final response =
          await ThinkProvider().getFeed(uuid: uuid, profileId: '000');

      // Parse posts from response
      final List<dynamic> postsJson = response['data']['posts'];
      final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user posts: $e');
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _hasPostsError = true;
        });
      }
    }
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
                                ? Colors.white.withValues(alpha: 38)
                                : Colors.black.withValues(alpha: 26),
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
                                ? Colors.white.withValues(alpha: 38)
                                : Colors.black.withValues(alpha: 26),
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
          // Use network image from API with fallback to placeholder
          userData['profileImage'].isNotEmpty
              ? Image.network(
                  userData['profileImage'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.black.withValues(alpha: 128),
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * .7,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.elliptical(size.width * 0.8, size.width * 0.8),
                    bottom:
                        Radius.elliptical(size.width * 0.8, size.width * 0.8),
                  ),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 80)
                        : Colors.black.withValues(alpha: 26),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.elliptical(size.width * 0.8, size.width * 0.8),
                    bottom:
                        Radius.elliptical(size.width * 0.8, size.width * 0.8),
                  ),
                  child: Image.network(
                    userData['profileImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Heart icon with friend count overlay
              Positioned(
                top: size.width * 0.76,
                right: size.width * 0.1,
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
                        size: size.width * 0.13,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 50),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      Text(
                        '${userData['friendCount']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 100),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gender icon
              Icon(
                IconMapper.getGenderIcon(userData['gender'] ?? 'unknown'),
                color: isDarkMode ? Colors.white : Colors.black,
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.01),
              // Name
              Text(
                userData['name'] ?? 'Unknown',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: size.width * 0.01),
              // Age
              Text(
                userData['age'] != null ? ", ${userData['age']}" : "",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                userData['location'] ?? 'Unknown location',
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
    final glassColor = isDarkMode
        ? Colors.white.withValues(alpha: 30)
        : Colors.white.withValues(alpha: 150);

    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 51)
        : Colors.black.withValues(alpha: 51);

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
                ? Colors.white.withValues(alpha: 180)
                : Colors.black.withValues(alpha: 180),
            fontSize: size.width * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(bool isDarkMode, Size size) {
    final glassColor = isDarkMode
        ? Colors.white.withValues(alpha: 30)
        : Colors.white.withValues(alpha: 150);

    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 51)
        : Colors.black.withValues(alpha: 51);

    final textColor = isDarkMode ? Colors.white : Colors.black;

    final secondaryTextColor = isDarkMode
        ? Colors.white.withValues(alpha: 180)
        : Colors.black.withValues(alpha: 180);

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
                    // Add gender chip first
                    if (userData['gender'] != null)
                      _buildInterestChip(
                        userData['gender'],
                        IconMapper.getGenderIcon(userData['gender']),
                        textColor,
                        size,
                      ),
                    // Add interests from API
                    if (userData['interests'] != null)
                      ...(userData['interests'] as List<String>).map(
                        (interest) => _buildInterestChip(
                          interest,
                          IconMapper.getIconForInterest(interest),
                          textColor,
                          size,
                        ),
                      ),
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
                  ? Colors.black.withValues(alpha: 230)
                  : Colors.white.withValues(alpha: 230),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 51)
                    : Colors.black.withValues(alpha: 51),
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
                        ? Colors.white.withValues(alpha: 38)
                        : Colors.black.withValues(alpha: 26),
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
                          ? Colors.white.withValues(alpha: 128)
                          : Colors.black.withValues(alpha: 128),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 51)
                            : Colors.black.withValues(alpha: 51),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 51)
                            : Colors.black.withValues(alpha: 51),
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
      String label, IconData icon, Color textColor, Size size) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.04),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: size.width * 0.04,
            color: textColor,
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
    final glassColor = isDarkMode
        ? Colors.white.withValues(alpha: 30)
        : Colors.white.withValues(alpha: 150);

    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 51)
        : Colors.black.withValues(alpha: 51);

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
                    // TODO: Implement Spotify API integration for user music preferences
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
        // Stats Section
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildStats(isDarkMode, size),
        ),

        SizedBox(height: baseSpacing),

        // Bio Section
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildBioSection(isDarkMode, size),
        ),

        SizedBox(height: baseSpacing),

        // Spotify Section
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: _buildSpotifyWidget(isDarkMode, size),
        ),

        SizedBox(height: largerSpacing),

        // Posts Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Text(
            'Posts',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        _buildPostsSection(isDarkMode, size),

        SizedBox(height: largerSpacing),

        // Snips Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Text(
            'Snips',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        _buildSnipsSection(isDarkMode, size),

        // Increase bottom padding to prevent cutoff
        SizedBox(height: size.height * 0.12),
      ],
    );
  }

  Widget _buildPostsSection(bool isDarkMode, Size size) {
    if (_isLoadingPosts) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: CircularProgressIndicator(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    if (_hasPostsError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load posts',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _loadUserPosts,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: Text(
            'No posts yet',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    // Calculate dimensions for horizontal scroll
    final postWidth = size.width * 0.6;
    final postHeight = postWidth * 1.2; // Slightly taller than wide for posts
    final postSpacing = size.width * 0.04;

    return SizedBox(
      height: postHeight,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: size.width * 0.04,
          right: size.width * 0.04,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          final post = _userPosts[index];
          return Container(
            margin: EdgeInsets.only(right: postSpacing),
            width: postWidth,
            child: _buildPostTile(
              context: context,
              post: post,
              index: index,
              isDarkMode: isDarkMode,
              width: postWidth,
              height: postHeight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostTile({
    required BuildContext context,
    required PostModel post,
    required int index,
    required bool isDarkMode,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => _showExpandedPostView(context, index),
      child: Hero(
        tag: 'post_${post.postId}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Post image
              Image.network(
                post.media.source,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                  ),
                ),
              ),

              // Gradient overlay for better visibility of icons
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: height * 0.15,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 179),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Like and comment counts
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: width * 0.06,
                    ),
                    SizedBox(width: 4),
                    Text(
                      post.likesCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: width * 0.06,
                    ),
                    SizedBox(width: 4),
                    Text(
                      post.commentsCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Post author name
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 128),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.authorProfile.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpandedPostView(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierColor: Colors.black87,
      builder: (context) => ExpandedPostView(
        posts: _userPosts,
        initialIndex: initialIndex,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }

  Widget _buildSnipsSection(bool isDarkMode, Size size) {
    if (_isLoadingSnips) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }

    if (_hasSnipsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load snips',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: _loadUserSnips,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userSnips.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Text(
            'No snips yet',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    // Calculate aspect ratio based on the SnipsScreen implementation
    const aspectRatio = 9 / 16; // Standard vertical video aspect ratio
    final snipWidth = size.width * 0.45;
    final snipHeight = snipWidth / aspectRatio;

    return SizedBox(
      height: snipHeight + 20, // Add some padding
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: size.width * 0.04,
          right: size.width * 0.04,
          top: 0,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _userSnips.length,
        itemBuilder: (context, index) {
          final snip = _userSnips[index];
          return _buildSnipTile(
            context: context,
            snip: snip,
            index: index,
            isDarkMode: isDarkMode,
            width: snipWidth,
            height: snipHeight,
          );
        },
      ),
    );
  }

  // Custom SnipTile widget for profile view
  Widget _buildSnipTile({
    required BuildContext context,
    required SnipModel snip,
    required int index,
    required bool isDarkMode,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => _showExpandedSnipView(context, index),
      onDoubleTap: () => _toggleLike(snip),
      child: Container(
        margin: EdgeInsets.only(right: width * 0.1),
        width: width,
        height: height,
        child: Stack(
          children: [
            // Hero widget for animation
            Hero(
              tag: 'snip_${snip.snipId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SnipCard(
                  snip: snip,
                  isProfileView: true,
                  customWidth: width,
                  customHeight: height,
                  isVisible: false, // Don't autoplay in profile view
                  autoPlay: false, // Ensure videos don't play in small view
                ),
              ),
            ),

            // Like count overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 128),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _isSnipLiked(snip) ? Colors.red : Colors.white,
                      size: width * 0.1,
                    ),
                    if (snip.likesCount > 0)
                      Text(
                        snip.likesCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Track liked snips
  final Set<String> _likedSnipIds = {};

  bool _isSnipLiked(SnipModel snip) {
    return _likedSnipIds.contains(snip.snipId);
  }

  void _toggleLike(SnipModel snip) {
    // Add haptic feedback for like/unlike action
    HapticFeedback.mediumImpact();

    setState(() {
      if (_isSnipLiked(snip)) {
        _likedSnipIds.remove(snip.snipId);
      } else {
        _likedSnipIds.add(snip.snipId);
      }
    });
    // TODO: Implement API call to like/unlike snip
  }

  void _showExpandedSnipView(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierColor: Colors.black87,
      builder: (context) => ExpandedSnipView(
        snips: _userSnips,
        initialIndex: initialIndex,
        onLikeToggle: _toggleLike,
        likedSnipIds: _likedSnipIds,
      ),
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
                  ? Colors.white.withValues(alpha: 38)
                  : Colors.black.withValues(alpha: 26),
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
}

// New widget for expanded snip view with horizontal swiping
class ExpandedSnipView extends StatefulWidget {
  final List<SnipModel> snips;
  final int initialIndex;
  final Function(SnipModel) onLikeToggle;
  final Set<String> likedSnipIds;

  const ExpandedSnipView({
    Key? key,
    required this.snips,
    required this.initialIndex,
    required this.onLikeToggle,
    required this.likedSnipIds,
  }) : super(key: key);

  @override
  State<ExpandedSnipView> createState() => _ExpandedSnipViewState();
}

class _ExpandedSnipViewState extends State<ExpandedSnipView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleLike(SnipModel snip) {
    // Add haptic feedback for like/unlike action in expanded view
    HapticFeedback.mediumImpact();
    widget.onLikeToggle(snip);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const aspectRatio = 9 / 16;

    // Calculate dimensions that maintain aspect ratio but don't exceed screen
    double dialogWidth = size.width * 0.9;
    double dialogHeight = dialogWidth / aspectRatio;

    // Ensure dialog doesn't exceed screen height
    if (dialogHeight > size.height * 0.8) {
      dialogHeight = size.height * 0.8;
      dialogWidth = dialogHeight * aspectRatio;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: (size.width - dialogWidth) / 2,
        vertical: (size.height - dialogHeight) / 2,
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          children: [
            // PageView for horizontal swiping
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.snips.length,
              itemBuilder: (context, index) {
                final snip = widget.snips[index];
                return Hero(
                  tag: 'snip_${snip.snipId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SnipCard(
                      snip: snip,
                      isProfileView: false,
                      isVisible:
                          _currentIndex == index, // Only visible when current
                      autoPlay: _currentIndex == index, // Autoplay when current
                      onLike: () => _handleLike(snip),
                      onComment: () => _showCommentsSheet(context, snip),
                      onShare: () => _showShareSheet(context, snip),
                    ),
                  ),
                );
              },
            ),

            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Navigation indicators
            if (widget.snips.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.snips.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 128),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, SnipModel snip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        contentId: snip.snipId,
        contentType: 'snip',
        commentIds: snip.commentIds,
        authorProfile: snip.authorProfile,
        screenHeight: MediaQuery.of(context).size.height,
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  void _showShareSheet(BuildContext context, SnipModel snip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareSheet(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        post: snip.toJson(),
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }
}

// New widget for expanded post view with horizontal swiping
class ExpandedPostView extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;
  final bool isDarkMode;

  const ExpandedPostView({
    Key? key,
    required this.posts,
    required this.initialIndex,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ExpandedPostView> createState() => _ExpandedPostViewState();
}

class _ExpandedPostViewState extends State<ExpandedPostView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate dimensions that maintain aspect ratio but don't exceed screen
    double dialogWidth = size.width * 0.9;
    double dialogHeight = size.height * 0.8;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: (size.width - dialogWidth) / 2,
        vertical: (size.height - dialogHeight) / 2,
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          children: [
            // PageView for horizontal swiping
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.posts.length,
              itemBuilder: (context, index) {
                final post = widget.posts[index];
                return Hero(
                  tag: 'post_${post.postId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PostCard(
                      post: post,
                      isDarkMode: widget.isDarkMode,
                      isProfileView: false,
                      showProfileImage: true,
                      onPostTap:
                          () {}, // No action needed when tapping in expanded view
                    ),
                  ),
                );
              },
            ),

            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Navigation indicators
            if (widget.posts.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.posts.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 128),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
