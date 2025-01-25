import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:flutter_svg/svg.dart';


class AadharStatusScreen extends StatefulWidget {
  const AadharStatusScreen({super.key});

  @override
  State<AadharStatusScreen> createState() => _AadharStatusScreenState();
}

class _AadharStatusScreenState extends State<AadharStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ProfileCreation1()));
          },
          child: const Text('Launch HyperVerge SDK'),
        ),
      ),
    );
  }
}














class AadharVerificationResultPage extends StatefulWidget {
  String resultStatus;
  String resultDescription;
  String resultImageUrl;
  String resultButtonText;

  VoidCallback onPressed;

  AadharVerificationResultPage({
    super.key,
    required this.resultStatus,
    required this.resultDescription,
    required this.resultImageUrl,
    required this.resultButtonText,
    required this.onPressed,
  });

  @override
  State<AadharVerificationResultPage> createState() =>
      _AadharVerificationResultPage();
}

class _AadharVerificationResultPage
    extends State<AadharVerificationResultPage> {
  @override
  void initState() {
    super.initState();
    check();
  }

  check() async {
    if (widget.resultStatus == 'Successful') {
      await SharedPref.digiScreenSave();
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('lastScreen','digiCheck');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: widget.resultStatus == 'Successful'
            ? Color(0xFF000000)
            : widget.resultStatus == 'Failed'
                ? Color(0xFF000000)
                : Color(0xFF000000),
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: kToolbarHeight + kToolbarHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  widget.resultImageUrl,
                  width: MediaQuery.of(context).size.width / 1.4,
                  height: MediaQuery.of(context).size.width / 1.4,
                ),
              ),
            ),
            SizedBox(
              height: kTextTabBarHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.resultStatus,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: MediaQuery.of(context).size.width * 0.1),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.resultDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: MediaQuery.of(context).size.width * 0.04),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width / 2,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(8),
                        backgroundColor: WidgetStateProperty.all(
                            widget.resultStatus == 'Successful'
                                ? Color(0xFF000000)
                                : widget.resultStatus == 'Failed'
                                    ? Color(0xFF000000)
                                    : Color(0xFF000000)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(color: Color(0xFF000000)))),
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ProfileCreation1()));
                    },
                    child: Text(
                      widget.resultButtonText,
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: MediaQuery.of(context).size.width * 0.05),
                    ),
                  )),
            ),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}
