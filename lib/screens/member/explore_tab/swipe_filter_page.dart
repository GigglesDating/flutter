import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';

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
  RangeValues _currentRangeValues = const RangeValues(18, 60);

  bool isSwipeIndicator = true;

  List<String> _selectedOptions = [];

  final List<Map<String, dynamic>> _activities = [
    {"name": "movie", "icon": Icons.movie},
    {"name": "coffee", "icon": Icons.coffee},
    {"name": "shopping_bag", "icon": Icons.shopping_bag},
    {"name": "sports_basketball", "icon": Icons.sports_basketball},
    {"name": "music_note", "icon": Icons.music_note},
    {"name": "restaurant", "icon": Icons.restaurant},
    {"name": "sports_esports", "icon": Icons.sports_esports},
    {"name": "fitness_center", "icon": Icons.fitness_center},
    {"name": "brush", "icon": Icons.brush},
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
    {"name": "phishing", "icon": Icons.phishing},
    {"name": "directions_bike", "icon": Icons.directions_bike},
    {"name": "terrain", "icon": Icons.terrain},
    {"name": "paragliding", "icon": Icons.paragliding},
    {"name": "settings_accessibility", "icon": Icons.settings_accessibility},
    {"name": "sports_handball_sharp", "icon": Icons.sports_handball_sharp},
    {"name": "sports_tennis", "icon": Icons.sports_tennis},
    {"name": "golf_course", "icon": Icons.golf_course},
    {"name": "circle_rounded", "icon": Icons.circle_rounded},
    {"name": "self_improvement", "icon": Icons.self_improvement},
    {"name": "pool", "icon": Icons.pool},
    {"name": "directions_run", "icon": Icons.directions_run},
    {"name": "downhill_skiing", "icon": Icons.downhill_skiing},
    {"name": "sailing", "icon": Icons.sailing},
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
    {"name": "sunny_snowing", "icon": Icons.sunny_snowing},
    {"name": "menu_book", "icon": Icons.menu_book},
    {"name": "headphones", "icon": Icons.headphones},
    {"name": "psychology", "icon": Icons.psychology},
    {"name": "translate", "icon": Icons.translate},
    {"name": "psychology_alt", "icon": Icons.psychology_alt},
    {"name": "smart_toy", "icon": Icons.smart_toy},
    {"name": "grid_on", "icon": Icons.grid_on},
    {"name": "outdoor_grill", "icon": Icons.outdoor_grill},
    {"name": "edit_note", "icon": Icons.edit_note},
    {"name": "science", "icon": Icons.science},
    {"name": "record_voice_over", "icon": Icons.record_voice_over},
    {"name": "directions_car_outlined", "icon": Icons.directions_car_outlined},
    {"name": "holiday_village", "icon": Icons.holiday_village},
    {"name": "location_city", "icon": Icons.location_city},
    {"name": "backpack", "icon": Icons.backpack},
    {"name": "directions_boat", "icon": Icons.directions_boat},
    {"name": "diversity_3", "icon": Icons.diversity_3},
    {"name": "cabin", "icon": Icons.cabin},
    {"name": "landscape", "icon": Icons.landscape},
    {"name": "tour", "icon": Icons.tour},
    {"name": "temple_hindu", "icon": Icons.temple_hindu},
    {"name": "palette", "icon": Icons.palette},
    {"name": "diamond", "icon": Icons.diamond},
    {"name": "tag_rounded", "icon": Icons.tag_rounded},
    {"name": "photo_album", "icon": Icons.photo_album},
    {"name": "album", "icon": Icons.album},
    {"name": "monetization_on", "icon": Icons.monetization_on},
    {"name": "precision_manufacturing", "icon": Icons.precision_manufacturing},
    {"name": "vignette_sharp", "icon": Icons.vignette_sharp},
    {"name": "blind_outlined", "icon": Icons.blind_outlined},
    {"name": "auto_awesome", "icon": Icons.auto_awesome},
    {"name": "code", "icon": Icons.code},
    {"name": "view_in_ar", "icon": Icons.view_in_ar},
    {"name": "print", "icon": Icons.print},
    {"name": "currency_bitcoin", "icon": Icons.currency_bitcoin},
    {"name": "draw", "icon": Icons.draw},
    {"name": "connecting_airports", "icon": Icons.connecting_airports},
    {"name": "build", "icon": Icons.build},
    {"name": "subscriptions", "icon": Icons.subscriptions},
    {"name": "video_camera_front", "icon": Icons.video_camera_front},
    
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
        return AppColors.success;
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
        return AppColors.black;
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

  final _list = ['Coffee', ' Hiking'];
  List<String> userPRofile = [
    'assets/images/user2.png'
        'assets/images/user3.png'
        'assets/images/user4.png'
        'assets/images/user5.png'
  ];

  @override
  Widget build(BuildContext context) {
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
          titleSpacing: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          titleTextStyle: AppFonts.titleBold(
              fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 48),
            child: Container(
              // padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness==Brightness.light?AppColors.tabBarBackround:AppColors.SwipeUserProfileTextColor,
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
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                labelStyle:
                    AppFonts.titleBold(fontSize: 18,),
                unselectedLabelStyle:
                    AppFonts.titleBold(fontSize: 18,),
                labelColor: Theme.of(context).colorScheme.brightness==Brightness.light?AppColors.white:AppColors.black,
                unselectedLabelColor: AppColors.black,
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
                    SizedBox(height: 24,),
                    Text(
                      ' Who are you open to date ?',
                      style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'I\u0027m open to dating everyone',
                                style: AppFonts.titleRegular(
                                    color: Theme.of(context).colorScheme.tertiary,fontSize: 15),
                              ),
                              SizedBox(width: 8,),
                              Expanded(
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    // This bool value toggles the switch.
                                    value: isDatingEveryOne,
                                    onChanged: (value){
                                      setState(() {
                                        isDatingEveryOne=value;
                                        if(isDatingEveryOne==true){
                                          isNonBinary=true;
                                          isWomen=true;
                                          isMen=true;
                                        }else{
                                          isNonBinary=false;
                                          isWomen=false;
                                          isMen=false;
                                        }
                                
                                      });
                                    },
                                    overlayColor: overlayColor,
                                    trackColor: trackColor,
                                    // thumbColor:  WidgetStatePropertyAll(Theme.of(context).brightness==Brightness.light?AppColors.black:AppColors.white),
                                
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
                                style: AppFonts.titleRegular(
                                    color: Theme.of(context).colorScheme.tertiary),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness==Brightness.light?AppColors.white:AppColors.black,
                                activeColor: Theme.of(context).colorScheme.tertiary,
                                // isError: true,
                                value: isMen,
                                side: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2),
                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    isMen=value!;
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
                                style: AppFonts.titleRegular(
                                    color: Theme.of(context).colorScheme.tertiary),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness==Brightness.light?AppColors.white:AppColors.black,
                                activeColor: Theme.of(context).colorScheme.tertiary,
                                // isError: true,
                                value: isWomen,
                                side: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2),
                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    isWomen=value!;
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
                                style: AppFonts.titleRegular(
                                    color: Theme.of(context).colorScheme.tertiary),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness==Brightness.light?AppColors.white:AppColors.black,
                                activeColor: Theme.of(context).colorScheme.tertiary,
                                // isError: true,
                                value: isNonBinary,
                                side: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2),
                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    isNonBinary=value!;
                                  });
                                },
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16,),
                    Text(
                      ' Age Preference',
                      style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Between ${_currentRangeValues.start.round().toString()} and ${_currentRangeValues.end.round().toString()}',
                            style: AppFonts.titleRegular(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                          RangeSlider(
                            values: _currentRangeValues,
                            min: 0,
                            max: 60,
                            divisions: 100,
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            inactiveColor: AppColors.profileCreateOutlineBorder,
                            overlayColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.tertiary),
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
                    SizedBox(height: 16,),
                    Text(
                      'Interests',
                      style: AppFonts.titleBold(fontSize: 18,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary),
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

                          bool isSelected = _selectedActivities.contains(activity);

                          return GestureDetector(
                            onTap: () => _toggleSelection(activity),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white : Colors.grey[300],
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
                                      style: AppFonts.titleBold(
                                          color: isSelected
                                              ? Theme.of(context).brightness==Brightness.light?Colors.white:Colors.black
                                              : Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,
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
                                    color: isSelected ? Theme.of(context).brightness==Brightness.light?Colors.white:Colors.black :Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,
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
                    SizedBox(height: 24,),
                    Text(
                      ' Interest Groups',
                      style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'group in my interest',
                                style: AppFonts.titleRegular(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.tertiary),
                              ),
                              SizedBox(width: 8,),
                              Expanded(
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    // This bool value toggles the switch.
                                    value: isDatingEveryOne,
                                
                                    onChanged: (value){
                                      setState(() {
                                        isDatingEveryOne=value;
                                      });
                                    },
                                    overlayColor: overlayColor,
                                    trackColor: trackColor,
                                    // thumbColor:  WidgetStatePropertyAll(Theme.of(context).brightness==Brightness.light?AppColors.black:AppColors.white),
                                
                                  ),
                                ),
                              ),
                              SizedBox(width: 8,),
                              Text(
                                'Show all groups',
                                style: AppFonts.titleRegular(
                                  fontSize: 12,
                                    color: Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 16,),

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