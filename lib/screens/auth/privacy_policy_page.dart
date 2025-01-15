import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatefulWidget {
  final bool? isFromTermsOfUse;
  const PrivacyPolicy({this.isFromTermsOfUse, super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  String PrivacyPolicy = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Provider.of<AuthProvider>(context, listen: false).PrivacyPolicy().then(
        (value) {
          if (value?.status == true) {
            setState(() {
              PrivacyPolicy = value!.data!.privacyPolicy.toString();
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 1,
          shadowColor: const Color(0xffDDDDDD),
          titleSpacing: 0,
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.tertiary,)),
          title: Text(
            "Privacy and Policy",
            style: AppFonts.titleRegular(color: Theme.of(context).colorScheme.tertiary, fontSize: 20),
          ),
          // AppText(
          //     widget.isFromTermsOfUse!
          //         ? "Terms & conditions"
          //         : "Privacy Policy",
          //     style: GoogleFonts.getFont('Roboto',
          //         fontSize: 14, fontWeight: FontWeight.w700))
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [

            HtmlWidget(
              PrivacyPolicy ?? '',
              onTapUrl: (url) async{
                return launchUrl(Uri.parse(url));

              },
              textStyle: TextStyle(
                  // color: AppColors.appColor,
                  fontSize: 12,
                  // letterSpacing: 2,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400),
            ),
            // Text(
            //   PrivacyPolicy,
            //   style: AppFonts.titleRegular(color: Theme.of(context).colorScheme.tertiary),
            // ),
          ]),
        ));
  }
}
