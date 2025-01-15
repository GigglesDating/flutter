import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:giggles/screens/auth/Video_intro_screen.dart';
import 'package:giggles/screens/auth/aadhar_verification/adhar_verification_page.dart';
import 'package:giggles/screens/auth/signInPage.dart';
import 'package:giggles/screens/auth/signUpPage.dart';
import 'package:giggles/screens/user/while_waiting_events_page.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

import '../user/user_profile_creation_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode _focusOTP = FocusNode();

  bool _otpFieldVisible = true;
  final signInFormKey = GlobalKey<FormState>();
  String? _commingSms = 'Unknown';
  final smartAuth = SmartAuth.instance;

  String? appSignature;

  @override
  void initState() {
    // TODO: implement initState
    smsRetriever();
  }

  void getAppSignature() async {
    final res = await smartAuth.getAppSignature();
    setState(() => appSignature = res.data);
    debugPrint('Signature: $res');
  }

  void smsRetriever() async {
    final res = await smartAuth.getSmsWithUserConsentApi();
    if (res.hasData) {
      debugPrint('smsRetriever: $res');
      final code = res.requireData.code;
      print('object');
      print(code);
      print(code.runtimeType);

      /// The code can be null if the SMS is received but the code is extracted from it
      if (code == null) return;
      otpController.text = code;
      otpController.selection = TextSelection.fromPosition(
        TextPosition(offset: otpController.text.length),
      );
    } else {
      debugPrint('smsRetriever failed: $res');
    }
  }

  @override
  void dispose() {
    smartAuth.removeUserConsentApiListener();
    super.dispose();
  }

  // Country selectedCountry = Country(
  //   phoneCode: "91",
  //   countryCode: "IN",
  //   e164Sc: 0,
  //   geographic: true,
  //   level: 1,
  //   name: "India",
  //   example: "India",
  //   displayName: "IN",
  //   displayNameNoCountryCode: "IN",
  //   e164Key: "",
  // );

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
                              autofillHints: [AutofillHints.oneTimeCode],
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
                              textInputAction: TextInputAction.done,
                              focusNode: _focusOTP,
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
                                                    otpController.clear();
                                                    smsRetriever();
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
                                  if (signInFormKey.currentState!.validate()) {
                                    try {
                                      var userMap = {'otp': otpController.text};
                                      final isOtpValidate =
                                          await userProvider.otpVerify(userMap);
                                      print('isOtpValidate');
                                      print(isOtpValidate.runtimeType);
                                      print(isOtpValidate);
                                      print(isOtpValidate?.data!.isAgree);
                                      print(isOtpValidate?.data!.isFirstTime);
                                      print(isOtpValidate?.data!.aadhaarVerified);
                                      print(isOtpValidate?.data!.isAgree != true);
                                      print(isOtpValidate?.data!.isFirstTime != true);
                                      print(isOtpValidate?.data!.aadhaarVerified != true);
                                      if (isOtpValidate != null &&
                                          isOtpValidate.status == true) {
                                        if (isOtpValidate.data!.isAgree ==
                                                false &&
                                            isOtpValidate
                                                    .data!.aadhaarVerified ==
                                                false &&
                                            isOtpValidate.data!.isFirstTime ==
                                                false && isOtpValidate.data!.isVideoWatched==false) {
                                          final success = await userProvider
                                              .fetchIntroVideoData();
                                          print('successIntro');
                                          print(success);
                                          print(success?.status);
                                          print(success?.data!.introVideo);
                                          if (success?.status == true) {
                                            if (success!
                                                .data!.introVideo!.isNotEmpty) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoIntroPage(
                                                            videoUrl: success
                                                                .data!
                                                                .introVideo,
                                                          )));
                                            } else {
                                              ShowDialog().showErrorDialog(
                                                  context,
                                                  userProvider.errorMessage);
                                            }
                                          }else{
                                            ShowDialog().showErrorDialog(
                                                context,
                                                userProvider.errorMessage);
                                          }
                                        } else if (isOtpValidate
                                                .data!.isAgree !=
                                            true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignUPPage()),
                                          );
                                        } else if (isOtpValidate
                                                .data!.aadhaarVerified !=
                                            true) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AadharVerificationPage(),
                                              ));
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           WhiteWaitingEventsPage()),
                                          // );
                                          // if(Platform.isIOS){
                                          //   Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             WhiteWaitingEventsPage()),
                                          //   );
                                          // }else{
                                          //   Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //         builder: (context) =>
                                          //         const AadharVerificationPage(),
                                          //       ));
                                          // //
                                          // }
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
                                                      WhileWaitingEventsPage()));
                                        }
                                      } else {
                                        ShowDialog().showErrorDialog(
                                            context, userProvider.errorMessage);
                                      }
                                    } catch (e) {
                                      ShowDialog().showErrorDialog(
                                          context, userProvider.errorMessage);
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
        bottomSheet: Platform.isIOS
            ? _focusOTP.hasFocus
                ? CustomKeyboardToolbar(
                    onDonePressed: () {
                      // print('Phone number entered: ${_controller.text}');
                      _focusOTP.unfocus(); // Dismiss keyboard
                    },
                  )
                : null
            : null,
      ),
    );
  }
}

class CustomKeyboardToolbar extends StatelessWidget {
  final VoidCallback onDonePressed;

  const CustomKeyboardToolbar({required this.onDonePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onDonePressed,
            child: Text(
              'Done',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
