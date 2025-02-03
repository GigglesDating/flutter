// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class PaymentsProvider {
//   static Future<void> initializeRazorpay() async {
//     try {
//       Razorpay razorpay = Razorpay();
//       razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//       razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//       razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//       await razorpay.open(options);
//     } catch (e) {
//       print("Error initializing Razorpay: $e");
//     }
//   }

//   static void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     Fluttertoast.showToast(msg: "Payment successful");
//   }

//   static void _handlePaymentError(PaymentFailureResponse response) {
//     Fluttertoast.showToast(msg: "Payment failed");
//   }

//   static void _handleExternalWallet(ExternalWalletResponse response) {
//     Fluttertoast.showToast(msg: "External wallet selected");
//   }
// }
