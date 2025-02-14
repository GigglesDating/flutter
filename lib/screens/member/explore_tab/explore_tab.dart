import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_frontend/screens/member/explore_tab/swipe_filter_page.dart';
import 'package:flutter_frontend/screens/prompt_screen.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../user/swipe_user_profile_page.dart';


class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with WidgetsBindingObserver {
  late List<Widget> _cards = [];
  bool isSwipeIndicator = true;
  bool showImageTiles = false;
  String mainImage = 'assets/images/image1.jpg';
  int currentIndex = 0;
  List<String> profiles = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mainImage = profiles[currentIndex];
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

  // Future<void> handleSwipeRight(
  //     String currentUserId, String swipedUserId) async {}

  List<String> userPRofile = [
    'assets/images/user2.png'
        'assets/images/user3.png'
        'assets/images/user4.png'
        'assets/images/user5.png'
  ];

  // List of small images with initial random positions
  List<Map<String, dynamic>> smallImages = [
    {'path': 'assets/images/image2.png', 'position': Offset(0, 0)},
    {'path': 'assets/images/image3.png', 'position': Offset(0, 0)},
    {'path': 'assets/images/image4.jpg', 'position': Offset(0, 0)},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    randomizeTilePositions(); // Set initial random positions within the mid 55% of the screen
  }

  void randomizeTilePositions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final minX = screenWidth * 0.225;
    final maxX = screenWidth * 0.775;
    final minY = screenHeight * 0.225;
    final maxY = screenHeight * 0.775;

    setState(() {
      for (var image in smallImages) {
        image['position'] = Offset(
          minX + Random().nextDouble() * (maxX - minX),
          minY + Random().nextDouble() * (maxY - minY),
        );
      }
    });
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: CardSwiper(
              padding: EdgeInsets.zero,
              cardsCount: _cards.length,
              onSwipe: (previousIndex, currentIndex, direction) {
                if (direction == CardSwiperDirection.top) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SwipeUserProfilePage(),
                      ));
                }
                if (direction == CardSwiperDirection.left ) {
                  // if (showImageTiles) {
                  //   randomizeTilePositions(); // Reset positions on every show after swap
                  // }
                  setState(() {
                    showImageTiles =false;
                  });
                }
                if(direction == CardSwiperDirection.right){
                  setState(() {
                    showImageTiles =false;
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptScreen(),
                      ));
                }
                return true;
              },
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) {
                return GestureDetector(
                  onTap: () {
                    if (showImageTiles) {
                      randomizeTilePositions(); // Reset positions on every show after swap
                    }
                    setState(() {
                      showImageTiles = !showImageTiles;
                    });
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        child: Image.asset(
                          mainImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  'Dhawani Tripati,26',
                                  style: AppFonts.titleBold(
                                      fontSize: 24, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/swipe_location_icon.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Banglore',
                                    style: AppFonts.titleBold(
                                        fontSize: 16,
                                        color: const Color.fromARGB(255, 200, 208, 216)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: kToolbarHeight,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/swipe_bio_icon.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry..',
                                      style: AppFonts.titleBold(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: kToolbarHeight - 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                //   Container(
                //   decoration: const BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage('assets/images/swipe_image.png'),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // );
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        'assets/icons/swipe_back_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                    )),
                InkWell(
                    onTap: () {
                      // Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SwipeFilterPage(),
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        'assets/icons/swipe_filter_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSwipeIndicator
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/left_swipe_image.png',
                              width: 100,
                              height: 48,
                            ),
                            Image.asset(
                              'assets/images/right_swipe_image.png',
                              width: 100,
                              height: 48,
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: kToolbarHeight,
                  ),
                  isSwipeIndicator
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/swipe_hand_image.png',
                                width: 100,
                                height: 48,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Next Image',
                                style: AppFonts.titleBold(
                                    fontSize: 10, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height:
                        isSwipeIndicator ? 0 : kToolbarHeight + kToolbarHeight,
                  ),
                ],
              ),
            ),
          ),


          // Image Tiles (if tapped to show)
          if (showImageTiles) buildDraggableImageTiles(),
        ],
      ),
    );
  }

  // Function to display draggable image tiles
  Widget buildDraggableImageTiles() {
    return Stack(
      children: smallImages.asMap().entries.map((entry) {
        int index = entry.key;
        String imagePath = entry.value['path'];
        Offset initialPosition = entry.value['position'];

        return Positioned(
          left: initialPosition.dx,
          top: initialPosition.dy,
          child: Draggable<Map<String, dynamic>>(
            data: {'index': index, 'position': initialPosition},
            feedback: buildImageTile(imagePath),
            // What shows while dragging
            childWhenDragging: Container(),
            // What stays in original position while dragging
            onDragEnd: (details) {
              // Update position on drag end
              setState(() {
                smallImages[index]['position'] = details.offset;
              });
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // Swap main image with tapped small image
                  String temp = mainImage;
                  mainImage = imagePath;
                  smallImages[index]['path'] = temp;
                  showImageTiles = false; // Hide tiles after swap
                });
              },
              child: Transform.rotate(
                angle: (Random().nextDouble() * 20 - 10) * pi / 180,
                // Add slight tilt
                child: buildImageTile(imagePath),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper function to create individual image tiles
  Widget buildImageTile(String imagePath) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}