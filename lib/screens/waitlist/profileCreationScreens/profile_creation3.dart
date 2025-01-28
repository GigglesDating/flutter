import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/network/think.dart';

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

  // Map backend icon names to Flutter Icons
  static final Map<String, IconData> _iconMapping = {
    'coffee': Icons.coffee,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'directions_bike': Icons.directions_bike,
    'hiking': Icons.hiking,
    'pool': Icons.pool,
    'gesture': Icons.gesture,
    'restaurant': Icons.restaurant,
    'self_improvement': Icons.self_improvement,
    'book': Icons.book,
    'nightlife': Icons.nightlife,
    'directions_car': Icons.directions_car,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'mic': Icons.mic,
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
        final interestsList = (response['data'] as List).map((interest) {
          return {
            'name': interest['name'],
            'id': interest['id'],
            'category': interest['category'],
            'icon': _iconMapping[interest['icon_name']] ?? Icons.star,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _defaultInterests = interestsList;
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
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid') ?? '';

      // Convert selected interests to required format
      final selectedInterests = _selectedDefaultInterests.map((interest) {
        final interestData = _defaultInterests.firstWhere(
          (i) => i['name'] == interest,
          orElse: () => {'name': interest, 'icon': 'custom'},
        );

        return {
          'name': interest,
          'icon': interestData['icon'].toString(),
          'is_custom': _customInterests.contains(interest),
        };
      }).toList();

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.pC3Submit(
        uuid: uuid,
        selectedInterests: selectedInterests,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to submit interests');
      }

      if (!mounted) return;

      // Navigate to waitlist screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WaitlistScreen(),
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
        ),
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
                              icon: const Icon(Icons.add,
                                  color: Colors.black, size: 20),
                              label: Text(
                                'Add custom interest',
                                style: TextStyle(
                                  color: Colors.grey[800],
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
