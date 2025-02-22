import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:giggles/screens/auth/signInPage.dart';
import 'package:giggles/screens/subcription_plan/subscription_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/waiting_event_model.dart';
import '../auth/Video_intro_screen.dart';

class WhileWaitingEventsPage extends StatefulWidget {
  const WhileWaitingEventsPage({super.key});

  @override
  State<WhileWaitingEventsPage> createState() => _WhileWaitingEventsPage();
}

class _WhileWaitingEventsPage extends State<WhileWaitingEventsPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // late Gallery3DController controller;
  double? size = 0.9;
  List itemColor = [Colors.red, Colors.black, Colors.amber, Colors.green];
  String membershipCount = '';
  List<bool> isLiked = [];
  List<WaitingEventData> waitingEventList = [];
  String phoneNumber ='';
  String userNumber ='';
  bool? isRegister = false;

  List<String> imageUrlList = [
    "assets/images/stock_1.jpg",
    "assets/images/stock-03.jpg",
    "assets/images/stock-02.jpg",
    "assets/images/stock_1.jpg",
    "assets/images/stock_1.jpg",
    "assets/images/stock_1.jpg",
  ];

  final _formKey = GlobalKey<FormState>();

  void fetchData() async {
    // Fetch membership count
    Provider.of<AuthProvider>(context, listen: false).membershipCount().then(
      (value) {
        if (value?.status == true) {
          setState(() {
            membershipCount = value!.data!.totalUsers.toString();
          });
        }
      },
    );

    // Fetch waiting events
    Provider.of<AuthProvider>(context, listen: false).waitingEvents().then(
      (value) {
        if (value?.status == true) {
          setState(() {
            waitingEventList = value!.data!;
          });
        }
      },
    );
  }

  Future<void> saveLastScreen() async {
    await SharedPref.eventScreenSave();
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('lastScreen', 'eventPage');
  }

  @override
  void initState() {
    super.initState();
    saveLastScreen();
    Future.microtask(() async {
      // Fetch data when the screen appears
      Provider.of<AuthProvider>(context, listen: false).membershipCount().then(
        (value) {
          if (value?.status == true) {
            setState(() {
              membershipCount = value!.data!.totalUsers.toString();
            });
          }
        },
      );
      Provider.of<AuthProvider>(context, listen: false).waitingEvents().then(
        (value) {
          if (value?.status == true) {
            setState(() {
              waitingEventList = value!.data!;
            });
          }
        },
      );
      Provider.of<AuthProvider>(context, listen: false).getCustomerSupportNumber().then(
        (value) {
          if (value?.status == true) {
            setState(() {
              phoneNumber = value!.data!.supportNumber!.phoneNumber.toString();
              userNumber = value.data!.userPhone.toString();
            });
          }
        },
      );
    });
  }

  Future<void> openWhatsApp() async {
    if(Platform.isIOS){
      final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $whatsappUrl';
      }
    }else{
      final Uri whatsappUrl = Uri.parse("https://wa.me/+91 $phoneNumber");
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $whatsappUrl';
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    final registerProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xffF2F3F7),
      // extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/stock_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
             Platform.isIOS?SizedBox(height: kToolbarHeight * 1):
            SizedBox(height: kToolbarHeight * 0.6),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  color: Colors.white,
                  iconSize: 24,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {

                    ShowDialog().showInfoDialogPopUp(context,
                        'Be patient leaving now may mean a longer wait later. The best is worth the wait.',
                        () async {
                      Navigator.of(context).pop();
                      final success =
                          await registerProvider.deleteUserProfileProvider();
                      if (success?.status == true) {
                        await SharedPref().clearUserData();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SigninPage(),
                            ));
                        ShowDialog().showSuccessDialog(
                            context, registerProvider.successMessage);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => SigninPage(),));
                      } else {
                        ShowDialog().showErrorDialog(
                            context, registerProvider.errorMessage);
                      }
                    });
                  },
                  icon: const Icon(Icons.delete_rounded),
                ),
              ),
            ),
            Text(
              membershipCount.length == 2
                  ? '00$membershipCount'
                  : membershipCount,
              style: AppFonts.titleBold(
                fontSize: MediaQuery.of(context).size.width * 0.14,
                // fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              'waiting list',
              style: AppFonts.titleRegular(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: AppColors.sosbuttonBgColor,
              ),
            ),
            // const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                color: AppColors.white,
                iconSize: 72,
                onPressed: () async {
                  try {
                    final success =
                        await registerProvider.fetchEventVideoData();
                    if (success?.status == true) {
                      final introVideo = success?.data
                          ?.waitingListVideo; // Safely access introVideo
                      if (introVideo != null && introVideo.isNotEmpty) {
                        print("Video URL: $introVideo");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoIntroPage(
                              value: true,
                              videoUrl: introVideo,
                            ),
                          ),
                        );
                      } else {
                        print("Intro video not available");
                        ShowDialog().showErrorDialog(
                          context,
                          registerProvider.errorMessage.isNotEmpty
                              ? registerProvider.errorMessage
                              : 'Intro video not available',
                        );
                      }
                    } else {
                      print("Failed to fetch intro video");
                      ShowDialog().showErrorDialog(
                        context,
                        registerProvider.errorMessage.isNotEmpty
                            ? registerProvider.errorMessage
                            : 'Failed to fetch intro video',
                      );
                    }
                  } catch (e) {
                    print("Error occurred: $e");
                    ShowDialog().showErrorDialog(
                      context,
                      'An unexpected error occurred. Please try again.',
                    );
                  }
                },
                icon: const Icon(Icons.play_circle_outline_rounded),
              ),
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: IconButton(
            //     color: AppColors.white,
            //     iconSize: 72,
            //     onPressed: () async {
            //       final success =
            //           await registerProvider.fetchIntroVideoData(false);
            //       if (success?.status == true) {
            //         if (success!.data!.introVideo!.isNotEmpty) {
            //           print("yesss");
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => VideoIntroPage(
            //                   value: true,
            //                   videoUrl: success.data!.introVideo,
            //                 ),
            //               ));
            //         } else {
            //           print("chuuu");
            //           ShowDialog().showErrorDialog(
            //               context, registerProvider.errorMessage);
            //         }
            //       } else {
            //         ShowDialog().showErrorDialog(
            //             context, registerProvider.errorMessage);
            //       }
            //     },
            //     icon: const Icon(Icons.play_circle_outline_rounded),
            //   ),
            // ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'While awaiting approval',
                        style: AppFonts.titleBold(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Finding the one, but also the fun!',
                        style: AppFonts.titleBold(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'join our fun outdoor and indoor games -a great way to enjoy and compete to navigate through the waiting list faster.',
                        textAlign: TextAlign.start,
                        style: AppFonts.titleRegular(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        flex: 20,
                        child: CarouselSlider.builder(
                          itemCount: waitingEventList.length,
                          // itemCount: imageUrlList.length,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.width,
                            aspectRatio: 1.0,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                            enlargeFactor: 0.3,
                            enableInfiniteScroll: false,
                          ),
                          itemBuilder: (ctx, index, realIdx) {
                            // print("asdasdad ${waitingEventList[index].isRegistered}");
                            for (int i = 0;
                                i < waitingEventList.length;
                                i++) {
                              isLiked.add(
                                  waitingEventList[index].isLike ?? false);
                              return Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  // color: Theme.of(context).brightness==Brightness.light?AppColors.black:AppColors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        waitingEventList[index]
                                            .eventImage
                                            .toString()),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image(
                                                height: 24,
                                                width: 24,
                                                image: AssetImage(
                                                  'assets/images/logodarktheme.png',
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    'iggles',
                                                    textAlign:
                                                        TextAlign.start,
                                                    style:
                                                        AppFonts.titleMedium(
                                                            color: AppColors
                                                                .white,
                                                            fontSize: 16),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2, left: 10),
                                                    child: Text(
                                                      'platonic dating',
                                                      textAlign:
                                                          TextAlign.end,
                                                      style: AppFonts
                                                          .titleMedium(
                                                              fontSize: 4,
                                                              color: AppColors
                                                                  .white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Entries Left',
                                                  style: AppFonts.titleMedium(
                                                      fontSize: 12,
                                                      // fontStyle: FontStyle.italic,
                                                      color: AppColors.white),
                                                ),
                                                SizedBox(
                                                  height: 1,
                                                ),
                                                Text(
                                                  '${waitingEventList[index].currentSeat}/${waitingEventList[index].totalSeat}',
                                                  style: AppFonts.titleBold(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              ])
                                        ]),
                                    Expanded(child: Container()),
                                    Text(
                                      waitingEventList[index]
                                          .eventType
                                          .toString(),
                                      style: AppFonts.titleBold(
                                          fontSize: 15,
                                          color: AppColors
                                              .subscriptionplanGiveToFrienButtonBgColor),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            waitingEventList[index]
                                                .eventName
                                                .toString(),
                                            style: AppFonts.titleBold(
                                                fontSize: 22,
                                                color: Colors.white),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                isLiked[index] =
                                                    !isLiked[index];
                                              });
                                              var likeMap = {
                                                'event_id':
                                                    waitingEventList[index]
                                                        .id,
                                                'action':
                                                    isLiked[index] == true
                                                        ? 'like'
                                                        : 'dislike',
                                              };
                                              final success =
                                                  await registerProvider
                                                      .likeWaitingEventsProvider(
                                                          likeMap);
                                              if (success?.status == true) {
                                                // ShowDialog().showSuccessDialog(context, registerProvider.successMessage);
                                              } else {
                                                // ShowDialog().showErrorDialog(
                                                //     context,
                                                //     registerProvider
                                                //         .errorMessage);
                                              }
                                            },
                                            icon: isLiked[index]
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: AppColors
                                                        .DateBackgroundColor,
                                                  )
                                                : Icon(
                                                    Icons.favorite_outline,
                                                    color: AppColors.white,
                                                  ),
                                            visualDensity:
                                                const VisualDensity(
                                                    vertical: -4),
                                          )
                                        ]),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '₹ ${waitingEventList[index].price}',
                                            style: AppFonts.titleBoldOverline(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors
                                                  .subscriptionplanGiveToFrienButtonBgColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '•₹${waitingEventList[index].discountPrice}',
                                            style: AppFonts.titleBold(
                                                fontSize: 14,
                                                color: AppColors
                                                    .subscriptionplanGiveToFrienButtonBgColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.white),
                                        child: Text(
                                          DateFormat('MMM dd').format(
                                              DateTime.parse(
                                                  waitingEventList[index]
                                                      .eventDateAndTime
                                                      .toString())),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.white),
                                        child: Text(
                                          DateFormat('hh:mm a').format(
                                              DateTime.parse(
                                                  waitingEventList[index]
                                                      .eventDateAndTime
                                                      .toString())),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        onTap: () {
                                          openVenue(waitingEventList[index]
                                              .eventLocation
                                              .toString());
                                          print('objectobjectobject');
                                          print(waitingEventList[index]
                                              .eventLocation
                                              .toString());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.white),
                                            child: Row(children: [
                                              Icon(Icons.location_on,
                                                  size: 16),
                                              Text(
                                                'Venue',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontStyle:
                                                        FontStyle.italic,
                                                    color: Colors.black),
                                              ),
                                            ])),
                                      )
                                    ]),
                                    const SizedBox(height: 20),
                                    waitingEventList[index].isRegistered ==
                                            true
                                        ? InkWell(
                                            onTap: () async {
                                              print("ontapppppppppp");

                                              var eventMap = {
                                                'event_id':
                                                    waitingEventList[index]
                                                        .id
                                                        .toString()
                                              };

                                              try {
                                                // Call the register method
                                                final success =
                                                    await registerProvider
                                                        .waitingEventRegisterUser2(
                                                            eventMap);

                                                // Log the success response
                                                print(
                                                    "Response status: ${success?.status}");
                                                print(
                                                    "Response message: ${success?.message}");

                                                if (success?.status == true) {
                                                  print(
                                                      "Registration successful!");
                                                  fetchData();
                                                  setState(() {});
                                                  ShowDialog()
                                                      .showSuccessDialog(
                                                    context,
                                                    registerProvider
                                                        .successMessage,
                                                  );
                                                } else {
                                                  fetchData();
                                                  ShowDialog()
                                                      .showSuccessDialog(
                                                    context,
                                                    "Event unregistered successfully",
                                                  );
                                                }
                                              } catch (error) {
                                                fetchData();
                                                print("Error: $error");
                                                ShowDialog().showErrorDialog(
                                                  context,
                                                  "Something went wrong. Please try again.",
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(36),
                                                color: Colors.grey
                                                    .withOpacity(0.6),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Unregister",
                                                  style: AppFonts.titleBold(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () async {
                                              var eventMap = {
                                                'event_id':
                                                    waitingEventList[index]
                                                        .id
                                                        .toString()
                                              };

                                              try {
                                                final success =
                                                    await registerProvider
                                                        .waitingEventRegisterUser(
                                                            eventMap);

                                                if (success?.status == true) {
                                                  print("success");
                                                  fetchData(); // Ensure this updates the `waitingEventList`
                                                  setState(() {});
                                                  ShowDialog()
                                                      .showSuccessDialog(
                                                    context,
                                                    registerProvider
                                                        .successMessage,
                                                  );
                                                } else {
                                                  print("nottttt");
                                                  ShowDialog()
                                                      .showErrorDialog(
                                                    context,
                                                    registerProvider
                                                        .errorMessage,
                                                  );
                                                }
                                              } catch (error) {
                                                print("error: $error");
                                                ShowDialog().showErrorDialog(
                                                  context,
                                                  "Something went wrong. Please try again.",
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(36),
                                                color: Colors.grey
                                                    .withOpacity(0.6),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Register",
                                                  style: AppFonts.titleBold(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                      userNumber=='9030373653'? SizedBox(height: 12,):SizedBox(),
                      userNumber=='9030373653'? InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage(),));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding:
                          const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(36),
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: Text(
                              "View Demo for Review",
                              style: AppFonts.titleBold(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ):SizedBox(),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          onPressed: () async{
                            openWhatsApp();
                          },
                          child: Text('Customer support',
                              textAlign: TextAlign.center,
                              style: AppFonts.titleMediumUnderLine(
                                color: AppColors.grey,
                                fontSize: 14,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openVenue(String locationUrl) async {
    if (!await launchUrl(Uri.parse(locationUrl),
        mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $locationUrl');
    }
  }
}
