import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeFilterPage extends StatefulWidget {
  const SwipeFilterPage({Key? key}) : super(key: key);

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

  List<String> _selectedOptions = [];

  String selectedLoveLanguage = '';
  String selectedCommunicationStyle = '';
  String selectedpets = '';
  String selectedexercise = '';
  String selectedsmoke = '';
  String selecteddrinker = '';
  String selectedsocialenergy = '';
  String selectedsocialinterest = '';

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
      if (states.contains(MaterialState.selected)) {
        return Colors.amber.withOpacity(0.54);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Narrow your search'),
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
                labelColor:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: [
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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                        color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
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
                            min: 0,
                            max: 60,
                            divisions: 100,
                            activeColor: isDarkMode
                                ? Colors.grey[100]
                                : Colors.grey[900],
                            inactiveColor:
                                const Color.fromARGB(255, 90, 89, 89),
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
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Interests',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
                    ),
                    SizedBox(
                      height: 10,
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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                value: selectedsocialinterest == 'Just a Homie',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                value: selectedsocialinterest == 'Surprise Me',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                value:
                                    selectedsocialinterest == 'Short Term Fun',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    selecteddrinker = value! ? 'Weekends' : '';
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    selecteddrinker = value! ? 'Drunkard' : '';
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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                value: selectedsmoke == 'Smoking when drinking',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                value: selectedexercise == 'Don\u0027t want to',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                value:
                                    selectedCommunicationStyle == 'Bad Texter',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                          color:
                              isDarkMode ? Colors.grey[100] : Colors.grey[900]),
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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                value: selectedLoveLanguage == 'physical_touch',
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
                                side: BorderSide(color: Colors.grey, width: 2),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

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
    );
  }
}
