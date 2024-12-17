// import 'package:flutter/material.dart';
// import 'package:giggles/constants/appColors.dart';
// import 'package:giggles/constants/appFonts.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';

// class OtpPage extends StatefulWidget {
//   String verificationId;
//   String phoneNumber;
//   OtpPage({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//   });

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   TextEditingController otpController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Enter your 6 Digit OTP',
//             style: AppFonts.titleRegular(),
//           ),
//           SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Pinput(
//               length: 6,
//               controller: otpController,
//               showCursor: true,
//               defaultPinTheme: PinTheme(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: AppColors.white,
//                     )),
//                 textStyle: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               minimumSize: Size(250, 50),
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//               backgroundColor: Theme.of(context).colorScheme.primary,
//             ),
//             onPressed: () async {
//               // if (otpController.text.isEmpty) {
//               //   AppUtil().showErrorDialog(context, 'OTP is required');
//               //   return;
//               // }
//               //
//               // final userProvider =
//               //     Provider.of<UserProvider>(context, listen: false);
//               // try {
//               //   await userProvider.verifyOtpAndProceed(
//               //     context: context,
//               //     otp: otpController.text,
//               //     verificationId: widget.verificationId,
//               //     phoneNumber: widget.phoneNumber,
//               //   );
//               //   AppUtil()
//               //       .showSuccessDialog(context, 'User verified successfully');
//               // } catch (e) {
//               //   AppUtil().showErrorDialog(context, 'Failed to verify OTP: $e');
//               // }
//             },
//             child: Text(
//               'VERIFY OTP',
//               style: AppFonts.titleBold().copyWith(
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ));
//   }
// }
