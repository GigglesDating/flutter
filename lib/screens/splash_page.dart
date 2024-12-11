import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/screens/auth/aadhar_verification/adhar_verification_page.dart';
import 'package:giggles/screens/auth/signUpPage.dart';
import 'package:giggles/screens/user/user_profile_creation_page.dart';
import 'package:giggles/screens/user/white_waiting_events_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/signInPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage> {
  // Function to check login status and navigate accordingly
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    final lastScreen = prefs.getString('lastScreen');

    print("Token: $token, LastScreen: $lastScreen");

    if (token != null) {
      if (lastScreen == 'eventPage') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WhiteWaitingEventsPage(),
          ),
        );
      } else if (lastScreen == 'digiCheck') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileCreationPage()),
        );
      } else if (lastScreen == 'signUpVerified') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AadharVerificationPage(),
          ),
        );
      } else if (lastScreen == 'otpVerified') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUPPage()),
        );
      } else {
        print("sadasdasd");
        Timer(
          const Duration(seconds: 2),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SigninPage(),
              ),
            );
          },
        );
      }
    } else {
      // Handle case when token is null (no login)
      Timer(
        const Duration(seconds: 2),
        () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SigninPage(),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Perform async tasks after widget is built
    Future.delayed(Duration.zero, () {
      checkLoginStatus();
    });

    // Hide only the status bar and set the system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    // Set immersive sticky system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 2,
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/images/logolighttheme.png'
                  : 'assets/images/logodarktheme.png',
            )
          ],
        ),
      ),
    );
  }
}
