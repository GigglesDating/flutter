import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/screens/dashboard/snip_tab/snip_tab.dart';

import '../maps/sos_map_page.dart';
import '../user/user_profile_page.dart';
import 'explore_tab/explore_tab.dart';
import 'home_tab/home_tab.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      Page1(),
     Page2(),
      Page3(),
      const Page4(),
      const Page5(),
      Page6(),
    ];
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent the user from navigating back
        return false;
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
              bottomBarPages.length, (index) => bottomBarPages[index]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              backgroundColor: AppColors.sosbuttonBgColor,
              shape: const CircleBorder(),
              onPressed: () {
                // _pageController.jumpToPage(2);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SosMapPage()));

                // );

              },
              child: SvgPicture.asset(
                'assets/icons/sos_icon.svg',
                width: 46,
                height: 46,
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
            child: BottomAppBar(
              height: 60,
              color: AppColors.bottomAppBarBg,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape:const AutomaticNotchedShape(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                // If you need a notch for a FAB:
                // CircularNotchedRectangle(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: () {
                        _pageController.jumpToPage(0);
                      },
                      hoverColor: AppColors.transparent,
                      splashColor: AppColors.transparent,
                      child: SvgPicture.asset(
                        'assets/icons/home_icon.svg',
                        width: 40,
                        height: 40,
                      )),
                  InkWell(
                    onTap: () {
                      // if (user!.role == 'user') {
                      // _pageController.jumpToPage(1);
                      // } else if (user!.role == 'user_2') {
                      //   _pageController.jumpToPage(5);
                      // }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreTab(),));

                    },
                    child: SvgPicture.asset(
                      'assets/icons/explore_icon.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  InkWell(
                      onTap: () {
                        _pageController.jumpToPage(3);

                      },
                      child: SvgPicture.asset(
                        'assets/icons/snip_icon.svg',
                        width: 40,
                        height: 40,
                      )),
                  InkWell(
                      onTap: () {
                        _pageController.jumpToPage(4);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.userProfileBorderColor,
                              width: 1,
                            )),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/user1.png'),
                          radius: 16),
                      ),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: HomeTab(),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: ExploreTab(),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  Page3({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,

      child: SizedBox(),
      // Center(
      //   child: user!.gender == 'Female'
      //       ? BookingPage(userId: user!.uid)
      //       : AddDatePage(user: user!),
      // ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SnipTab();
  }
}

class Page5 extends StatelessWidget {
  const Page5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserProfilePage();
  }
}

class Page6 extends StatelessWidget {
  Page6({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: SizedBox(),
        // FemaleSurfComponent(),
      ),
    );
  }
}
