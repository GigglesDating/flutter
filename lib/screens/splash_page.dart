import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/screens/date_booking_page.dart';

import 'auth/signInPage.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Hide only the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Timer(const Duration(seconds: 2), () {
      // Navigator.push(context, MaterialPageRoute(builder: (context) =>  DateBookingPage(),));
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  SigninPage(),));
    },);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.width/2,
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
