import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Default interests with their icons
  final List<Map<String, dynamic>> _defaultInterests = [
    {'name': 'Coffee', 'icon': Icons.coffee},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Cinema', 'icon': Icons.movie},
    {'name': 'Cycling', 'icon': Icons.directions_bike},
    {'name': 'Hiking', 'icon': Icons.hiking},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Pottery', 'icon': Icons.gesture},
    {'name': 'Cooking', 'icon': Icons.restaurant},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
    {'name': 'Book Club', 'icon': Icons.book},
    {'name': 'Clubbing', 'icon': Icons.nightlife},
    {'name': 'Long drive', 'icon': Icons.directions_car},
    {'name': 'Gymming', 'icon': Icons.fitness_center},
    {'name': 'Pet Club', 'icon': Icons.pets},
    {'name': 'Karaoke', 'icon': Icons.mic},
  ];

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

  void _addCustomInterest() {
    final interest = _customInterestController.text.trim();
    if (interest.isNotEmpty) {
      setState(() {
        _selectedInterests.add(interest);
        _customInterests.add(interest);
        _customInterestController.clear();
        _isAddingCustom = false;
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
              // Back Button - Adjusted position to match profile_creation2
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 20,
                      top: 10, // Reduced top margin
                      bottom: 20, // Reduced bottom margin
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    // Header Text - Adjusted spacing
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Choose what you are\ninterested in...',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
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
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _filteredInterests.map((interest) {
                            final isSelected =
                                _selectedInterests.contains(interest['name']);
                            final isCustom = interest['isCustom'] ?? false;
                            return GestureDetector(
                              onTap: () =>
                                  _toggleInterest(interest['name'], isCustom),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
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
                                            color: Colors.black.withAlpha(26),
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
                                  ? () => Navigator.pushNamed(
                                      context, '/next-screen')
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
