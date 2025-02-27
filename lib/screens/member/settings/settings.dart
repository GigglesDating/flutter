import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledUp = false;
  static SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    initPrefs();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_hasScrolledUp) {
        setState(() {
          _hasScrolledUp = true;
        });
      }
    });
  }

  Future<void> initPrefs() async {
    // TODO: Replace with proper API implementation for user preferences
    preferences ??= await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<bool> clearUserData() async {
    try {
      // TODO: Implement API call to clear user data from backend
      preferences ??= await SharedPreferences.getInstance();
      await preferences!.clear();
      return true;
    } catch (e) {
      // Use logger instead of print
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define responsive measurements
    final containerHeight = size.height * 0.07;
    final horizontalPadding = size.width * 0.04;
    final iconSize = size.width * 0.06;
    final arrowIconSize = size.width * 0.04;
    final dividerIndent = size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        title: Text(
          'Settings',
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w700),
        ),
        titleSpacing: horizontalPadding,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(
              indent: dividerIndent,
              endIndent: dividerIndent,
              thickness: 0.5,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 128)
                  : Colors.black.withValues(alpha: 128),
            ),
            SizedBox(
              height: 12,
            ),
            buildSectionTitle('Account Settings'),
            SizedBox(
              height: 12,
            ),
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
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.manage_accounts_rounded,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Accounts Center',
                      style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
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
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.privacy_tip_rounded,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Account Privacy',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_filled,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Your Activity',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            Divider(
              indent: dividerIndent,
              endIndent: dividerIndent,
              thickness: 0.5,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(
              height: 12,
            ),
            buildSectionTitle('DnD and Restrictions'),
            SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Notifications',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedUsersScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.block,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Blocked Users',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            Divider(
              indent: dividerIndent,
              endIndent: dividerIndent,
              thickness: 0.5,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(
              height: 12,
            ),
            buildSectionTitle('Membership'),
            SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () {
                showSubscription(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.subscriptions,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Subscription',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Share.share(
                    'https://play.google.com/store/apps/details?id=com.platonicdating.giggles');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.share,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Share your membership',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            Divider(
              indent: dividerIndent,
              endIndent: dividerIndent,
              thickness: 0.5,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(
              height: 12,
            ),
            buildSectionTitle('Help'),
            SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeaturesScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.star,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Features',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.headset_mic,
                        size: iconSize,
                        color: isDarkMode ? Colors.white : Colors.black),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Support',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                bool cleared = await clearUserData();
                if (cleared) {
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: containerHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.logout,
                        size: iconSize,
                        color: const Color.fromARGB(255, 176, 0, 32)),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color.fromARGB(255, 176, 0, 32)),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: const Color.fromARGB(255, 176, 0, 32),
                        size: arrowIconSize),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  void showSubscription(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cancel/Renew'),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close))
          ],
        ),
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black),
        content: Text(
          ' you can Cancel or Renew this plan',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showCancelSubscription(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle unblock action
              Navigator.pop(context);
              showRenewSubscription(context);
            },
            child: Text(
              'Renew',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 82, 113, 255)),
            ),
          ),
        ],
      ),
    );
  }

  void showCancelSubscription(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: const Text('Unblock User'),
        // titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content: Text(
          'Are you sure you want to cancel your subscription?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle unblock action
              Navigator.pop(context);
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 82, 113, 255)),
            ),
          ),
        ],
      ),
    );
  }

  void showRenewSubscription(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: const Text('Unblock User'),
        // titleTextStyle: AppFonts.titleBold(fontSize: 20),
        content: Text(
          'You will be redirected to our payment gateway partner',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionScreen(),
                  ));
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 82, 113, 255)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
