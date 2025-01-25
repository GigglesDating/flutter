import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/screens/barrel.dart';

//import '../../../constants/utils/show_dialog.dart';

String generateTransactionId() {
  final rnd = Random();
  final digits = '0123456789';

  String getRandomDigits(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => digits.codeUnitAt(rnd.nextInt(digits.length))));

  return 'Giggles-${getRandomDigits(12)}';
}

class AadharVerificationScreen extends StatefulWidget {
  const AadharVerificationScreen({super.key});

  @override
  State<AadharVerificationScreen> createState() =>
      _AadharVerificationScreenState();
}

class _AadharVerificationScreenState extends State<AadharVerificationScreen> {
  late final HyperKycConfig hyperKycConfig;

  @override
  void initState() {
    super.initState();
    hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
      appId: 'o811fk',
      appKey: '3ddhunl5z427du78rm10',
      workflowId: 'Aadhar_facematch',
      transactionId: generateTransactionId(),
    );
  }

  void startKYCProcess() async {
    try {
      HyperKycResult hyperKycResult =
          await HyperKyc.launch(hyperKycConfig: hyperKycConfig);
    } catch (error) {
      print("Error starting KYC process: $error");
    }
  }

  void handleKYCResult(HyperKycResult result) async {
    String? status = result.status?.value;
    final prefs = await SharedPreferences.getInstance();

    switch (status) {
      case 'auto_approved':
        await prefs.setString('aadhar_status', 'verified');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
          );
        }
        break;

      case 'auto_declined':
        await prefs.setString('aadhar_status', 'failed');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
          );
        }
        break;

      case 'needs_review':
        await prefs.setString('aadhar_status', 'inReview');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
          );
        }
        break;

      case 'error':
        await prefs.setString('aadhar_status', 'error');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
          );
        }
        break;

      case 'user_cancelled':
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitlistScreen()),
          );
        }
        break;

      default:
        await prefs.setString('aadhar_status', 'failed');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Aadhar Verification')),
    );
  }
}
