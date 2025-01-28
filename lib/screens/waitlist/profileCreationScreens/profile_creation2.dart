import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_creation3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/network/think.dart';

class ProfileCreation2 extends StatefulWidget {
  const ProfileCreation2({super.key});

  @override
  State<ProfileCreation2> createState() => _ProfileCreation2State();
}

class _ProfileCreation2State extends State<ProfileCreation2> {
  String _selectedPreference = '';
  RangeValues _ageRange = const RangeValues(18, 35);
  final List<String> _preferences = ['Men', 'Women', 'Everyone', 'Nonbinary'];
  bool _isSubmitting = false;

  Future<void> _submitPreferences() async {
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid') ?? '';

      // Convert preference to list format as required by API
      List<String> genderPreference;
      switch (_selectedPreference.toLowerCase()) {
        case 'everyone':
          genderPreference = ['men', 'women', 'non-binary'];
          break;
        case 'nonbinary':
          genderPreference = ['non-binary'];
          break;
        default:
          genderPreference = [_selectedPreference.toLowerCase()];
      }

      // Format age preference
      final agePreference = {
        'min': _ageRange.start.round(),
        'max': _ageRange.end.round(),
      };

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.pC2Submit(
        uuid: uuid,
        genderPreference: genderPreference,
        agePreference: agePreference,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to submit preferences');
      }

      if (!mounted) return;

      // Navigate to next screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfileCreation3(),
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
          settings: RouteSettings(
            arguments: {
              'preference': _selectedPreference,
              'ageRange': {
                'start': _ageRange.start.round(),
                'end': _ageRange.end.round(),
              },
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving preferences: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    isIOS ? padding.top : 20,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode
                                ? Colors.grey[900]
                                : Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Title and Subtitle
                      Text(
                        'Tell us about Your\ndating preference...',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "By selecting 'Share Only with Friends',\nyour content will be visible exclusively to\nyour approved connections.",
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Preference Selection with Animation
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _preferences.map((preference) {
                          final isSelected = _selectedPreference == preference;
                          return AnimatedScale(
                            scale: isSelected ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                    () => _selectedPreference = preference);
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDarkMode
                                          ? Colors.white
                                          : Colors.black)
                                      : (isDarkMode
                                          ? Colors.grey[900]
                                          : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: isDarkMode
                                                ? Colors.white.withAlpha(20)
                                                : Colors.black.withAlpha(26),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  preference,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                        : (isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Age Preference with Custom Slider
                      Text(
                        'Age Preference',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Column(
                        children: [
                          RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            divisions: 42,
                            activeColor:
                                isDarkMode ? Colors.white : Colors.black,
                            inactiveColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            labels: RangeLabels(
                              _ageRange.start.round().toString(),
                              _ageRange.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _ageRange = values;
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_ageRange.start.round()} - ${_ageRange.end.round()} years',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.08),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom section with fixed position
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                keyboardPadding > 0
                    ? keyboardPadding + 16
                    : padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
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
                width: size.width * 0.5,
                child: ElevatedButton(
                  onPressed: _selectedPreference.isNotEmpty && !_isSubmitting
                      ? () {
                          HapticFeedback.mediumImpact();
                          _submitPreferences();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                    disabledBackgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? Colors.black : Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
      resizeToAvoidBottomInset: false,
    );
  }
}
