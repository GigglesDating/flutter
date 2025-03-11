import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeFilterPage extends StatefulWidget {
  const SwipeFilterPage({super.key});

  @override
  State<SwipeFilterPage> createState() => _SwipeFilterPage();
}

class _SwipeFilterPage extends State<SwipeFilterPage> {
  bool isDatingEveryOne = false;
  bool isMen = false;
  bool isWomen = false;
  bool isNonBinary = false;

  bool interestgroups = false;

  RangeValues _currentRangeValues = const RangeValues(18, 60);

  bool isSwipeIndicator = true;

  String selectedLoveLanguage = '';
  String selectedCommunicationStyle = '';
  String selectedpets = '';
  String selectedexercise = '';
  String selectedsmoke = '';
  String selecteddrinker = '';
  String selectedsocialenergy = '';
  String selectedsocialinterest = '';

  final WidgetStateProperty<Color?> trackColor =
      WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) {
      // Track color when the switch is selected.
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(255, 76, 175, 80);
      }
      // Otherwise return null to set default track color
      // for remaining states such as when the switch is
      // hovered, focused, or disabled.
      return null;
    },
  );
  final WidgetStateProperty<Color?> overlayColor =
      WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) {
      // Material color when switch is selected.
      if (states.contains(WidgetState.selected)) {
        return Colors.amber.withValues(alpha: 50);
      }
      // Material color when switch is disabled.
      if (states.contains(WidgetState.disabled)) {
        return Colors.black;
      }
      // Otherwise return null to set default material color
      // for remaining states such as when the switch is
      // hovered, or focused.
      return null;
    },
  );
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
  }

  int counter = 0;

  Future<void> handleSwipeRight(
      String currentUserId, String swipedUserId) async {}

  // final _list = ['Coffee', ' Hiking'];
  List<String> userPRofile = [
    'assets/images/user2.png'
        'assets/images/user3.png'
        'assets/images/user4.png'
        'assets/images/user5.png'
  ];

  // New additions for interests
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedInterests = [];
  String _searchQuery = '';

  // Sample interests list (you can modify this)
  final List<String> _allInterests = [
    'movie',
    'coffee',
    'shopping_bag',
    'sports_basketball',
    'music_note',
    'restaurant',
    'sports_esports',
    'fitness_center',
    'book',
    'bedroom_baby',
    'hiking',
    'local_bar',
    'camera_alt',
    'travel_explore',
    'wine_bar',
    'liquor',
    'nightlife',
    'sports_bar',
    'festival',
    'soup_kitchen',
    'door_sliding',
    'deck',
    'house_siding',
    'beach_access',
    'kayaking',
    'directions_bike',
    'terrain',
    'paragliding',
    'settings_accessibility',
    'sports_handball_sharp',
    'sports_tennis',
    'circle_rounded',
    'self_improvement',
    'pool',
    'directions_run',
    'museum',
    'account_balance',
    'theater_comedy',
    'mic',
    'photo_camera',
    'construction',
    'table_bar',
    'casino',
    'mic_external_on',
    'quiz',
    'attractions',
    'gamepad',
    'extension',
    'sports_hockey',
    'gps_fixed',
    'yard',
    'visibility',
    'park',
    'star_rounded',
    'spa',
    'hot_tub',
    'directions_car',
    'menu_book',
    'translate',
    'smart_toy',
    'grid_on',
    'edit_note',
    'science',
    'record_voice_over',
    'directions_car_outlined',
    'holiday_village',
    'location_city',
    'backpack',
    'landscape',
    'tour',
    'temple_hindu',
    'palette',
    'diamond',
    'tag_rounded',
    'photo_album',
    'vignette_sharp',
    'auto_awesome',
    'code',
    'view_in_ar',
    'currency_bitcoin',
    'draw',
    'connecting_airports',
    'build',
    'video_camera_front',
    'local_movies',
    'pedal_bike',
    'sports_cricket',
    'sports_football',
    'sports_martial_arts',
    'track_changes_outlined',
    'sports_volleyball',
    'track_changes',
    'skateboarding',
    'videocam_sharp',
    'ondemand_video',
    'design_services',
    'piano',
    'spoke',
    'crisis_alert',
    'menu_book_rounded',
    'volunteer_activism',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withAlpha(15)
            : Colors.white.withAlpha(15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withAlpha(25)
              : Colors.black.withAlpha(15),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ),
            title: Text(
              'Narrow your search',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            titleSpacing: 15,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
            bottom: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 48),
              child: Container(
                // padding: EdgeInsets.zero,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 241, 242, 242)
                      : const Color.fromARGB(255, 188, 188, 188),
                  // Background color for entire tab section
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: TabBar(
                  dividerHeight: 0,
                  physics: const NeverScrollableScrollPhysics(),
                  // labelPadding: EdgeInsets.all(0),
                  isScrollable: false,
                  // textScaler: TextScaler.noScaling,
                  indicator: BoxDecoration(
                      color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                  labelStyle: TextStyle(
                    fontSize: 18,
                  ),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                  labelColor: Theme.of(context).colorScheme.brightness ==
                          Brightness.light
                      ? Colors.white
                      : Colors.black,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: "Basic Filters"),
                    Tab(text: "Advance Filters"),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        ' Who are you open to date ?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'I\u0027m open to dating everyone',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontSize: 15),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      // This bool value toggles the switch.
                                      value: isDatingEveryOne,
                                      onChanged: (value) {
                                        setState(() {
                                          isDatingEveryOne = value;
                                          if (isDatingEveryOne == true) {
                                            isNonBinary = true;
                                            isWomen = true;
                                            isMen = true;
                                          } else {
                                            isNonBinary = false;
                                            isWomen = false;
                                            isMen = false;
                                          }
                                        });
                                      },
                                      overlayColor: overlayColor,
                                      trackColor: trackColor,
                                      // thumbColor:  WidgetStatePropertyAll(Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Men',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: isMen,
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      isMen = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Women',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: isWomen,
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      isWomen = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Non-Binary',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: isNonBinary,
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      isNonBinary = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        ' Age Preference',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
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
                              divisions: 42,
                              activeColor: isDarkMode
                                  ? Colors.grey[100]
                                  : Colors.grey[900],
                              inactiveColor:
                                  const Color.fromARGB(255, 90, 89, 89),
                              overlayColor: WidgetStatePropertyAll(isDarkMode
                                  ? Colors.grey[900]?.withValues(alpha: 128)
                                  : Colors.grey[100]?.withValues(alpha: 128)),
                              labels: RangeLabels(
                                _currentRangeValues.start.round().toString(),
                                _currentRangeValues.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                if (values.start >= 18) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                } else {
                                  setState(() {
                                    _currentRangeValues =
                                        RangeValues(18, values.end);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      _buildInterestsSection(isDarkMode),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'What are you interested in?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Just a Homie',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedsocialinterest == 'Just a Homie',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialinterest =
                                          value! ? 'Just a Homie' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Serious Connections',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialinterest ==
                                      'Serious Connections',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialinterest =
                                          value! ? 'Serious Connections' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Casual Connections',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialinterest ==
                                      'Casual Connections',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialinterest =
                                          value! ? 'Casual Connections' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Surprise Me',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedsocialinterest == 'Surprise Me',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialinterest =
                                          value! ? 'Surprise Me' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Short Term Fun',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialinterest ==
                                      'Short Term Fun',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialinterest =
                                          value! ? 'Short Term Fun' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'What\u0027s your social energy level?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Introvert',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialenergy == 'Introvert',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialenergy =
                                          value! ? 'Introvert' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Extrovert',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialenergy == 'Extrovert',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialenergy =
                                          value! ? 'Extrovert' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ambivert',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsocialenergy == 'Ambivert',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsocialenergy =
                                          value! ? 'Ambivert' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'How often do you drink?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Teetotaler',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selecteddrinker == 'Teetotaler',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selecteddrinker =
                                          value! ? 'Teetotaler' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Social drinking',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selecteddrinker == 'Social drinking',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selecteddrinker =
                                          value! ? 'Social drinking' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Weekends',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selecteddrinker == 'Weekends',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selecteddrinker =
                                          value! ? 'Weekends' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Drunkard',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selecteddrinker == 'Drunkard',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selecteddrinker =
                                          value! ? 'Drunkard' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'How often do you smoke?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Social smoking',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsmoke == 'Social smoking',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsmoke =
                                          value! ? 'Social smoking' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trying to quit',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsmoke == 'Trying to quit',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsmoke =
                                          value! ? 'Trying to quit' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Smoking when drinking',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedsmoke == 'Smoking when drinking',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsmoke =
                                          value! ? 'Smoking when drinking' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Chain smoker',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedsmoke == 'Chain smoker',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedsmoke =
                                          value! ? 'Chain smoker' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Do you exercise?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Don\u0027t want to',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedexercise == 'Don\u0027t want to',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedexercise =
                                          value! ? 'Don\u0027t want to' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Every Day',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedexercise == 'Every Day',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedexercise =
                                          value! ? 'Every Day' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sometimes',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedexercise == 'Sometimes',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedexercise =
                                          value! ? 'Sometimes' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Do you like pets?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Furry Pets',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedpets == 'Furry Pets',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedpets = value! ? 'Furry Pets' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amphibian',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedpets == 'Amphibian',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedpets = value! ? 'Amphibian' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Allergic to pets',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedpets == 'Allergic to pets',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedpets =
                                          value! ? 'Allergic to pets' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Don\u0027t like pets',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedpets == 'Don\u0027t like pets',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedpets =
                                          value! ? 'Don\u0027t like pets' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'What\u0027s your communication style?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bad Texter',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedCommunicationStyle ==
                                      'Bad Texter',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedCommunicationStyle =
                                          value! ? 'Bad Texter' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Big Time Texter',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedCommunicationStyle ==
                                      'Big Time Texter',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedCommunicationStyle =
                                          value! ? 'Big Time Texter' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'In Person',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedCommunicationStyle == 'In Person',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedCommunicationStyle =
                                          value! ? 'In Person' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Phone caller',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedCommunicationStyle ==
                                      'Phone caller',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedCommunicationStyle =
                                          value! ? 'Phone caller' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'what\u0027s your Love language?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Compliments',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedLoveLanguage == 'compliments',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedLoveLanguage =
                                          value! ? 'compliments' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Physical touch',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedLoveLanguage == 'physical_touch',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedLoveLanguage =
                                          value! ? 'physical_touch' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Gifting/Receiving gifts',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedLoveLanguage == 'gifting',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedLoveLanguage =
                                          value! ? 'gifting' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quality Time',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value: selectedLoveLanguage == 'quality_time',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedLoveLanguage =
                                          value! ? 'quality_time' : '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Acts of service',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900]),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  // isError: true,
                                  value:
                                      selectedLoveLanguage == 'acts_of_service',
                                  side:
                                      BorderSide(color: Colors.grey, width: 2),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedLoveLanguage =
                                          value! ? 'acts_of_service' : '';
                                    });
                                  },
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildInterestsSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
          child: Text(
            'Interests',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
          ),
        ),
        // SizedBox(height: 10),
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
                    onChanged: (value) => setState(() => _searchQuery = value),
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
                    child: Icon(Icons.close, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        // Interests Chips
        Container(
          height: 200, // Adjust height as needed
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[900]!.withValues(alpha: 128)
                : Colors.grey[100]!.withValues(alpha: 128),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allInterests
                  .where((interest) => interest
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .map((interest) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedInterests.contains(interest)) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedInterests.contains(interest)
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : Colors.transparent,
                            border: Border.all(
                              color: isDarkMode ? Colors.white : Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: _selectedInterests.contains(interest)
                                  ? (isDarkMode ? Colors.black : Colors.white)
                                  : (isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
