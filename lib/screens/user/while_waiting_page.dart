import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:video_player/video_player.dart';

import '../auth/Video_intro_screen.dart';
import '../dashboard/explore_tab/swipe_filter_page.dart';
import '../subcription_plan/subscription_page.dart';

class WhileWaitingPage extends StatefulWidget {
  const WhileWaitingPage({Key? key}) : super(key: key);

  @override
  State<WhileWaitingPage> createState() => _WhileWaitingPage();
}

class _WhileWaitingPage extends State<WhileWaitingPage> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  String? sortByDropDown;

  // late MatchEngine _matchEngine;

  // List<SwipeItem> _swipeItem = <SwipeItem>[];

  RangeValues _currentRangeValues = const RangeValues(500, 5000);
  final GlobalKey _buttonKey = GlobalKey();

  // bool _isSwiped = false;
  final List<String> items = [
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
    'assets/images/reel_profile_image.png',
  ];
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  List<bool> _isSwiped = [];
  List<bool> isChecked =
      List.generate(8, (index) => false); // Initial unchecked state
  List<String> sortByDropDownList = [
    'Recently Active',
    'Recent Join',
    'Most Populart',
  ];
  void _initializeSwipeItems() {
    _swipeItems = items.asMap().entries.map((entry) {
      int index = entry.key;
      String item = entry.value;

      return SwipeItem(
        content: item,
        likeAction: () {
          _removeItem(index);
        },
        nopeAction: () {
          _removeItem(index);
        },
      );
    }).toList();
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      _initializeSwipeItems();
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    //   statusBarColor: Colors.transparent,
    //   // Make it transparent or choose any color
    //   statusBarIconBrightness: Brightness.light,
    //   // Set icons to white
    //   statusBarBrightness: Brightness.light, // For iOS
    // ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeSwipeItems();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    // _matchEngine = MatchEngine(swipeItems: _swipeItem);
  }

  Future<void> showPriceRange() async {
    return showDialog<void>(
      context: context, barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          // Removes padding around dialog
          title: const Text('Price Range'),
          titleTextStyle: AppFonts.titleBold(
              color: Theme.of(context).colorScheme.tertiary, fontSize: 24),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
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
                            min: 500,
                            max: 10000,
                            // divisions: 50,
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
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Submit',
                style: AppFonts.titleBold(
                    color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              SizedBox(width: 8),
              Text('Warning'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    //   statusBarColor: Colors.transparent,
    //   // Make it transparent or choose any color
    //   statusBarIconBrightness: Brightness.light,
    //   // Set icons to white
    //   statusBarBrightness: Brightness.light, // For iOS
    // ));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('While you are waiting'),
        titleSpacing: 0,
        titleTextStyle: AppFonts.titleBold(
            fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        // height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Text(
                              '2154',
                              style: AppFonts.titleBold(fontSize: 14),
                            ),
                            Text(
                              'Waiting List',
                              style: AppFonts.titleMedium(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: -8,
                          left: -4,
                          child: SvgPicture.asset(
                            'assets/icons/announcement_icon.svg',
                            height: 20,
                            width: 16,
                          ))
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoIntroPage(
                              value: true,
                            ),
                          ));
                    },
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 36,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      showWarningDialog(
                          context, 'Are you sure want to delete this Profile?');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: AppColors.error,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Delete My Profile',
                            style: AppFonts.titleBold(
                                color: AppColors.error, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Divider(
                thickness: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                child: SizedBox(
                  height: 48, // width: MediaQuery.of(context).size.width/1.4,
                  child: TextFormField(
                    // controller: commentController,
                    // focusNode: commentFocusNode,

                    style: AppFonts.titleMedium(
                        color: Theme.of(context).colorScheme.tertiary),

                    cursorHeight: 18,
                    cursorColor: Theme.of(context).colorScheme.tertiary,
                    // maxLength: 10,
                    maxLines: 1,
                    minLines: 1,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {});
                      }
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'Search for an influencer',
                      hintStyle: AppFonts.hintTitle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 14),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sort By',
                          style: AppFonts.titleMedium(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 16),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          height: 24,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 1)),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: DropdownButton<String>(
                            underline: Text(''),
                            // dropdownColor: AppColors.black,
                            style: AppFonts.hintTitle(
                                color: AppColors.sosbuttonBgColor),
                            value: sortByDropDown,
                            hint: Text('Please Select',
                                style: AppFonts.hintTitle(
                                    color: AppColors.sosbuttonBgColor,
                                    fontSize: 14)),
                            iconDisabledColor:
                                AppColors.profileCreateOutlineBorder,
                            iconEnabledColor:
                                AppColors.profileCreateOutlineBorder,
                            isExpanded: true,
                            items: sortByDropDownList.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.hintTitle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                sortByDropDown = newValue;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          // key: _buttonKey,
                          onTap: () {
                            showPriceRange();

                            print('object');
                          },
                          child: SvgPicture.asset(
                            'assets/icons/dimension_icon.svg',
                            width: 20,
                            height: 16,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ), // Spacer(),
                        IconButton(
                          icon: Icon(Icons.filter_alt_outlined),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SwipeFilterPage(),
                                ));
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              // GridView.builder(
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2, // 3 items per row
              //     childAspectRatio: 1, // Adjust height-to-width ratio
              //     crossAxisSpacing: 8,
              //     mainAxisSpacing: 8,
              //   ),
              //   physics: ScrollPhysics(),
              //   itemCount: items.length,
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
              //               // border: Border.all(color: AppColors.userProfileBorderColor),
              //               borderRadius: BorderRadius.circular(16),
              //               ),
              //         alignment: Alignment.centerLeft,
              //         padding: EdgeInsets.only(left: 20),
              //         ),
              //       // secondaryBackground: Container(
              //       //   color: Colors.red,
              //       //   alignment: Alignment.centerRight,
              //       //   padding: EdgeInsets.only(right: 20),
              //       //   child: Icon(Icons.delete, color: Colors.white),
              //       // ),
              //       child: InkWell(
              //         onTap: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => SubscriptionPage(),
              //               ));
              //         },
              //         child: ProfileCard(
              //           imageUrl: 'assets/images/reel_profile_image.png',
              //           socialIcons: [
              //             'assets/icons/instagram_icon.svg',
              //             'assets/icons/instagram_icon.svg',
              //             'assets/icons/instagram_icon.svg'
              //           ],
              //           label: 'Tech Doc',
              //         ),
              //       ),
              //     );
              //   },
              // ),

              GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: items.length,
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubscriptionPage(),
                            ));
                      },
                      child: SwipeCards(
                        likeTag: const Icon(Icons.check_box_rounded,
                            size: 60, color: Colors.green),
                        nopeTag: const Icon(Icons.close,
                            size: 48, color: Colors.red),
                        matchEngine: MatchEngine(
                            swipeItems: items.asMap().entries.map((entry) {
                          int index = entry.key;
                          String item = entry.value;
                          return SwipeItem(
                            content: item,
                            likeAction: () {
                              _removeItem(index);
                            },
                            nopeAction: () {
                              _removeItem(index);
                            },
                          );
                        }).toList()),
                        fillSpace: true,
                        upSwipeAllowed: true,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ProfileCard(
                              imageUrl: items[index],
                              socialIcons: const [
                                'assets/icons/instagram_icon.svg',
                                'assets/icons/instagram_icon.svg',
                                'assets/icons/instagram_icon.svg'
                              ],
                              label: 'Tech Doc',
                            ),
                          );
                        },
                        onStackFinished: () {
                          // setState(() {
                          //   items.removeAt(index);
                          // });
                        },
                      )

                      // SwipeableCard(
                      //   key: ValueKey(items[index]),
                      //   // Ensures unique widget for each image
                      //   imageUrl: items[index],
                      //   onLiked: (){
                      //     setState(() {
                      //       items.removeAt(index);
                      //     });
                      //
                      //   },
                      //   onDisliked: () {
                      //     setState(() {
                      //       items.removeAt(index);
                      //     });
                      //   }), // Remove by URL

                      );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      items.removeAt(index);
    });
  }
}

class ProfileCard extends StatelessWidget {
  final String imageUrl;
  final List<String> socialIcons;
  final String label;

  const ProfileCard({
    required this.imageUrl,
    required this.socialIcons,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Octagon Shape with Profile Image
        Container(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.userProfileBorderColor),
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              )),
          // color: AppColors.userProfileBorderColor, // Border color
        ),
        // Social Media Icons
        Positioned(
          left: 8,
          top: kToolbarHeight - 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: socialIcons
                .map((icon) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: SvgPicture.asset(
                        icon,
                        width: 18,
                        height: 18,
                      ),
                    ))
                .toList(),
          ),
        ),
        Positioned(
          right: 8,
          top: 36,
          child: Icon(
            Icons.info_outline,
            color: AppColors.primaryLight,
            size: 18,
          ),
        ),
        // Optional Label
        if (label.isNotEmpty)
          Positioned(
            bottom: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                label,
                style:
                    AppFonts.titleMedium(fontSize: 14, color: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// Custom ClipPath for Octagon
// class OctagonClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     final w = size.width;
//     final h = size.height;
//     final factor = 0.2; // Adjust for desired octagon proportions
//
//     path.moveTo(w * factor, 0);
//     path.lineTo(w * (1 - factor), 0);
//     path.lineTo(w, h * factor);
//     path.lineTo(w, h * (1 - factor));
//     path.lineTo(w * (1 - factor), h);
//     path.lineTo(w * factor, h);
//     path.lineTo(0, h * (1 - factor));
//     path.lineTo(0, h * factor);
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
