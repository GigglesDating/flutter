import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final List<File> _mediaFiles = [];
  String? _orientation;
  String? _orientation1;

  RangeValues _currentRangeValues = const RangeValues(18, 60);

  final _orientations = ['Straight', 'Bisexual', 'Gay', 'Lesbian', 'Other'];
  final _orientations1 = ['Men', 'Women', 'Everone', 'Nonbinary'];

  final List<Map<String, dynamic>> _activities = [
    {"name": "movie", "icon": Icons.movie},
    {"name": "coffee", "icon": Icons.coffee},
    {"name": "shopping_bag", "icon": Icons.shopping_bag},
    {"name": "sports_basketball", "icon": Icons.sports_basketball},
    {"name": "music_note", "icon": Icons.music_note},
    {"name": "restaurant", "icon": Icons.restaurant},
    {"name": "sports_esports", "icon": Icons.sports_esports},
    {"name": "fitness_center", "icon": Icons.fitness_center},
    {"name": "book", "icon": Icons.book},
    {"name": "bedroom_baby", "icon": Icons.bedroom_baby},
    {"name": "hiking", "icon": Icons.hiking},
    {"name": "local_bar", "icon": Icons.local_bar},
    {"name": "camera_alt", "icon": Icons.camera_alt},
    {"name": "travel_explore", "icon": Icons.travel_explore},
    {"name": "wine_bar", "icon": Icons.wine_bar},
    {"name": "liquor", "icon": Icons.liquor},
    {"name": "nightlife", "icon": Icons.nightlife},
    {"name": "sports_bar", "icon": Icons.sports_bar},
    {"name": "festival", "icon": Icons.festival},
    {"name": "soup_kitchen", "icon": Icons.soup_kitchen},
    {"name": "door_sliding", "icon": Icons.door_sliding},
    {"name": "deck", "icon": Icons.deck},
    {"name": "house_siding", "icon": Icons.house_siding},
    {"name": "beach_access", "icon": Icons.beach_access},
    {"name": "kayaking", "icon": Icons.kayaking},
    {"name": "directions_bike", "icon": Icons.directions_bike},
    {"name": "terrain", "icon": Icons.terrain},
    {"name": "paragliding", "icon": Icons.paragliding},
    {"name": "settings_accessibility", "icon": Icons.settings_accessibility},
    {"name": "sports_handball_sharp", "icon": Icons.sports_handball_sharp},
    {"name": "sports_tennis", "icon": Icons.sports_tennis},
    {"name": "circle_rounded", "icon": Icons.circle_rounded},
    {"name": "self_improvement", "icon": Icons.self_improvement},
    {"name": "pool", "icon": Icons.pool},
    {"name": "directions_run", "icon": Icons.directions_run},
    {"name": "museum", "icon": Icons.museum},
    {"name": "account_balance", "icon": Icons.account_balance},
    {"name": "theater_comedy", "icon": Icons.theater_comedy},
    {"name": "mic", "icon": Icons.mic},
    {"name": "photo_camera", "icon": Icons.photo_camera},
    {"name": "construction", "icon": Icons.construction},
    {"name": "table_bar", "icon": Icons.table_bar},
    {"name": "casino", "icon": Icons.casino},
    {"name": "mic_external_on", "icon": Icons.mic_external_on},
    {"name": "quiz", "icon": Icons.quiz},
    {"name": "attractions", "icon": Icons.attractions},
    {"name": "gamepad", "icon": Icons.gamepad},
    {"name": "extension", "icon": Icons.extension},
    {"name": "sports_hockey", "icon": Icons.sports_hockey},
    {"name": "gps_fixed", "icon": Icons.gps_fixed},
    {"name": "yard", "icon": Icons.yard},
    {"name": "visibility", "icon": Icons.visibility},
    {"name": "park", "icon": Icons.park},
    {"name": "star_rounded", "icon": Icons.star_rounded},
    {"name": "spa", "icon": Icons.spa},
    {"name": "hot_tub", "icon": Icons.hot_tub},
    {"name": "directions_car", "icon": Icons.directions_car},
    {"name": "menu_book", "icon": Icons.menu_book},
    {"name": "translate", "icon": Icons.translate},
    {"name": "smart_toy", "icon": Icons.smart_toy},
    {"name": "grid_on", "icon": Icons.grid_on},
    {"name": "edit_note", "icon": Icons.edit_note},
    {"name": "science", "icon": Icons.science},
    {"name": "record_voice_over", "icon": Icons.record_voice_over},
    {"name": "directions_car_outlined", "icon": Icons.directions_car_outlined},
    {"name": "holiday_village", "icon": Icons.holiday_village},
    {"name": "location_city", "icon": Icons.location_city},
    {"name": "backpack", "icon": Icons.backpack},
    {"name": "landscape", "icon": Icons.landscape},
    {"name": "tour", "icon": Icons.tour},
    {"name": "temple_hindu", "icon": Icons.temple_hindu},
    {"name": "palette", "icon": Icons.palette},
    {"name": "diamond", "icon": Icons.diamond},
    {"name": "tag_rounded", "icon": Icons.tag_rounded},
    {"name": "photo_album", "icon": Icons.photo_album},
    {"name": "vignette_sharp", "icon": Icons.vignette_sharp},
    {"name": "auto_awesome", "icon": Icons.auto_awesome},
    {"name": "code", "icon": Icons.code},
    {"name": "view_in_ar", "icon": Icons.view_in_ar},
    {"name": "currency_bitcoin", "icon": Icons.currency_bitcoin},
    {"name": "draw", "icon": Icons.draw},
    {"name": "connecting_airports", "icon": Icons.connecting_airports},
    {"name": "build", "icon": Icons.build},
    {"name": "video_camera_front", "icon": Icons.video_camera_front},
    {"name": "local_movies", "icon": Icons.local_movies},
    {"name": "pedal_bike", "icon": Icons.pedal_bike},
    {"name": "sports_cricket", "icon": Icons.sports_cricket},
    {"name": "sports_football", "icon": Icons.sports_football},
    {"name": "sports_martial_arts", "icon": Icons.sports_martial_arts},
    {"name": "track_changes_outlined", "icon": Icons.track_changes_outlined},
    {"name": "sports_volleyball", "icon": Icons.sports_volleyball},
    {"name": "track_changes", "icon": Icons.track_changes},
    {"name": "skateboarding", "icon": Icons.skateboarding},
    {"name": "videocam_sharp", "icon": Icons.videocam_sharp},
    {"name": "ondemand_video", "icon": Icons.ondemand_video},
    {"name": "design_services", "icon": Icons.design_services},
    {"name": "piano", "icon": Icons.piano},
    {"name": "spoke", "icon": Icons.spoke},
    {"name": "crisis_alert", "icon": Icons.crisis_alert},
    {"name": "menu_book_rounded", "icon": Icons.menu_book_rounded},
    {"name": "volunteer_activism", "icon": Icons.volunteer_activism},
  ];

  Set<String> _selectedActivities = Set<String>();
  // Method to toggle selection
  void _toggleSelection(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
  }

  RangeValues _ageRange = const RangeValues(18, 35);

  bool interestgroups = false;

  final _name = TextEditingController();
  final _bio = TextEditingController();

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
                    color: Colors.black),
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
            child: Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    // Responsive calculations
    final buttonWidth = (size.width * 0.9).clamp(200.0, 300.0);
    final horizontalPadding = (size.width * 0.05).clamp(16.0, 24.0);

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
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.arrow_circle_left,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 38,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Edit profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
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
                                border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Name",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? const Color.fromARGB(255, 0, 0, 0)
                                    .withAlpha(5)
                                : const Color.fromARGB(255, 255, 255, 255)
                                    .withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _name,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          fillColor:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          filled: false,
                          suffixIcon: Icon(Icons.edit),
                          hintText: 'name...',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Bio",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? const Color.fromARGB(255, 0, 0, 0)
                                    .withAlpha(5)
                                : const Color.fromARGB(255, 255, 255, 255)
                                    .withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _bio,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Your Gender Orientation",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _orientation,
                        decoration: InputDecoration(
                          hintText: 'Your Gender Orientation',
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
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
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Your Dating Preferences",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _orientation1,
                        decoration: InputDecoration(
                          hintText: 'Your Dating Preferences',
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
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
                        items: _orientations1.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _orientation1 = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        ' Age Preference',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Between ${_currentRangeValues.start.round().toString()} and ${_currentRangeValues.end.round().toString()}',
                            style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          ),
                          RangeSlider(
                            values: _currentRangeValues,
                            min: 18,
                            max: 60,
                            divisions: 100,
                            activeColor: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900],
                            inactiveColor:
                                const Color.fromARGB(255, 168, 168, 168),
                            overlayColor: WidgetStatePropertyAll(isDarkMode
                                ? Colors.grey[900]
                                : Colors.grey[100]),
                            labels: RangeLabels(
                              _currentRangeValues.start.round().toString(),
                              _currentRangeValues.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentRangeValues = values;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        ' Interests',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900],
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(20)),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 items per row
                          childAspectRatio: 3, // Adjust height-to-width ratio
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        physics: ScrollPhysics(),
                        itemCount: _activities.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          String activity = _activities[index]["name"];
                          IconData icon = _activities[index]["icon"];

                          bool isSelected =
                              _selectedActivities.contains(activity);

                          return GestureDetector(
                            onTap: () => _toggleSelection(activity),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      activity,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isSelected
                                              ? Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.white
                                                  : Colors.black
                                              : Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    icon,
                                    size: 12,
                                    color: isSelected
                                        ? Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black
                                        : Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        keyboardPadding > 0
                            ? keyboardPadding + 16
                            : padding.bottom + 20,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.white.withAlpha(5)
                                : Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode ? Colors.white : Colors.black,
                            foregroundColor:
                                isDarkMode ? Colors.black : Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                            disabledBackgroundColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300],
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
                  ]),
            ))));
  }
}
