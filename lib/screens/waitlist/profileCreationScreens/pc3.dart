import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '/../network/auth_provider.dart';

class ProfileCreation3 extends StatefulWidget {
  const ProfileCreation3({super.key});

  @override
  State<ProfileCreation3> createState() => _ProfileCreation3State();
}

class _ProfileCreation3State extends State<ProfileCreation3> {
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedDefaultInterests = {};
  final Set<String> _customInterests = {};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customInterestController =
      TextEditingController();
  String _searchQuery = '';
  bool _isAddingCustom = false;
  final FocusNode _customInterestFocus = FocusNode();
  List<Map<String, dynamic>> _defaultInterests = [];
  bool _isLoading = true;

  final Map<String, IconData> iconMapping = {
    'movie': Icons.movie,
    'coffee': Icons.coffee,
    'shopping_bag': Icons.shopping_bag,
    'sports_basketball': Icons.sports_basketball,
    'music_note': Icons.music_note,
    'restaurant': Icons.restaurant,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'bedroom_baby': Icons.bedroom_baby,
    'hiking': Icons.hiking,
    'local_bar': Icons.local_bar,
    'camera_alt': Icons.camera_alt,
    'travel_explore': Icons.travel_explore,
    'wine_bar': Icons.wine_bar,
    'liquor': Icons.liquor,
    'nightlife': Icons.nightlife,
    'sports_bar': Icons.sports_bar,
    'festival': Icons.festival,
    'soup_kitchen': Icons.soup_kitchen,
    'door_sliding': Icons.door_sliding,
    'deck': Icons.deck,
    'house_siding': Icons.house_siding,
    'beach_access': Icons.beach_access,
    'kayaking': Icons.kayaking,
    'directions_bike': Icons.directions_bike,
    'terrain': Icons.terrain,
    'paragliding': Icons.paragliding,
    'settings_accessibility': Icons.settings_accessibility,
    'sports_handball_sharp': Icons.sports_handball_sharp,
    'sports_tennis': Icons.sports_tennis,
    'circle_rounded': Icons.circle_rounded,
    'self_improvement': Icons.self_improvement,
    'pool': Icons.pool,
    'directions_run': Icons.directions_run,
    'museum': Icons.museum,
    'account_balance': Icons.account_balance,
    'theater_comedy': Icons.theater_comedy,
    'mic': Icons.mic,
    'photo_camera': Icons.photo_camera,
    'construction': Icons.construction,
    'table_bar': Icons.table_bar,
    'casino': Icons.casino,
    'mic_external_on': Icons.mic_external_on,
    'quiz': Icons.quiz,
    'attractions': Icons.attractions,
    'gamepad': Icons.gamepad,
    'extension': Icons.extension,
    'sports_hockey': Icons.sports_hockey,
    'gps_fixed': Icons.gps_fixed,
    'yard': Icons.yard,
    'visibility': Icons.visibility,
    'park': Icons.park,
    'star_rounded': Icons.star_rounded,
    'spa': Icons.spa,
    'hot_tub': Icons.hot_tub,
    'directions_car': Icons.directions_car,
    'menu_book': Icons.menu_book,
    'translate': Icons.translate,
    'smart_toy': Icons.smart_toy,
    'grid_on': Icons.grid_on,
    'edit_note': Icons.edit_note,
    'science': Icons.science,
    'record_voice_over': Icons.record_voice_over,
    'directions_car_outlined': Icons.directions_car_outlined,
    'holiday_village': Icons.holiday_village,
    'location_city': Icons.location_city,
    'backpack': Icons.backpack,
    'landscape': Icons.landscape,
    'tour': Icons.tour,
    'temple_hindu': Icons.temple_hindu,
    'palette': Icons.palette,
    'diamond': Icons.diamond,
    'tag_rounded': Icons.tag_rounded,
    'photo_album': Icons.photo_album,
    'vignette_sharp': Icons.vignette_sharp,
    'auto_awesome': Icons.auto_awesome,
    'code': Icons.code,
    'view_in_ar': Icons.view_in_ar,
    'currency_bitcoin': Icons.currency_bitcoin,
    'draw': Icons.draw,
    'connecting_airports': Icons.connecting_airports,
    'build': Icons.build,
    'video_camera_front': Icons.video_camera_front,
    'local_movies': Icons.local_movies,
    'pedal_bike': Icons.pedal_bike,
    'sports_cricket': Icons.sports_cricket,
    'sports_football': Icons.sports_football,
    'sports_martial_arts': Icons.sports_martial_arts,
    'track_changes_outlined': Icons.track_changes_outlined,
    'sports_volleyball': Icons.sports_volleyball,
    'track_changes': Icons.track_changes,
    'skateboarding': Icons.skateboarding,
    'videocam_sharp': Icons.videocam_sharp,
    'ondemand_video': Icons.ondemand_video,
    'design_services': Icons.design_services,
    'piano': Icons.piano,
    'spoke': Icons.spoke,
    'crisis_alert': Icons.crisis_alert,
    'menu_book_rounded': Icons.menu_book_rounded,
    'volunteer_activism': Icons.volunteer_activism,
    // Add more mappings as needed
  };

  @override
  void initState() {
    super.initState();
    _fetchInterests();
  }

  Future<void> _fetchInterests() async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getInterests();

      if (response['status'] == 'success') {
        final List<dynamic> interestsList = response['data'];
        final formattedInterests = interestsList.map((interest) {
          final iconName = interest['icon_name'].toString();
          return {
            'name': interest['name'],
            'id': interest['id'],
            'category': interest['category'],
            'icon': iconMapping[iconName] ??
                Icons.star, // Use mapping with fallback
          };
        }).toList();

        if (mounted) {
          setState(() {
            _defaultInterests = formattedInterests;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch interests');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading interests: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredInterests {
    List<Map<String, dynamic>> allInterests = List.from(_defaultInterests);

    // Add custom interests to the list with a star icon
    for (String custom in _customInterests) {
      allInterests.add({
        'name': custom,
        'icon': Icons.star,
        'isCustom': true,
      });
    }

    if (_searchQuery.isEmpty) return allInterests;
    return allInterests
        .where((interest) =>
            interest['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleInterest(String interest, bool isCustom) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
        if (!isCustom) {
          _selectedDefaultInterests.remove(interest);
        }
      } else {
        _selectedInterests.add(interest);
        if (!isCustom) {
          _selectedDefaultInterests.add(interest);
        }
      }
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _addCustomInterest() async {
    final interest = _customInterestController.text.trim();
    if (interest.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final uuid = prefs.getString('user_uuid') ?? '';

        // Submit custom interest to backend
        final thinkProvider = ThinkProvider();
        final response = await thinkProvider.addCustomInterest(
          uuid: uuid,
          interestName: interest,
        );

        if (response['status'] != 'success') {
          throw Exception(
              response['message'] ?? 'Failed to add custom interest');
        }

        if (!mounted) return;

        // Update local state after successful submission
        setState(() {
          _selectedInterests.add(interest);
          _customInterests.add(interest);
          _customInterestController.clear();
          _isAddingCustom = false;
        });

        HapticFeedback.mediumImpact();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding custom interest: $e')),
        );
      }
    }
  }

  Future<void> _submitInterests() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uuid = authProvider.uuid ?? '';

      // Convert selected interests to required format
      final selectedInterests = _selectedInterests.map((interest) {
        if (_customInterests.contains(interest)) {
          return {'name': interest, 'is_custom': true, 'added_by': uuid};
        } else {
          final defaultInterest = _defaultInterests.firstWhere(
            (i) => i['name'] == interest,
            orElse: () => {'id': '', 'name': interest},
          );
          return {
            'id': defaultInterest['id'],
            'name': interest,
            'is_custom': false
          };
        }
      }).toList();

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.pC3Submit(
        uuid: uuid,
        selectedInterests: selectedInterests,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to submit interests');
      }

      // Update registration status using AuthProvider
      await authProvider.updateRegProcess('waitlisted');

      if (!mounted) return;

      // Navigate to waitlist screen with replacement
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WaitlistScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
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
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving interests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_isAddingCustom) {
            setState(() {
              _isAddingCustom = false;
              _customInterestController.clear();
            });
          }
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 20,
                      top: 10,
                      bottom: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    // Header Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Choose what you are\ninterested in...',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.02), // Reduced spacing

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value),
                                decoration: InputDecoration(
                                  hintText: 'Search interests...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                                child:
                                    Icon(Icons.close, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Custom Interest Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isAddingCustom)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _isAddingCustom = true);
                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  _customInterestFocus.requestFocus();
                                });
                              },
                              icon: Icon(Icons.add,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  size: 20),
                              label: Text(
                                'Add custom interest',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          if (_isAddingCustom)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(30),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextField(
                                      controller: _customInterestController,
                                      focusNode: _customInterestFocus,
                                      decoration: const InputDecoration(
                                        hintText: 'Type your interest...',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => _addCustomInterest(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addCustomInterest,
                                  icon: const Icon(Icons.check),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _isAddingCustom = false),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Interests Grid
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _filteredInterests.map((interest) {
                                  final isSelected = _selectedInterests
                                      .contains(interest['name']);
                                  final isCustom =
                                      interest['isCustom'] ?? false;
                                  return GestureDetector(
                                    onTap: () => _toggleInterest(
                                        interest['name'], isCustom),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withAlpha(26),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            interest['icon'],
                                            size: 18,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            interest['name'],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),

                    // Bottom Section - Updated red message visibility
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        24,
                        20,
                        MediaQuery.of(context).padding.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_customInterests.isNotEmpty &&
                              _selectedInterests.any((interest) =>
                                  _customInterests.contains(interest)))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Custom interests will be added to profile after review',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_selectedDefaultInterests.length}/5 selected',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_selectedDefaultInterests.length >= 5)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          SizedBox(
                            width: size.width * 0.6,
                            child: ElevatedButton(
                              onPressed: _selectedDefaultInterests.length >= 5
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      _submitInterests();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customInterestController.dispose();
    _customInterestFocus.dispose();
    super.dispose();
  }
}
