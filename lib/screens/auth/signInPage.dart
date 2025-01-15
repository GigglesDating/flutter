import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/network/auth_provider.dart';
import 'package:giggles/screens/auth/aadhar_verification/adhar_verification_page.dart';
import 'package:giggles/screens/auth/otp_page.dart';
import 'package:giggles/screens/user/user_profile_creation_page.dart';
import 'package:giggles/screens/user/while_waiting_events_page.dart';
import 'package:provider/provider.dart';

import 'Video_intro_screen.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({
    super.key,
  });

  @override
  State<SigninPage> createState() => _signInPageState();
}

class _signInPageState extends State<SigninPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode _focusPhone = FocusNode();
  bool _otpFieldVisible = false;
  final signInFormKey = GlobalKey<FormState>();

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

  void closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // Enter full-Page landscape mode by hiding system UI and locking orientation
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SmsAutoFill().listenForCode();
    // Hide only the status bar
    closeKeyboard();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // @override
  // void dispose() {
  //   SmsAutoFill().unregisterListener();
  //   super.dispose();
  // }

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
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        body: Stack(
          children: [
            // The backdrop filter for blur effect
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            //   child: Container(
            //     color: Colors.black.withOpacity(0), // Transparent container
            //   ),
            // ),

            // Image.asset('assets/images/loginPagebg.png'),
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
                      // SizedBox(height: kToolbarHeight,),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width / 2.5,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 2.5,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme
                                    .of(context)
                                    .brightness ==
                                    Brightness.light
                                    ? AppColors.white
                                    : AppColors.black,
                                width: 2)),
                        child: Image.asset(
                          Theme
                              .of(context)
                              .brightness == Brightness.light
                              ? 'assets/images/logodarktheme.png'
                              : 'assets/images/logolighttheme.png',
                          // height: 150,
                          // width: 150,
                        ),
                      ),
                      const SizedBox(
                        height: kToolbarHeight + kTextTabBarHeight,
                      ),
                      _otpFieldVisible
                          ? const SizedBox()
                          : TextFormField(
                        controller: phoneNumberController,
                        focusNode: _focusPhone,
                        keyboardType: TextInputType.phone,

                        textInputAction: TextInputAction.done,
                        style: AppFonts.hintTitle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .tertiary,
                        ),
                        cursorHeight: 20,
                        maxLength: 10,
                        maxLines: 1,
                        minLines: 1,
                        // onFieldSubmitted: (value) {
                        //   // Called when the user presses the "Done" button
                        //   closeKeyboard();
                        //   // You can add any additional logic here
                        // },
                        onChanged: (value) {
                          if (value.length == 10) {
                            closeKeyboard();
                          }
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                          // Allows only numbers
                        ],

                        validator: (value) {
                          bool isValidLength(String text) {
                            return text.length >= 10;
                          }

                          if (value!.isEmpty) {
                            return 'Mobile number is empty';
                          } else if (!isValidLength(value)) {
                            return 'Enter complete mobile number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior:
                          FloatingLabelBehavior.never,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16),
                          hintText: 'Phone',
                          filled: true,
                          fillColor: Theme
                              .of(context)
                              .brightness ==
                              Brightness.light
                              ? AppColors.white
                              : AppColors.black,
                          counterText: '',
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
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      // _otpFieldVisible
                      //     ? PinFieldAutoFill(
                      //   controller: otpController,
                      //   currentCode: otpController.text,
                      //   decoration: UnderlineDecoration(
                      //     colorBuilder:
                      //     FixedColorBuilder(AppColors.white),
                      //     textStyle: AppFonts.hintTitle(
                      //       color: Theme
                      //           .of(context)
                      //           .colorScheme
                      //           .tertiary,
                      //     ),
                      //   ),
                      //   // cursorHeight: 20,
                      //   codeLength: 6,
                      //   // Length of the OTP
                      //   onCodeChanged: (value) {
                      //     if (value != null && value.length == 6) {
                      //       otpController.text = value;
                      //       closeKeyboard();
                      //       // You can add any additional action here, such as validation
                      //     }
                      //   },
                      //   onCodeSubmitted: (value) {
                      //     // Optionally handle the case when OTP is submitted automatically
                      //     otpController.text = value;
                      //   },
                      // )
                      //     : SizedBox(),
                      // _otpFieldVisible
                      //     ? TextFormField(
                      //         controller: otpController,
                      //         style: AppFonts.hintTitle(
                      //             color:
                      //                 Theme.of(context).colorScheme.tertiary),
                      //         cursorHeight: 20,
                      //         maxLength: 6,
                      //         maxLines: 1,
                      //         minLines: 1,
                      //         onChanged: (value) {
                      //           if (value.length == 6) {
                      //             _closeKeyboard();
                      //           }
                      //         },
                      //         keyboardType: TextInputType.phone,
                      //         inputFormatters: <TextInputFormatter>[
                      //           FilteringTextInputFormatter.digitsOnly
                      //           // Allows only numbers
                      //         ],
                      //         validator: (value) {
                      //           bool isValidLength(String text) {
                      //             return text.length >= 6;
                      //           }

                      //           if (value!.isEmpty) {
                      //             return 'OTP is empty';
                      //           } else if (!isValidLength(value)) {
                      //             return 'Enter 6 digit OTP';
                      //           }
                      //           return null;
                      //         },
                      //         decoration: InputDecoration(
                      //           floatingLabelBehavior:
                      //               FloatingLabelBehavior.never,
                      //           contentPadding:
                      //               EdgeInsets.symmetric(horizontal: 16),
                      //           hintText: 'Otp',
                      //           isDense: true,
                      //           hintStyle: TextStyle(
                      //             color:
                      //                 Theme.of(context).colorScheme.secondary,
                      //           ),
                      //           suffixIcon: Container(
                      //             width: MediaQuery.of(context).size.width / 3,
                      //             padding: EdgeInsets.only(right: 8),
                      //             child: Align(
                      //               alignment: Alignment.centerRight,
                      //               child: InkWell(
                      //                 onTap: userProvider.isResendOTPLoading
                      //                     ? null
                      //                     : () async {
                      //                         if (_otpFieldVisible) {
                      //                           try {
                      //                             final isOtpValidate =
                      //                                 await userProvider
                      //                                     .postResendOTP();
                      //                             if (isOtpValidate == true) {
                      //                               ShowDialog().showSuccessDialog(
                      //                                   context,
                      //                                   'OTP Resend Successfully');
                      //                             } else {
                      //                               ShowDialog()
                      //                                   .showErrorDialog(
                      //                                       context,
                      //                                       'Please Try Again');
                      //                             }
                      //                           } catch (e) {
                      //                             ShowDialog().showErrorDialog(
                      //                                 context,
                      //                                 'Failed to Resend OTP: $e');
                      //                           }
                      //                         }
                      //                       },
                      //                 child: userProvider.isResendOTPLoading
                      //                     ? SizedBox(
                      //                         width: 20,
                      //                         height: 20,
                      //                         child: Align(
                      //                           alignment: Alignment.center,
                      //                           child:
                      //                               CircularProgressIndicator(
                      //                             color: AppColors.primary,
                      //                             strokeWidth: 2,
                      //                           ),
                      //                         ),
                      //                       )
                      //                     : Text(
                      //                         'Resend OTP',
                      //                         textAlign: TextAlign.start,
                      //                         style: TextStyle(
                      //                             color: Theme.of(context)
                      //                                 .hintColor),
                      //                       ),
                      //               ),
                      //             ),
                      //           ),
                      //           counterText: '',
                      //           filled: true,
                      //           fillColor: Theme.of(context).brightness ==
                      //                   Brightness.light
                      //               ? AppColors.white
                      //               : AppColors.black,
                      //           border: OutlineInputBorder(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(22)),
                      //               borderSide:
                      //                   BorderSide(color: AppColors.white)),
                      //           focusedBorder: OutlineInputBorder(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(22)),
                      //               borderSide:
                      //                   BorderSide(color: AppColors.white)),
                      //           enabledBorder: const OutlineInputBorder(
                      //             // Border when enabled
                      //             borderSide:
                      //                 BorderSide(color: AppColors.white),
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(22)),
                      //           ),
                      //           errorBorder: const OutlineInputBorder(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(22)),
                      //             borderSide:
                      //                 BorderSide(color: AppColors.error),
                      //           ),
                      //         ),
                      //       )
                      //     : SizedBox(),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // minimumSize: Size(250, 50),
                            foregroundColor:
                            Theme
                                .of(context)
                                .colorScheme
                                .onPrimary,
                            backgroundColor:
                            Theme
                                .of(context)
                                .brightness == Brightness.light
                                ? AppColors.white
                                : AppColors.black,
                          ),
                          onPressed: userProvider.isLoading
                              ? null
                              : () async {
                            // final success =
                            //     await userProvider.fetchUserInterestList();
                            // if (success?.status == true) {
                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             UserProfileCreationPage(userInterestList: success?.data,),
                            //         // VideoIntroPage(videoUrl: success?.data?.introVideo,),
                            //       ));
                            // }

                            // final success = await userProvider.fetchUserInterestList();
                            // if(success?.status==true){
                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>  WhiteWaitingEventsPage()
                            //       ));
                            // }

                            if (_otpFieldVisible) {
                              // OTP Verification Flow
                              if (signInFormKey.currentState!
                                  .validate()) {
                                try {
                                  var userMap = {
                                    'otp': otpController.text
                                  };

                                  // Call OTP Verify API
                                  final isOtpValidate = await userProvider
                                      .otpVerify(userMap);

                                  print(
                                      'OTP Verify Response: ${isOtpValidate
                                          ?.toJson()}');
                                  print(
                                      'Token: ${SharedPref()
                                          .getTokenDetail()}');

                                  if (isOtpValidate != null &&
                                      isOtpValidate.status == true) {
                                    print(
                                        "helloo123 ${isOtpValidate.data!
                                            .aadhaarVerified}");
                                    // Fetch intro video data
                                    final success = await userProvider
                                        .fetchIntroVideoData();
                                    if (success != null &&
                                        success.status == true) {
                                      if (success.data?.introVideo
                                          ?.isNotEmpty ??
                                          false) {
                                        if (isOtpValidate.data!.isAgree !=
                                            true) {
                                          print(
                                              "ayush1 ${isOtpValidate.data!
                                                  .isAgree} ");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoIntroPage(
                                                    videoUrl: success
                                                        .data!.introVideo!,
                                                  ),
                                            ),
                                          );
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         SignUPPage(),
                                          //   ),
                                          // );
                                        } else if (isOtpValidate
                                            .data!.aadhaarVerified !=
                                            true) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const AadharVerificationPage(),
                                              ));

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
                                          //   //
                                          // }
                                        } else
                                        if (isOtpValidate.data!.isFirstTime !=
                                            true) {
                                          print(
                                              "ayush123 ${isOtpValidate.data!
                                                  .isFirstTime} ");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfileCreationPage()),
                                          );
                                        } else {
                                          print("last");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WhileWaitingEventsPage()),
                                          );
                                        }
                                        // Navigate to Video Intro Page
                                      } else {
                                        ShowDialog().showErrorDialog(
                                            context,
                                            userProvider.errorMessage);
                                      }
                                    } else {
                                      ShowDialog().showErrorDialog(
                                          context,
                                          userProvider.errorMessage);
                                    }
                                  } else {
                                    ShowDialog().showErrorDialog(context,
                                        userProvider.errorMessage);
                                  }
                                } catch (e) {
                                  print('Error in OTP verification: $e');
                                  ShowDialog().showErrorDialog(
                                      context, userProvider.errorMessage);
                                }
                              }
                            } else {
                              // Login Flow
                              if (signInFormKey.currentState!
                                  .validate()) {
                                try {
                                  var userMap = {
                                    'phone': phoneNumberController.text
                                  };

                                  // Call Login API
                                  final userLogin =
                                  await userProvider.login(userMap);
                                  print('userLogin');
                                  print(userLogin);

                                  if (userLogin != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtpPage(),
                                      ),
                                    ).then((result) {});
                                    // setState(() {
                                    //   _otpFieldVisible = true;
                                    // });
                                  } else {
                                    ShowDialog().showErrorDialog(context,
                                        userProvider.errorMessage);
                                  }
                                } catch (e) {
                                  print('Error in login: $e');
                                  ShowDialog().showErrorDialog(
                                      context, userProvider.errorMessage);
                                }
                              }
                            }

                            // if (_otpFieldVisible) {
                            //   if (signInFormKey.currentState!
                            //       .validate()) {
                            //     try {
                            //       var userMap = {
                            //         'otp': otpController.text
                            //       };
                            //       final isOtpValidate = await userProvider
                            //           .otpVerify(userMap);
                            //       print('response.verufy');
                            //       print(SharedPref().getTokenDetail());
                            //       if (isOtpValidate!.status == "true") {
                            //         final success = await userProvider
                            //             .fetchIntroVideoData();
                            //         if (success?.status == true) {
                            //           if (success!
                            //               .data!.introVideo!.isNotEmpty) {
                            //             Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                     builder: (context) =>
                            //                         VideoIntroPage(
                            //                           videoUrl: success
                            //                               .data!
                            //                               .introVideo,
                            //                         )));
                            //           } else {
                            //             ShowDialog().showErrorDialog(
                            //                 context,
                            //                 userProvider.errorMessage);
                            //           }
                            //         } else {
                            //           ShowDialog().showErrorDialog(
                            //               context,
                            //               userProvider.errorMessage);
                            //         }
                            //       } else {
                            //         ShowDialog().showErrorDialog(context,
                            //             userProvider.errorMessage);
                            //       }
                            //     } catch (e) {
                            //       ShowDialog().showErrorDialog(
                            //           context, userProvider.errorMessage);
                            //     }
                            //   }
                            // } else {
                            //   if (signInFormKey.currentState!
                            //       .validate()) {
                            //     try {
                            //       var userMap = {
                            //         'phone': phoneNumberController.text
                            //       };

                            //       final userLogin =
                            //           await userProvider.login(userMap);
                            //       if (userLogin != null) {
                            //         setState(() {
                            //           _otpFieldVisible = true;
                            //         });
                            //         ShowDialog().showSuccessDialog(
                            //             context,
                            //             userProvider.successMessage);
                            //       } else {
                            //         ShowDialog().showErrorDialog(context,
                            //             userProvider.errorMessage);
                            //       }
                            //     } catch (e) {
                            //       ShowDialog().showErrorDialog(
                            //           context, userProvider.errorMessage);
                            //     }
                            //   }
                            // }
                            ////
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
                            _otpFieldVisible ? 'Login' : 'Get OTP',
                            style: AppFonts.titleBold().copyWith(
                              color:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _otpFieldVisible
                          ? TextButton(
                        onPressed: () {
                          setState(() {
                            _otpFieldVisible = false;
                            phoneNumberController.clear();
                          });
                        },
                        child: Text(
                          'Wrong Number?',
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .primaryColor),
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

        bottomSheet: Platform.isIOS ? _focusPhone.hasFocus
            ? CustomKeyboardToolbar(
          onDonePressed: () {
            // print('Phone number entered: ${_controller.text}');
            _focusPhone.unfocus(); // Dismiss keyboard
          },
        )
            : null : null,
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
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onDonePressed,
            child: Text(
              'Done',
              style: TextStyle(color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}