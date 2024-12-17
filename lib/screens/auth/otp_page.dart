import 'package:alt_sms_autofill/alt_sms_autofill.dart';
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
  String? _commingSms = 'Unknown';

  @override
  void initState() {
    // TODO: implement initState
    initSmsListener();
  }

  Future<void> initSmsListener() async {
    String? commingSms;
    try {
      commingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      commingSms = 'Failed to get SMS.';
    }

    if (!mounted) return;

    // Extract only digits from the incoming SMS
    final otpCode = _extractDigits(commingSms ?? '');

    setState(() {
      otpController.text = otpCode;
    });
  }

// Helper function to extract only digits from the string
  String _extractDigits(String input) {
    final digitRegex = RegExp(r'\d+');
    final match = digitRegex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  @override
  void dispose() {
    AltSmsAutofill().unregisterListener();
    super.dispose();
  }

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
                          ? TextFormField(
                              controller: otpController,
                              style: AppFonts.hintTitle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              cursorHeight: 20,
                              maxLength: 6,
                              maxLines: 1,
                              minLines: 1,
                              onChanged: (value) {
                                if (value.length == 6) {
                                  _closeKeyboard();
                                }
                              },
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                                // Allows only numbers
                              ],
                              validator: (value) {
                                bool isValidLength(String text) {
                                  return text.length >= 6;
                                }

                                if (value!.isEmpty) {
                                  return 'OTP is empty';
                                } else if (!isValidLength(value)) {
                                  return 'Enter 6 digit OTP';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                hintText: 'Otp',
                                isDense: true,
                                hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                suffixIcon: Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  padding: EdgeInsets.only(right: 8),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: userProvider.isResendOTPLoading
                                          ? null
                                          : () async {
                                              if (_otpFieldVisible) {
                                                try {
                                                  final isOtpValidate =
                                                      await userProvider
                                                          .postResendOTP();
                                                  if (isOtpValidate == true) {
                                                    ShowDialog().showSuccessDialog(
                                                        context,
                                                        'OTP Resend Successfully');
                                                  } else {
                                                    ShowDialog()
                                                        .showErrorDialog(
                                                            context,
                                                            'Please Try Again');
                                                  }
                                                } catch (e) {
                                                  ShowDialog().showErrorDialog(
                                                      context,
                                                      'Failed to Resend OTP: $e');
                                                }
                                              }
                                            },
                                      child: userProvider.isResendOTPLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: AppColors.primary,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Resend OTP',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            ),
                                    ),
                                  ),
                                ),
                                counterText: '',
                                filled: true,
                                fillColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.white
                                    : AppColors.black,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                enabledBorder: const OutlineInputBorder(
                                  // Border when enabled
                                  borderSide:
                                      BorderSide(color: AppColors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                  borderSide:
                                      BorderSide(color: AppColors.error),
                                ),
                              ),
                            )
                          : SizedBox(),
                      // _otpFieldVisible
                      //     ? PinFieldAutoFill(
                      //         controller: otpController,
                      //         currentCode: otpController.text,
                      //         decoration: UnderlineDecoration(
                      //           colorBuilder:
                      //               FixedColorBuilder(AppColors.white),
                      //           textStyle: AppFonts.hintTitle(
                      //             color: Theme.of(context).colorScheme.tertiary,
                      //           ),
                      //         ),
                      //         codeLength: 6,
                      //         onCodeChanged: (value) {
                      //           if (value != null && value.length == 6) {
                      //             otpController.text = value;
                      //             _closeKeyboard();
                      //           }
                      //         },
                      //         onCodeSubmitted: (value) {
                      //           otpController.text = value;
                      //         },
                      //       )
                      //     : SizedBox(),
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
