import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/screens/user/while_waiting_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UserWaitListPage extends StatefulWidget {
  const UserWaitListPage({
    super.key,
  });

  @override
  State<UserWaitListPage> createState() => _UserWaitListPage();
}

class _UserWaitListPage extends State<UserWaitListPage> {
  final Uri gmailUri = Uri(
    scheme: 'intent',
    path: 'mailto:approvals@gigglesplatonicdating.com',
    query: 'subject=Support%20Request&body=Hello%2C%20I%20need%20help...',
    // queryParameters: {
    //   'package': 'com.google.android.gm',
    // },
  );
  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Timer(const Duration(seconds: 6), () {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) =>  WhileWaitingPage(),));
    // },);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show multi-select dialog

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 24,),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 48,
                width: 60,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  WhileWaitingPage(),));
                  },
                  style: ElevatedButton.styleFrom(
                    // fixedSize: Size(, 48),
                    // visualDensity: VisualDensity(horizontal: 0,vertical: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Add padding if needed
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(  width: 2,color: Theme.of(context).colorScheme.tertiary)
                      // Customize button shape
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.arrow_forward,color:  Theme.of(context).colorScheme.tertiary,)
                  ),
                ),
              ),
            ),
            SizedBox(height: kToolbarHeight,),
            Center(
              child: Image.asset(
                'assets/images/waitlistgreentick.png',
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Center(
                child: Text(
              'We have received\nyour application',
              textAlign: TextAlign.center,
              style: AppFonts.titleMedium(
                  color: Theme.of(context).colorScheme.tertiary, fontSize: 24),
            )),
            SizedBox(
              height: kToolbarHeight,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage(),));
                    },
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.waitlistNuumberBg),
                      child: Center(
                          child: Text(
                        '5',
                        textAlign: TextAlign.center,
                        style: AppFonts.titleBold(
                            color: AppColors.black, fontSize: 84),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.waitlistNuumberBg),
                    child: Center(
                        child: Text(
                      '7',
                      textAlign: TextAlign.center,
                      style: AppFonts.titleBold(
                          color: AppColors.black, fontSize: 84),
                    )),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.waitlistNuumberBg),
                    child: Center(
                        child: Text(
                      '0',
                      textAlign: TextAlign.center,
                      style: AppFonts.titleBold(
                          color: AppColors.black, fontSize: 84),
                    )),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.waitlistNuumberBg),
                    child: Center(
                        child: Text(
                      '4',
                      textAlign: TextAlign.center,
                      style: AppFonts.titleBold(
                          color: AppColors.black, fontSize: 84),
                    )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Memberships available',
                  style: AppFonts.titleMedium(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 18),
                )),
            Spacer(),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Watch out for an email from',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.titleMedium(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 18),
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){
                    openGmail();
                  },
                  child: Text(
                    'approvals@gigglesplatonicdating.com',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.titleMediumUnderLine(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18),
                  ),
                )),
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openGmail() async {
    // if (await canLaunchUrl(gmailUri)) {
    //   await launchUrl(gmailUri);
    // } else {
      // Fallback to generic mailto link if Gmail isn't available
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'approvals@gigglesplatonicdating.com',
        // query: 'subject=Support%20Request&body=Hello%2C%20I%20need%20help...',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        print('No email client available.');
        // Optionally show a message to the user
      }

  }

}
