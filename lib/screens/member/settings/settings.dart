import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/placeholders/shared_preferences_service.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:flutter_frontend/screens/member/settings/account_privacy_screen.dart';
import 'package:flutter_frontend/screens/member/settings/accounts_center_screen.dart';
import 'package:flutter_frontend/screens/member/settings/activity_screen.dart';
import 'package:flutter_frontend/screens/member/settings/blocked_users.dart';
import 'package:flutter_frontend/screens/member/settings/features.dart';
import 'package:flutter_frontend/screens/member/settings/notifications.dart';
import 'package:flutter_frontend/screens/subscription_page.dart';
import 'package:flutter_frontend/screens/waitlist/support.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utilitis/appColors.dart';
import '../../../utilitis/appFonts.dart';
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
          _appBarColor = Colors.white; // Fixed color after scrolling
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
          'Settings',
          // style: AppFonts.titleMedium().copyWith(
          //   color: Theme.of(context).colorScheme.tertiary,
          // ),
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,

        titleTextStyle: AppFonts.appBarTitle(color: Theme.of(context).colorScheme.tertiary,fontSize: 20,fontWeight: FontWeight.w700),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(thickness: 0.5,color:Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 12,),
            buildSectionTitle('Account Settings'),
            SizedBox(height: 12,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountCenterScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.manage_accounts_rounded, size: 30, color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: 8,),
                  Text(
                    'Accounts Center',
                    style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                ],
                            ),
              ),),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountPrivacyScreen(),
                  ),
                );

              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.privacy_tip_rounded, size: 30, color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: 8,),
                  Text(
                    'Account Privacy',
                    style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                ],
                            ),
              ),),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  ActivityScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_filled, size: 30, color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: 8,),
                  Text(
                    'Your Activity',
                    style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                ],
                            ),
              ),),
            Divider(thickness: 0.5,color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 12,),
            buildSectionTitle('DnD and Restrictions'),
            SizedBox(height: 12,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  NotificationsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Notifications',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  BlockedUsersScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.block, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Blocked Users',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),


            Divider(thickness: 0.5,color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 12,),
            buildSectionTitle('Membership'),
            SizedBox(height: 12,),
            InkWell(
              onTap: () {
                showSubscription(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.subscriptions, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Subscription',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),
            InkWell(
              onTap: () {
                Share.share('https://play.google.com/store/apps/details?id=com.platonicdating.giggles');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Share your membership',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),

            Divider(thickness: 0.5,color: Theme.of(context).colorScheme.tertiary,),
            SizedBox(height: 12,),
            buildSectionTitle('Help'),
            SizedBox(height: 12,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  FeaturesScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Features',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  SupportScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.headset_mic, size: 30, color: Theme.of(context).colorScheme.tertiary),
                    SizedBox(width: 8,),
                    Text(
                      'Support',
                      style: AppFonts.titleBold(fontSize: 16,color: Theme.of(context).colorScheme.tertiary)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.tertiary,size: 18),
                  ],
                ),
              ),),
            InkWell(
              onTap: () async {
                await SharedPref().clearUserData();
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 28, color: AppColors.error),
                    SizedBox(width: 8,),
                    Text(
                      'Logout',
                      style: AppFonts.titleBold(fontSize: 16,color: AppColors.error),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: AppColors.error,size: 18),
                  ],
                ),
              ),),
            const SizedBox(height: 24,),
          ],
        ),
      ),
    );
  }

  void showSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cancel/Renew'),
            IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.close))
          ],
        ),
        titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content:  Text(
          ' you are Cancel or Renew this plan',
          style: AppFonts.titleMedium(),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showCancelSubscription(context);
            },
            child:  Text('Cancel',style: AppFonts.titleBold(),),
          ),
          TextButton(
            onPressed: () {
              // Handle unblock action
              Navigator.pop(context);
              showRenewSubscription(context);

            },
            child:  Text('Renew',style: AppFonts.titleBold(color: AppColors.primary),),
          ),
        ],
      ),
    );
  }
  void showCancelSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: const Text('Unblock User'),
        // titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content:  Text(
          'Are you sure you want to cancel your subscription?',
          style: AppFonts.titleMedium(),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('Cancel',style: AppFonts.titleBold(),),
          ),
          TextButton(
            onPressed: () {
              // Handle unblock action
              Navigator.pop(context);
            },
            child:  Text('Confirm',style: AppFonts.titleBold(color: AppColors.primary),),
          ),
        ],
      ),
    );
  }
  void showRenewSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: const Text('Unblock User'),
        // titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content:  Text(
          'You will be redirected to our payment gateway partner',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage(),));
            },
            child:  Text('Confirm',style: AppFonts.titleBold(color: AppColors.primary),),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppFonts.titleBold(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
      ),
    );
  }
}