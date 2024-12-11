import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:provider/provider.dart';

class TermsPrivacyScreen extends StatefulWidget {
  final bool? isFromTermsOfUse;
  const TermsPrivacyScreen({this.isFromTermsOfUse, super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  String termsOfUse = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Provider.of<AuthProvider>(context, listen: false).termsOfUse().then(
        (value) {
          if (value?.status == true) {
            setState(() {
              termsOfUse = value!.data!.termsAndConditions.toString();
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          shadowColor: const Color(0xffDDDDDD),
          titleSpacing: 0,
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back)),
          title: Text(
            "Terms Of Use",
            style: AppFonts.titleRegular(color: AppColors.white, fontSize: 20),
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
      
            Text(
              termsOfUse,
              style: AppFonts.titleRegular(color: AppColors.black),
            ),
          ]),
        )
        
        );
  }
}

