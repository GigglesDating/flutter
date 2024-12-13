import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            ? AppColors.aadharSuccessScreenColor
            : widget.resultStatus == 'Failed'
                ? AppColors.aadharFailedScreenColor
                : AppColors.aadharinReviewScreenColor,
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
                style: AppFonts.titleBold(
                    color: AppColors.white,
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
                style: AppFonts.titleMedium(
                    color: AppColors.white,
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
                        // Sets the elevation (shadow effect)
                        backgroundColor: WidgetStateProperty.all(
                            widget.resultStatus == 'Successful'
                                ? AppColors.aadharSuccessScreenColor
                                : widget.resultStatus == 'Failed'
                                    ? AppColors.aadharFailedScreenColor
                                    : AppColors.aadharinReviewScreenColor),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(color: AppColors.white)))),
                    onPressed: widget.onPressed,
                    child: Text(
                      widget.resultButtonText,
                      style: AppFonts.titleBold(
                          color: AppColors.white,
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
