import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/components/userLikeYouSwipeableComponent.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../utilitis/appColors.dart';


class UserLikesPage extends StatefulWidget {
  const UserLikesPage({Key? key}) : super(key: key);

  @override
  State<UserLikesPage> createState() => _SwipeFilterPage();
}

class _SwipeFilterPage extends State<UserLikesPage> {
  bool isDatingEveryOne = false;
  bool isMen = false;
  bool isWomen = false;
  bool isNonBinary = false;
  late MatchEngine _matchEngine;
  late SwipeItem _swipeItem;
  bool _isSwiped = false;
  RangeValues _currentRangeValues = const RangeValues(18, 60);
  List<int> items = List<int>.generate(12, (i) => i); // Sample data

  final List<String> images = [
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
    'assets/images/liked_you image.png',
  ];
  bool isSwipeIndicator = true;

  List<String> _selectedOptions = [];

  final List<Map<String, dynamic>> _activities = [
    {"name": "Coffee", "icon": Icons.local_cafe},
    {"name": "Shopping", "icon": Icons.shopping_bag},
    {"name": "Clubbing", "icon": Icons.local_bar},
    {"name": "Cinema", "icon": Icons.movie},
    {"name": "Cycling", "icon": Icons.directions_bike},
    {"name": "Gymming", "icon": Icons.fitness_center},
    {"name": "Hiking", "icon": Icons.hiking},
    {"name": "Swimming", "icon": Icons.pool},
    {"name": "Pet Club", "icon": Icons.pets},
    {"name": "Pottery", "icon": Icons.brush},
    {"name": "Cooking", "icon": Icons.kitchen},
    {"name": "Karaoke", "icon": Icons.mic},
    {"name": "Yoga", "icon": Icons.self_improvement},
    {"name": "Book Club", "icon": Icons.menu_book},
    {"name": "Long Drive", "icon": Icons.directions_car},
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

  void _removeImage(String imageUrl) {
    setState(() {
      images.remove(imageUrl);
    });
  }
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
          title: const Text('Likes'),
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
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.tabBarBackround
                    : AppColors.SwipeUserProfileTextColor,
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
                labelStyle: AppFonts.titleBold(
                  fontSize: 18,
                ),
                unselectedLabelStyle: AppFonts.titleBold(
                  fontSize: 18,
                ),
                labelColor:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                        ? AppColors.white
                        : AppColors.black,
                unselectedLabelColor: AppColors.black,
                tabs: [
                  Tab(text: "Liked you"),
                  Tab(text: "Liked by you"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Few people would like to hangout with you,find out who.',
                      style: AppFonts.titleBold(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // GridView.builder(
                    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2, // Two images per row
                    //     childAspectRatio: .8, // Aspect ratio for images
                    //     mainAxisSpacing: 10,
                    //     crossAxisSpacing: 10,
                    //   ),
                    //   itemCount: items.length,
                    //   physics: NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   itemBuilder: (context, index) {
                    //     return Dismissible(
                    //       key: Key(items[index].toString()),
                    //       onDismissed: (direction) {
                    //         setState(() {
                    //           items.removeAt(index);
                    //         });
                    //         // ScaffoldMessenger.of(context).showSnackBar(
                    //         //   SnackBar(
                    //         //     content: Text("Item ${items[index]} dismissed"),
                    //         //   ),
                    //         // );
                    //       },
                    //       direction: DismissDirection.horizontal,
                    //
                    //       background: Container(
                    //
                    //           width: MediaQuery.of(context).size.width / 2,
                    //           height: MediaQuery.of(context).size.width / 2,
                    //           decoration: BoxDecoration(
                    //             // border: Border.all(color: AppColors.userProfileBorderColor),
                    //             borderRadius: BorderRadius.circular(16),
                    //           ),
                    //           alignment: Alignment.centerLeft,
                    //           padding: EdgeInsets.only(left: 20),
                    //           ),
                    //       child: GestureDetector(
                    //         onTap: () {},
                    //         // Open image picker on tap
                    //         child: Stack(
                    //           children: [
                    //             // Display selected image
                    //             ClipRRect(
                    //               borderRadius: BorderRadius.circular(15),
                    //               child: Image.asset(
                    //                 'assets/images/liked_you image.png',
                    //                 width: double.infinity,
                    //                 height: double.infinity,
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             ),
                    //             // Checkmark overlay when an image is selected
                    //
                    //             Positioned(
                    //               bottom: 16,
                    //               left: 0,
                    //               right: 0,
                    //               child: Center(
                    //                   child: Text(
                    //                 'Aditi Rao',
                    //                 style: AppFonts.titleBold(
                    //                     color: AppColors.white, fontSize: 18),
                    //               )),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two images per row
                            childAspectRatio: .8, // Aspect ratio for images
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                      ),
                      shrinkWrap: true,
                      // physics: ScrollPhysics(),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return UserlikeSwipeableCard(
                          key:
                          ValueKey(images[index]), // Ensures unique widget for each image
                          imageUrl: images[index],
                          onLiked: () => _removeImage(images[index]), // Remove by URL
                          onDisliked: () => _removeImage(images[index]), // Remove by URL
                        );
                      },
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
                    Text(
                      'People you have shown interest to hang out with',
                      style: AppFonts.titleBold(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 12,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          color: AppColors.tabBarBackround,  // Background color
                          borderRadius: BorderRadius.circular(15),  // Circular radius
                        ),
                        child: ListTile(
                          leading: ClipOval(
                            child: Image.asset('assets/images/user2.png'),
                          ),
                          titleTextStyle: AppFonts.titleBold(
                              fontSize: 16,
                              color:AppColors.black),
                          title: Text(
                            'Nithiya Ka',
                          ),
                          subtitle: Text(
                            '23/09/2024',
                          ),
                          subtitleTextStyle: AppFonts.titleBold(
                              fontSize: 12,
                              color: AppColors.black),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/close_redbg_icon.svg',width: 28,height: 28,),
                              SizedBox(height: 4,),
                              Text(
                                'Withdraw',
                                style: AppFonts.titleBold(fontSize: 12,color: AppColors.black),
                              ),
                            ],),
                        ),
                      );
                    },),

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