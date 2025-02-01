import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'profile_creation2.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/network/think.dart';
import 'dart:convert';

class ProfileCreation1 extends StatefulWidget {
  const ProfileCreation1({super.key});

  @override
  State<ProfileCreation1> createState() => _ProfileCreation1State();
}

class _ProfileCreation1State extends State<ProfileCreation1> {
  final _bioController = TextEditingController();
  File? _profileImage;
  final List<File> _mediaFiles = [];
  String? _orientation;

  final _orientations = ['Straight', 'Bisexual', 'Gay', 'Lesbian', 'Other'];

  Future<void> _showImageSourceDialog({required bool isProfile}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(isProfile, ImageSource.camera);
                    },
                  ),
                  _imageSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(isProfile, ImageSource.gallery);
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30),
          ),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }

  Future<void> _pickImage(bool isProfile, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else if (_mediaFiles.length < 4) {
            _mediaFiles.add(File(image.path));
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing image. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildImageContainer(int index, {bool isLarge = false}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: FileImage(_mediaFiles[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Delete button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _mediaFiles.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        // Required indicator
        if (index < 2)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyContainer(int index) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(isProfile: false),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 30,
              color: index < 2 ? Colors.black : Colors.grey,
            ),
            if (index < 2) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Updated grid layout
  Widget _buildPhotoGrid(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // First row - 1 large image
          if (_mediaFiles.isNotEmpty)
            Container(
              height: constraints.maxWidth * 0.6,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildImageContainer(0, isLarge: true),
            ),

          // Second row - 3 smaller images
          Row(
            children: [
              for (int i = 1; i < 4; i++)
                Expanded(
                  child: Container(
                    height: constraints.maxWidth * 0.3,
                    margin: EdgeInsets.only(
                      left: i == 1 ? 0 : 8,
                    ),
                    child: _mediaFiles.length > i
                        ? _buildImageContainer(i)
                        : _buildEmptyContainer(i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid') ?? '';

      // Convert images to base64
      final profileImageBase64 =
          base64Encode(await _profileImage!.readAsBytes());
      final mandateImage1Base64 =
          base64Encode(await _mediaFiles[0].readAsBytes());
      final mandateImage2Base64 =
          base64Encode(await _mediaFiles[1].readAsBytes());

      // Optional images
      String? optionalImage1;
      String? optionalImage2;
      if (_mediaFiles.length > 2) {
        optionalImage1 = base64Encode(await _mediaFiles[2].readAsBytes());
        if (_mediaFiles.length > 3) {
          optionalImage2 = base64Encode(await _mediaFiles[3].readAsBytes());
        }
      }

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.pC1Submit(
        uuid: uuid,
        profileImage: profileImageBase64,
        bio: _bioController.text.trim(),
        mandateImage1: mandateImage1Base64,
        mandateImage2: mandateImage2Base64,
        genderOrientation: _orientation!,
        optionalImage1: optionalImage1,
        optionalImage2: optionalImage2,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to submit profile data');
      }

      // Pass data to next screen
      final profileData = {
        'profileImage': _profileImage,
        'bio': _bioController.text,
        'mediaFiles': _mediaFiles,
        'orientation': _orientation,
      };

      if (!mounted) return;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfileCreation2(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Slide from right
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
          settings: RouteSettings(arguments: profileData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  String _getValidationMessage() {
    // Check fields in order of appearance (top to bottom)
    if (_profileImage == null) {
      return 'Please add a profile picture';
    }

    if (_bioController.text.trim().isEmpty) {
      return 'Please write something about yourself';
    }

    if (_orientation == null) {
      return 'Please select your gender orientation';
    }

    if (_mediaFiles.isEmpty) {
      return 'Please add some photos to your profile (minimum 2 required)';
    } else if (_mediaFiles.length == 1) {
      return 'Please add one more photo to your profile';
    } else if (_mediaFiles.length < 2) {
      return 'Please add at least 2 photos to your profile';
    }

    return ''; // All validations passed
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              isIOS ? padding.top : 20,
              20,
              padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Personalise your Profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Profile Picture with Animation
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showImageSourceDialog(isProfile: true);
                          HapticFeedback.lightImpact();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: size.width * 0.35,
                          height: size.width * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _profileImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.add_a_photo, size: 40),
                        ),
                      ),
                      if (_profileImage != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              _showImageSourceDialog(isProfile: true);
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Bio Editor with Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? const Color.fromARGB(255, 0, 0, 0).withAlpha(5)
                            : const Color.fromARGB(255, 255, 255, 255)
                                .withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 350,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write about yourself...',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 0, 0, 0),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),

                // Photos Section
                const Text(
                  'Select your best pictures',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildPhotoGrid(constraints);
                  },
                ),
                SizedBox(height: size.height * 0.03),

                // Gender Orientation Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _orientation,
                    decoration: InputDecoration(
                      labelText: 'Your gender orientation',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    dropdownColor:
                        isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    items: _orientations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _orientation = value;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Next Button
                Center(
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        final validationMessage = _getValidationMessage();
                        if (validationMessage.isEmpty) {
                          HapticFeedback.mediumImpact();
                          _submitProfileData();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(validationMessage),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
