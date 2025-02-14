import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/prompt_screen.dart';
import 'package:flutter_frontend/screens/user/shedule_date_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utilitis/appFonts.dart';

class SwipeUserProfilePage extends StatefulWidget {
  const SwipeUserProfilePage({Key? key}) : super(key: key);

  @override
  State<SwipeUserProfilePage> createState() => _SwipeUserProfilePage();
}

class _SwipeUserProfilePage extends State<SwipeUserProfilePage> {
  late List<Widget> _cards = [];
  bool isSwipeIndicator = true;

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          setState(() {
            isSwipeIndicator = false;
          });
        }
      },
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));

    _cards = List.generate(5, (index) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 102, 179, 230),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Image.asset(
            'assets/images/swipe_image.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    });

    print('Total cards: ${_cards.length}');
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
    return Scaffold(
      body: Stack(
        children: [
          // Background image

          Positioned.fill(
            child: Image.asset(
              'assets/images/user_profile_image.png',
              // Replace with your image URL
              fit: BoxFit.cover, // To make the image cover the full screen
            ),
          ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              // Adjust blur level here
              child: Container(
                color: Colors.black.withOpacity(
                    0), // Transparent container to apply the blur
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: (){
                        showReported(context);
                      }, icon: Icon(Icons.report_outlined,size: 40,color: const Color.fromARGB(255, 82, 113, 255),)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          print('object');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: SvgPicture.asset('assets/icons/close_redbg_icon.svg')),
                        ),
                      ),

                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.width / 1.2,
                    // padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 1, // Border width
                        ),
                        shape: BoxShape.rectangle,
                        // Explicitly set to rectangle
                        borderRadius: BorderRadius.circular(150),
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/user_profile_image.png'),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(
                    height: kToolbarHeight,
                  ),
                  Text(
                    'Anna Joseph',
                    style: AppFonts.titleBold(
                        fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color.fromARGB(255, 188, 188, 188),
                        size: 18,
                      ),
                      Text(
                        'Banglore',
                        style: AppFonts.titleBold(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 188, 188, 188)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '250',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleBold(
                                  color: Colors.white, fontSize: 14),
                            ),
                            Spacer(),
                            Text(
                              'Posts',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleRegular(
                                  color: const Color.fromARGB(255, 188, 188, 188),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        VerticalDivider(
                          color: Colors.white,
                          thickness: 2,
                          // width: 10,
                          // The total width of the divider widget, including spacing
                          // indent: 10,
                          // Optional: adds padding before the divider starts
                          // endIndent:
                          //     10, // Optional: adds padding at the end of the divider
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          children: [
                            Text(
                              '32',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleBold(
                                  color: Colors.white, fontSize: 14),
                            ),
                            Spacer(),
                            Text(
                              'Dates',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleRegular(
                                  color: const Color.fromARGB(255, 188, 188, 188),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        VerticalDivider(
                          color: Colors.white,
                          thickness: 2,
                          // width: 10,
                          // The total width of the divider widget, including spacing
                          // indent: 10,
                          // Optional: adds padding before the divider starts
                          // endIndent:
                          //     10, // Optional: adds padding at the end of the divider
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          children: [
                            Text(
                              '4.5',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleBold(
                                  color: Colors.white, fontSize: 14),
                            ),
                            Spacer(),
                            Text(
                              'Rating',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.titleRegular(
                                  color: const Color.fromARGB(255, 188, 188, 188),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 72, 183, 239),
                            Color.fromARGB(255, 12, 83, 168)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            24), // Border radius to match the button's shape
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 70, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                24), // Match the Container's border radius
                          ),
                          backgroundColor: Colors.transparent,
                          // Make the button background transparent
                          shadowColor: Colors
                              .transparent, // Remove shadow to avoid conflicting with gradient
                        ),
                        onPressed: () {
                          // Handle button press
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PromptScreen(),
                              ));
                        },
                        child: Text(
                          'Befriend',
                          style: AppFonts.titleBold(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 1.7,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SheduleDatePage(),));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 12, right: 20, top: 12, bottom: 12),
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: const Color.fromARGB(255, 194, 39, 75),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: Text(
                              'Date',
                              style: AppFonts.titleBold(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            controller: ScrollController(),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Stack(children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/date_image_profile.png',
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              1.7,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 12,
                                    top: 8,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      // clipBehavior: Clip.none,
                                      children: [
                                        // Positioned.fill(child: SvgPicture.asset('assets/icons/calendar.svg' ,width: 70,
                                        //   height: 70,)),
                                        // SvgPicture.asset(
                                        //   'assets/icons/calendar.svg', // Replace with your image URL
                                        //   width: 44,
                                        //   height: 44, // Adjust height as needed
                                        //   fit: BoxFit.cover, // Ensures the image covers the area
                                        // ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.favorite,
                                            color:
                                                const Color.fromARGB(255, 194, 39, 75),
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text('20',
                                            style: AppFonts.titleBold(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    ))
                              ]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text(
                            'Spotify Playlist',
                            style: AppFonts.titleBold(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/spotify_icon.svg',
                              width: 48,
                              height: 48,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                waveformBar(30, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 1
                                waveformBar(60, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 2
                                waveformBar(20, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 3
                                waveformBar(40, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 4
                                waveformBar(10, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 5
                                waveformBar(50, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 6
                                waveformBar(40, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 7 waveformBar(40, const Color.fromARGB(255, 16, 137, 3)), // Bar 1
                                waveformBar(60, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 2
                                waveformBar(20, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 3
                                waveformBar(40, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 4
                                waveformBar(10, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 5
                                waveformBar(50, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 6
                                waveformBar(40, const Color.fromARGB(255, 16, 137, 3)),
                                // Bar 7
                                waveformBar(
                                    70, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 8
                                waveformBar(
                                    25, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 9
                                waveformBar(
                                    45, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 10
                                waveformBar(
                                    15, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 11
                                waveformBar(
                                    35, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 12
                                waveformBar(
                                    35, const Color.fromARGB(255, 24, 20, 19)),
                                waveformBar(
                                    15, const Color.fromARGB(255, 24, 20, 19)),
                                // Bar 12
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Social Accounts',
                              style: AppFonts.titleBold(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 1.8,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            controller: ScrollController(),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Stack(children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/swipe_profile_social_image.png',
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              1.8,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: 16,
                                    top: 8,
                                    child: SvgPicture.asset(
                                      'assets/icons/instagram_icon.svg',
                                      width: 32,
                                      height: 32,
                                    ))
                              ]);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  void showReported(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: const Text('Unblock User'),
        // titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content:  Text(
          'Are you sure to report this profile',
          style: AppFonts.titleMedium(),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('Cancel',style: AppFonts.titleBold(),),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reported successfully'),
                ),
              );
            },
            child:  Text('Confirm',style: AppFonts.titleBold(color: const Color.fromARGB(255, 82, 113, 255)),),
          ),
        ],
      ),
    );
  }

  Widget waveformBar(double height, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 4, // Bar width, adjust as needed
        height: height,
        color: color,
      ),
    );
  }
}