import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/appFonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent; // Start with transparent AppBar color
  bool _hasScrolledUp = false; // Track if the user has scrolled up
  // Future<void> logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('isLoggedIn');
  //   await prefs.remove('userId');
  //
  //   await FirebaseAuth.instance.signOut();
  //
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => signInPage(),
  //     ), // Replace with your actual login page
  //     (route) => false,
  //   );
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_hasScrolledUp) {
        // Once scrolled past 100 pixels, set the AppBar color to fixed value
        setState(() {
          _appBarColor = Colors.blue; // Fixed color after scrolling
          _hasScrolledUp = true; // Mark that scrolling has happened
        });
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          // Light icons for dark theme
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light, // For iOS devices
        ),
        title: Text(
          'Settings and Subscription',
          // style: AppFonts.titleMedium().copyWith(
          //   color: Theme.of(context).colorScheme.tertiary,
          // ),
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,

        titleTextStyle: AppFonts.appBarTitle(color: Theme.of(context).colorScheme.tertiary,fontSize: 18),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(thickness: 0.5,color:Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Your Account',
                style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: SvgPicture.asset('assets/icons/user_profile_circle_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Accounts Center',
                ),
                subtitle: Text('Biometric Login,Perdsonal detail,Security'),
                subtitleTextStyle: AppFonts.titleRegular(fontSize: 12,color: Theme.of(context).colorScheme.tertiary),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Theme.of(context).colorScheme.tertiary,),
              ),
            ),
            // InkWell(
            //   onTap: () async {
            //     // await logout(context);
            //   },
            //   child: ListTile(
            //     leading: Icon(Icons.person),
            //     title: Text(
            //       'Log Out',
            //     ),
            //     trailing: Icon(Icons.arrow_forward),
            //   ),
            // ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: SvgPicture.asset('assets/icons/block_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Blocked Accounts',
                ),
                subtitle: Text('Temporary restrictions,Hidden profile'),
                subtitleTextStyle: AppFonts.titleRegular(fontSize: 12,color: Theme.of(context).colorScheme.tertiary),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Theme.of(context).colorScheme.tertiary,),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading:SvgPicture.asset('assets/icons/notification_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Notifications',
                ),
                subtitle: Text('Sleep setting,DND,Away mode'),
                subtitleTextStyle: AppFonts.titleRegular(fontSize: 12,color: Theme.of(context).colorScheme.tertiary),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Theme.of(context).colorScheme.tertiary,),
              ),
            ),
            Divider(thickness: 0.5,color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'How to Use HD ?',
                style:  AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading:SvgPicture.asset('assets/icons/watch_intro_icon.svg',height: 30,color: Theme.of(context).colorScheme.tertiary,),
        
                title: Text(
                  'Watch Intro',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                // trailing: Icon(Icons.arrow_forward_ios,size: 16,),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: SvgPicture.asset('assets/icons/faq_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'FAQS',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                // trailing: Icon(Icons.arrow_forward_ios,size: 16,),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading:  SvgPicture.asset('assets/icons/contactsupport_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Contact Support',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                // trailing: Icon(Icons.arrow_forward_ios,size: 16,),
              ),
            ),
            Divider(thickness: 0.5,color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Wallet & Payments',
                style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary)
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: SvgPicture.asset('assets/icons/payout_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Request Payout',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: SvgPicture.asset('assets/icons/date_history_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Date History',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: 10,),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading:  SvgPicture.asset('assets/icons/set_prices_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: const Text(
                  'Set Prices',
                ),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            SizedBox(height: 16,),
            InkWell(
              onTap: () {},
              child: ListTile(
                tileColor: AppColors.primaryDark,
                leading: SvgPicture.asset('assets/icons/logout_icon.svg',width: 40,height: 40,color: Theme.of(context).colorScheme.tertiary,),
                title: Text(
                  'Logout',
                ),
                // subtitle: Text('Temporary restrictions,Hidden profile'),
                // subtitleTextStyle: AppFonts.titleRegular(fontSize: 12,color: Theme.of(context).colorScheme.tertiary),
                titleTextStyle:  AppFonts.titleBold(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Theme.of(context).colorScheme.tertiary,),
              ),
            ),
            const SizedBox(height: 24,),
          ],
        ),
      ),
    );
  }
}
