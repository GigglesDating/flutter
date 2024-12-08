import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';

import '../components/buttonComponent.dart';
import '../dashboard/dashboard_page.dart';


class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({
    super.key,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPage();
}

class _SubscriptionPage extends State<SubscriptionPage> {
  CarouselSliderController carouselController = CarouselSliderController();
  int _currentPage = 0;
  int _selectedIndex = 0;
  bool isTrialCard = false;
  bool isSelectCard = true;
  bool isPremiumCard = false;
  List sbscriPtionPlanBanner = [
    'assets/images/subscriptionheader1.png',
    'assets/images/subscriptionheader1.png',
    'assets/images/subscriptionheader1.png',
  ];

  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentIndex = 1;
  PageController _controller = PageController();

  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show multi-select dialog

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: kToolbarHeight + kToolbarHeight,
            ),
            CarouselSlider(
                items: sbscriPtionPlanBanner.map((i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Image.asset(i),
                  );
                }).toList(),
                carouselController: carouselController,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  disableCenter: true,

                  // aspectRatio: 16/9,
                  viewportFraction: 1,
                  initialPage: _currentPage,
                  // enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 2),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  // autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  // enableInfiniteScroll: true,
                  enlargeFactor: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                )),
            SizedBox(
              height: 16,
            ),
            Align(
                alignment: Alignment.center,
                child: Text(
                  'Claim your membership',
                  style: AppFonts.titleBold(
                      color: AppColors.subscriptionplanCardColor, fontSize: 16),
                )),
            SizedBox(
              height: 8,
            ),
            Align(
                alignment: Alignment.center,
                child: Text(
                  'Unlimitd Likes,Date recommendations and more',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 12),
                )),
            SizedBox(
              height: 16,
            ),



            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isTrialCard = true;
                      isSelectCard = false;
                      isPremiumCard = false;
                    });
                  },
                  child: isTrialCard
                      ? DottedBorder(
                          borderType: BorderType.RRect,
                          strokeWidth: 2,
                          radius: Radius.circular(16),
                          color: AppColors.subscriptionplanCardColor,
                          borderPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: Container(
                            child: Column(
                              children: [
                                DottedBorder(
                                    radius: Radius.circular(16),
                                    borderType: BorderType.RRect,
                                    strokeWidth: 2,
                                    color: AppColors.subscriptionplanCardColor,
                                    borderPadding: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Save 40%',
                                        style: AppFonts.titleBold(
                                            color: AppColors
                                                .subscriptionplanCardColor,
                                            fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '1',
                                  style: AppFonts.titleBold(
                                      fontSize: 40,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Month',
                                  style: AppFonts.titleBold(
                                      fontSize: 16,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '\u0027100/day',
                                  style: AppFonts.titleBold(
                                      fontSize: 12,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ))
                      : Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16)),
                              border: Border(
                                left: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                top: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                bottom: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              )),
                          child: Column(
                            children: [
                              // DottedBorder(
                              //     radius: Radius.circular(16),
                              //     borderType: BorderType.RRect,
                              //     strokeWidth: 2,
                              //     color: AppColors.subscriptionplanTextColor,
                              //     borderPadding: EdgeInsets.zero,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text(
                              //         'Save 40%',
                              //         style: AppFonts.titleBold(
                              //             color: AppColors.subscriptionplanTextColor,
                              //             fontSize: 18),
                              //       ),
                              //     )),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Trial',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color:
                                        AppColors.subscriptionplanTrialCardColor),
                              ),
                              Text(
                                '7',
                                style: AppFonts.titleBold(
                                    fontSize: 40,
                                    color:
                                        AppColors.subscriptionplanTrialCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Days',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color:
                                        AppColors.subscriptionplanTrialCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Free',
                                style: AppFonts.titleBold(
                                    fontSize: 12,
                                    color:
                                        AppColors.subscriptionplanTrialCardColor),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isTrialCard = false;
                      isSelectCard = true;
                      isPremiumCard = false;
                    });
                  },
                  child: isSelectCard
                      ? DottedBorder(
                          borderType: BorderType.RRect,
                          strokeWidth: 2,
                          radius: Radius.circular(16),
                          color: AppColors.subscriptionplanCardColor,
                          borderPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: Container(
                            child: Column(
                              children: [
                                DottedBorder(
                                    radius: Radius.circular(16),
                                    borderType: BorderType.RRect,
                                    strokeWidth: 2,
                                    color: AppColors.subscriptionplanCardColor,
                                    borderPadding: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Save 40%',
                                        style: AppFonts.titleBold(
                                            color: AppColors
                                                .subscriptionplanCardColor,
                                            fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '1',
                                  style: AppFonts.titleBold(
                                      fontSize: 40,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Month',
                                  style: AppFonts.titleBold(
                                      fontSize: 16,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '\u0027100/day',
                                  style: AppFonts.titleBold(
                                      fontSize: 12,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ))
                      : Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16)),
                              border: Border(
                                right: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                top: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    style: BorderStyle.solid),
                              )),
                          child: Column(
                            children: [
                              // DottedBorder(
                              //     radius: Radius.circular(16),
                              //     borderType: BorderType.RRect,
                              //     strokeWidth: 2,
                              //     color: AppColors.subscriptionplanTextColor,
                              //     borderPadding: EdgeInsets.zero,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text(
                              //         'Save 40%',
                              //         style: AppFonts.titleBold(
                              //             color: AppColors.subscriptionplanTextColor,
                              //             fontSize: 18),
                              //       ),
                              //     )),
                              Text(
                                'Trial',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '3',
                                style: AppFonts.titleBold(
                                    fontSize: 40,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Month',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '\u002783.3/day',
                                style: AppFonts.titleBold(
                                    fontSize: 12,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isTrialCard = false;
                      isSelectCard = false;
                      isPremiumCard = true;
                    });
                  },
                  child: isPremiumCard
                      ? DottedBorder(
                          borderType: BorderType.RRect,
                          strokeWidth: 2,
                          radius: Radius.circular(16),
                          color: AppColors.subscriptionplanCardColor,
                          borderPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: Container(
                            child: Column(
                              children: [
                                DottedBorder(
                                    radius: Radius.circular(16),
                                    borderType: BorderType.RRect,
                                    strokeWidth: 2,
                                    color: AppColors.subscriptionplanCardColor,
                                    borderPadding: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Save 40%',
                                        style: AppFonts.titleBold(
                                            color: AppColors
                                                .subscriptionplanCardColor,
                                            fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '1',
                                  style: AppFonts.titleBold(
                                      fontSize: 40,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Month',
                                  style: AppFonts.titleBold(
                                      fontSize: 16,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '\u0027100/day',
                                  style: AppFonts.titleBold(
                                      fontSize: 12,
                                      color: AppColors.subscriptionplanCardColor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ))
                      : Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16)),
                              border: Border(
                                right: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                top: BorderSide(
                                    width: 0.5,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    style: BorderStyle.solid),
                              )),
                          child: Column(
                            children: [
                              // DottedBorder(
                              //     radius: Radius.circular(16),
                              //     borderType: BorderType.RRect,
                              //     strokeWidth: 2,
                              //     color: AppColors.subscriptionplanTextColor,
                              //     borderPadding: EdgeInsets.zero,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text(
                              //         'Save 40%',
                              //         style: AppFonts.titleBold(
                              //             color: AppColors.subscriptionplanTextColor,
                              //             fontSize: 18),
                              //       ),
                              //     )),
                              Text(
                                'Premium+',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '3',
                                style: AppFonts.titleBold(
                                    fontSize: 40,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Month',
                                style: AppFonts.titleBold(
                                    fontSize: 16,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '\u002783.3/day',
                                style: AppFonts.titleBold(
                                    fontSize: 12,
                                    color: AppColors
                                        .subscriptionplanPremiumCardColor),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                  child: AppButton.button(AppColors.subscriptionplanCardColor,
                      'Get exclusive membership', 18, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(),
                    ));
              }, AppColors.white, context)),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                  child: AppButton.buttonwithIcon(
                      AppColors.subscriptionplanGiveToFrienButtonBgColor,
                      'Give it to a friend',
                      18, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(),
                    ));
              }, AppColors.white, context)),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    // Data for each subscription plan
    final plans = [
      {
        'title': 'Trial',
        'duration': '7 days',
        'price': 'Free',
        'highlightColor': Colors.grey.shade300,
      },
      {
        'title': 'Save 40%',
        'duration': '1 Month',
        'price': '₹100/day',
        'highlightColor': Colors.orange,
      },
      {
        'title': 'Premium+',
        'duration': '3 Months',
        'price': '₹83.3/day',
        'highlightColor': Colors.grey.shade300,
      },
    ];

    // Check if the current index is selected
    bool isSelected = index == _currentIndex;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin:
          EdgeInsets.symmetric(horizontal: 8, vertical: isSelected ? 0 : 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plans[index]['highlightColor'] as Color,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            plans[index]['title'] as String,
            style: TextStyle(
              fontSize: 20,
              color: isSelected ? Colors.orange : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            plans[index]['duration'] as String,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.orange : Colors.black,
            ),
          ),
          if (index == 0) Text('days', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text(
            plans[index]['price'] as String,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
