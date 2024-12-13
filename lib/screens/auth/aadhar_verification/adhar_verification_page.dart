import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/screens/user/user_profile_creation_page.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/utils/show_dialog.dart';
import '../../../network/auth_provider.dart';
import 'aadhar_verification_result_page.dart';

class AadharVerificationPage extends StatefulWidget {
  const AadharVerificationPage({
    super.key,
  });

  @override
  State<AadharVerificationPage> createState() => _AadharVerificationPage();
}

class _AadharVerificationPage extends State<AadharVerificationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  FocusNode otpFocusNode = FocusNode();

  // late AnimationController _controller;
  // File? _imageFile;
  // bool isCameraOpen = false;
  // bool isImagePreview = false;
  // bool isOtpField = false;
  // String? imagePath;
  // late Future<void> _initializeControllerFuture;
  // CameraController? _cameraController;
  // bool _isCameraInitialized = false;
  var hyperKycConfig;

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> saveLastScreen() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('lastScreen', 'signUpVerified');
    await SharedPref.signUpVerifiedScreenSave();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveLastScreen();
    // initializeCamera();
    final transactionId = 'giggles' + getRandomString(10);
    hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
      appId: 'o811fk',
      //  Get this from Hyperverge team
      appKey: '3ddhunl5z427du78rm10',
      //  Get this from Hyperverge team
      workflowId: 'Aadhar_facematch',
      //  Get workflow-id from Hyperverge dashboard
      transactionId: transactionId,
    );

    // _controller = CameraController(
    //   // CameraLensDirection.front(),
    //   const CameraDescription(
    //       name: 'Camera Front',
    //       lensDirection: CameraLensDirection.front,
    //       sensorOrientation: 90),
    //   ResolutionPreset.high,
    // );
    // _initializeControllerFuture = _controller.initialize();
  }

  void startKYCProcess() async {
    try {
      //  Launch HyperKyc using launch() function
      HyperKycResult hyperKycResult =
          await HyperKyc.launch(hyperKycConfig: hyperKycConfig);
      handleKYCResult(hyperKycResult);
      print('hyperKycResult');
      print(hyperKycResult);
    } catch (error) {
      print("Error starting KYC process: $error");
    }
  }

  void handleKYCResult(HyperKycResult result) {
    print('result122222');
    print(result);
    print(result.status);
    print(result.status?.value);
    print(result.details);
    switch (result.status) {
      case HyperKycStatus.autoApproved:
        Future.microtask(() async {
          // Fetch data when the screen appears
          var map = {
            'aadhaar_data': result.details,
          };
          print('result.details');
          print(result.details);
          Provider.of<AuthProvider>(context, listen: false)
              .postAadharData(map)
              .then(
            (value) {
              if (value == true) {
                print('value');
                print(value);
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AadharVerificationResultPage(
                          resultImageUrl: 'assets/icons/success_icon.svg',
                          resultButtonText: 'Continue',
                          resultStatus: 'Successful',
                          resultDescription:
                              'Aadhar verification is complete!  Go ahead and Personalize your profile',
                          onPressed: () async {
                            final success = await Provider.of<AuthProvider>(
                                    context,
                                    listen: false)
                                .fetchUserInterestList();
                            if (success?.status == true) {
                              print('success?.data');
                              print(success?.data);
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfileCreationPage(
                                        userInterestList: success?.data,
                                      ),
                                      // VideoIntroPage(videoUrl: success?.data?.introVideo,),
                                    ));
                              });
                            }
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => UserProfileCreationPage()));
                          },
                        ),
                      ));
                });
              } else {
                ShowDialog().showErrorDialog(context, 'Something went wrong');
              }
            },
          );
        });

      case HyperKycStatus.autoDeclined:
      // workflow successful

      case HyperKycStatus.needsReview:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AadharVerificationResultPage(
                resultImageUrl: 'assets/icons/inreview_icon.svg',
                resultButtonText: 'Retry',
                resultStatus: 'InReview',
                resultDescription:
                    'Verification pending.  We may need additional information from you to complete the process, write to us at support @giglesplatonicdating.com',
                onPressed: () {
                  Navigator.pop(context);
                  startKYCProcess();
                },
              ),
            ));
      case HyperKycStatus.error:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AadharVerificationResultPage(
                resultImageUrl: 'assets/icons/failed_icon.svg',
                resultButtonText: 'Retry',
                resultStatus: 'Failed',
                resultDescription:
                    'Verification failed couldn’t verify your identity. Make sure everything is correct and try again',
                onPressed: () {
                  Navigator.pop(context);
                  startKYCProcess();
                },
              ),
            ));
        // failure
        print('failure');
      case HyperKycStatus.userCancelled:
        // user cancelled
        print('user cancelled');
      case HyperKycStatus.ongoing:
        // user cancelled
        print('user ongoing');
      case HyperKycStatus.manuallyApproved:
        // user cancelled
        print('user manualapproved');
      case HyperKycStatus.manuallyDeclined:
        // user cancelled
        print('user manualdeclined');
      default:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AadharVerificationPage()));
    }
  }

  // Future<void> initializeCamera() async {
  //   final cameras = await availableCameras();
  //   if (cameras.isNotEmpty) {
  //     _cameraController = CameraController(
  //       // CameraLensDirection.front(),
  //       const CameraDescription(
  //           name: 'Camera Front',
  //           lensDirection: CameraLensDirection.front,
  //           sensorOrientation: 90),
  //       ResolutionPreset.high,
  //     );
  //
  //     // Show loading indicator while camera is being initialized
  //     await _cameraController?.initialize();
  //
  //     if (mounted) {
  //       setState(() {
  //         _isCameraInitialized = true;
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    // _cameraController?.dispose();
    super.dispose();
  }

  // Future<void> pickImageFromCamera() async {
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front, // Use the front camera
  //   );
  //
  //   if (image != null) {
  //     setState(() {
  //       _imageFile = File(image.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: kToolbarHeight,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //     shape: BoxShape.rectangle,
              //   ),
              //   width: MediaQuery.of(context).size.width / 1.8,
              //   height: MediaQuery.of(context).size.width / 1.8,
              //   child: CameraPreview(_controller),
              // ),
              // isCameraOpen
              //     ? Container(
              //         width: MediaQuery.of(context).size.width /
              //             1.8, // Set the custom width
              //         height: MediaQuery.of(context).size.width /
              //             1.8, // Set the custom height
              //         child: isImagePreview
              //             ? Image.file(
              //                 File(imagePath!),
              //                 fit: BoxFit.cover,
              //               )
              //             : CameraPreview(_cameraController!),
              //       )
              //     : InkWell(
              //         onTap: () async {
              //           if (isCameraOpen) {
              //             if (isImagePreview) {
              //               isCameraOpen = true;
              //               isImagePreview = false;
              //             } else {
              //               final image = await _cameraController?.takePicture();
              //               setState(() {
              //                 isImagePreview = true;
              //                 imagePath = image?.path;
              //               });
              //             }
              //           }
              //           setState(() {
              //             isCameraOpen = true;
              //           });
              //         },
              //         child: Image.asset(
              //           'assets/images/faceidplaceholder.png',
              //           width: MediaQuery.of(context).size.width / 1.8,
              //           height: MediaQuery.of(context).size.width / 1.8,
              //         ),
              //       ),
              Image.asset(
                'assets/images/aadhar_verification.png',
                width: MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.width / 1.1,
              ),

              SizedBox(
                height: 24,
              ),
              // TextButton(
              //   onPressed: () async {
              //     // if (isCameraOpen) {
              //     //   if (isImagePreview) {
              //     //     isCameraOpen = true;
              //     //     isImagePreview = false;
              //     //   } else {
              //     //     final image = await _cameraController?.takePicture();
              //     //     setState(() {
              //     //       isImagePreview = true;
              //     //       imagePath = image?.path;
              //     //     });
              //     //   }
              //     // }
              //     // setState(() {
              //     //   isCameraOpen = true;
              //     // });
              //
              //     startKYCProcess();
              //     // launchAppIdAppKeyHyperKyc(context);
              //   },
              //   // padding: const EdgeInsets.all(8.0),
              //   child: Text(
              //     isCameraOpen
              //         ? isImagePreview
              //             ? 'Recapture'
              //             : 'Capture'
              //         : 'Open\nCamera',
              //     textAlign: TextAlign.center,
              //     style: AppFonts.titleBold(
              //         color: Theme.of(context).colorScheme.tertiary,
              //         fontSize: 20),
              //   ),
              // ),
              // FutureBuilder<void>(
              //   future: _initializeControllerFuture,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.done) {
              //       // If the future is complete, display the preview
              //       return CameraPreview(_controller);
              //     } else {
              //       // Otherwise, display a loading indicator
              //       return Center(child: CircularProgressIndicator());
              //     }
              //   },
              // ),
              Text(
                'Verify Your Identity',
                style: AppFonts.titleBold(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 24),
              ),

              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'All our members are required to verify their profile with Aadhar, to ensure authentic and secure connections at Giggles. With your consent, we retrieve your identity details via DigiLocker, to maintain a safe and trusted community. Rest assured, your data is safe.',
                  style: AppFonts.titleRegular(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // minimumSize: Size(250, 50),
                      // foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: AppColors.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    onPressed: () async {
                      startKYCProcess();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Next',
                          style: AppFonts.titleBold(
                            color: AppColors.white,
                          )),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: isOtpField ? kToolbarHeight : 0),
              // isOtpField
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           SizedBox(
              //             height: 48,
              //             width: MediaQuery.of(context).size.width / 2.5,
              //             child: TextFormField(
              //               controller: otpController,
              //               focusNode: otpFocusNode,
              //               keyboardType: TextInputType.phone,
              //               inputFormatters: <TextInputFormatter>[
              //                 FilteringTextInputFormatter.digitsOnly
              //                 // Allows only numbers
              //               ],
              //               style: AppFonts.titleMedium(
              //                   color: Theme.of(context).colorScheme.tertiary),
              //               cursorHeight: 20,
              //               cursorColor: Theme.of(context).colorScheme.tertiary,
              //               maxLength: 6,
              //               maxLines: 1,
              //               minLines: 1,
              //               onChanged: (value) {
              //                 if (value.length == 6) {
              //                   otpFocusNode.unfocus();
              //                 }
              //               },
              //               textAlign: TextAlign.center,
              //               decoration: InputDecoration(
              //                 floatingLabelBehavior: FloatingLabelBehavior.never,
              //                 counterText: '',
              //                 contentPadding:
              //                     const EdgeInsets.symmetric(horizontal: 12),
              //                 hintText: 'Enter OTP',
              //                 hintStyle: AppFonts.hintTitle(
              //                     color: Theme.of(context).colorScheme.tertiary,
              //                     fontSize: 14),
              //                 border: OutlineInputBorder(
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(22)),
              //                     borderSide: BorderSide(
              //                         color: Theme.of(context)
              //                             .colorScheme
              //                             .tertiary)),
              //                 focusedBorder: OutlineInputBorder(
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(22)),
              //                     borderSide: BorderSide(
              //                         color:
              //                             Theme.of(context).colorScheme.primary)),
              //               ),
              //             ),
              //           ),
              //           SizedBox(
              //             width: 12,
              //           ),
              //           Container(
              //             height: 48,
              //             width: MediaQuery.of(context).size.width / 2.5,
              //             child: ElevatedButton(
              //               style: ElevatedButton.styleFrom(
              //                 // minimumSize: Size(250, 50),
              //                 // foregroundColor: Theme.of(context).colorScheme.onPrimary,
              //                 backgroundColor: AppColors.primary,
              //                 side: BorderSide(
              //                   color: Theme.of(context).colorScheme.tertiary,
              //                 ),
              //               ),
              //               onPressed: () async {
              //                 Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder: (context) =>
              //                           const UserProfileCreationPage(),
              //                     ));
              //                 Future.delayed(const Duration(milliseconds: 500),
              //                     () {
              //                   _cameraController?.dispose();
              //                 });
              //               },
              //               child: Padding(
              //                 padding:
              //                     const EdgeInsets.symmetric(horizontal: 16.0),
              //                 child: Text('Verify OTP',
              //                     style: AppFonts.titleBold(
              //                         color: AppColors.white, fontSize: 14)),
              //               ),
              //             ),
              //           ),
              //         ],
              //       )
              //     : SizedBox(),
              // const SizedBox(height: kToolbarHeight),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceRecognitionPainter extends CustomPainter {
  final Animation<double> animation;

  FaceRecognitionPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint blueLinePaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw geometric face structure (simplified for this example)
    Path facePath = Path();

    // Head outline
    facePath.moveTo(size.width * 0.5, size.height * 0.1); // Top-center
    facePath.lineTo(size.width * 0.8, size.height * 0.3); // Right top
    facePath.lineTo(size.width * 0.9, size.height * 0.6); // Right bottom
    facePath.lineTo(size.width * 0.5, size.height * 0.9); // Bottom-center
    facePath.lineTo(size.width * 0.1, size.height * 0.6); // Left bottom
    facePath.lineTo(size.width * 0.2, size.height * 0.3); // Left top
    facePath.close(); // Back to Top-center

    // Eyes (left and right)
    Path eyePath = Path();
    eyePath.moveTo(size.width * 0.35, size.height * 0.45); // Left eye start
    eyePath.lineTo(size.width * 0.45, size.height * 0.45); // Left eye end
    eyePath.moveTo(size.width * 0.55, size.height * 0.45); // Right eye start
    eyePath.lineTo(size.width * 0.65, size.height * 0.45); // Right eye end

    // Nose
    Path nosePath = Path();
    nosePath.moveTo(size.width * 0.5, size.height * 0.5); // Nose bridge
    nosePath.lineTo(size.width * 0.5, size.height * 0.7); // Nose bottom

    // Mouth
    Path mouthPath = Path();
    mouthPath.moveTo(size.width * 0.4, size.height * 0.75); // Left mouth corner
    mouthPath.lineTo(
        size.width * 0.6, size.height * 0.75); // Right mouth corner

    // Drawing face, eyes, nose, and mouth
    canvas.drawPath(facePath, linePaint);
    canvas.drawPath(eyePath, linePaint);
    canvas.drawPath(nosePath, linePaint);
    canvas.drawPath(mouthPath, linePaint);

    // Animate a horizontal blue scanning line across the face
    double scanLineY = size.height *
        (0.3 + (0.4 * animation.value)); // Adjust scan line position
    canvas.drawLine(
      Offset(size.width * 0.1, scanLineY), // Left edge of the face
      Offset(size.width * 0.9, scanLineY), // Right edge of the face
      blueLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DisplayPicturePage extends StatelessWidget {
  final String imagePath;

  const DisplayPicturePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captured Image')),
      body: Image.file(File(imagePath)),
    );
  }
}
