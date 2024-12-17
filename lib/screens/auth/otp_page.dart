import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:giggles/screens/auth/aadhar_verification/adhar_verification_page.dart';
import 'package:giggles/screens/auth/otpScreen.dart';
import 'package:giggles/screens/auth/signInPage.dart';
import 'package:giggles/screens/auth/signUpPage.dart';
import 'package:giggles/screens/user/white_waiting_events_page.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../user/user_profile_creation_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool _otpFieldVisible = true;
  final signInFormKey = GlobalKey<FormState>();

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "IN",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  void initState() {
    super.initState();
    SmsAutoFill().listenForCode();
    // bool _otpFieldVisible = true;
    // Uncomment below lines if you want to set full-screen immersive mode.
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final userProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/loginscreenbg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                child: Form(
                  key: signInFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width / 2.5,
                        width: MediaQuery.of(context).size.width / 2.5,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.white
                                    : AppColors.black,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? 'assets/images/logodarktheme.png'
                              : 'assets/images/logolighttheme.png',
                        ),
                      ),
                      const SizedBox(
                          height: kToolbarHeight + kTextTabBarHeight),
                      _otpFieldVisible
                          ? PinFieldAutoFill(
                              controller: otpController,
                              currentCode: otpController.text,
                              decoration: UnderlineDecoration(
                                colorBuilder:
                                    FixedColorBuilder(AppColors.white),
                                textStyle: AppFonts.hintTitle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              codeLength: 6,
                              onCodeChanged: (value) {
                                if (value != null && value.length == 6) {
                                  otpController.text = value;
                                  _closeKeyboard();
                                }
                              },
                              onCodeSubmitted: (value) {
                                otpController.text = value;
                              },
                            )
                          : SizedBox(),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.white
                                    : AppColors.black,
                          ),
                          onPressed: userProvider.isLoading
                              ? null
                              : () async {
                                  if (_otpFieldVisible) {
                                    if (signInFormKey.currentState!
                                        .validate()) {
                                      try {
                                        var userMap = {
                                          'otp': otpController.text
                                        };

                                        final isOtpValidate = await userProvider
                                            .otpVerify(userMap);

                                        if (isOtpValidate != null &&
                                            isOtpValidate.status == true) {
                                          if (isOtpValidate
                                                  .data!.aadhaarVerified !=
                                              true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AadharVerificationPage()),
                                            );
                                          } else if (isOtpValidate
                                                  .data!.isFirstTime !=
                                              true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserProfileCreationPage()),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WhiteWaitingEventsPage()),
                                            );
                                          }
                                        } else {
                                          ShowDialog().showErrorDialog(context,
                                              userProvider.errorMessage);
                                        }
                                      } catch (e) {
                                        ShowDialog().showErrorDialog(
                                            context, userProvider.errorMessage);
                                      }
                                    }
                                  } else {
                                    if (signInFormKey.currentState!
                                        .validate()) {
                                      try {
                                        var userMap = {
                                          'phone': phoneNumberController.text
                                        };

                                        final userLogin =
                                            await userProvider.login(userMap);

                                        if (userLogin != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtpPage(),
                                            ),
                                          ).then((result) {});
                                        } else {
                                          ShowDialog().showErrorDialog(context,
                                              userProvider.errorMessage);
                                        }
                                      } catch (e) {
                                        ShowDialog().showErrorDialog(
                                            context, userProvider.errorMessage);
                                      }
                                    }
                                  }
                                },
                          child: userProvider.isLoading
                              ? SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _otpFieldVisible ? 'Verify' : 'Get OTP',
                                  style: AppFonts.titleBold().copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _otpFieldVisible
                          ? TextButton(
                              onPressed: () {
                                phoneNumberController.clear();
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SigninPage(),
                                    ),
                                  );
                                  setState(() {});
                                });
                              },
                              child: Text(
                                'Wrong Number?',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            )
                          : SizedBox.shrink(),
                      const SizedBox(height: kToolbarHeight),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
