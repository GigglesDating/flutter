import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KycConsentScreen extends StatefulWidget {
  const KycConsentScreen({super.key});

  @override
  State<KycConsentScreen> createState() => _KycConsentScreenState();
}

class _KycConsentScreenState extends State<KycConsentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isLoading = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String generateTransactionId() {
    final rnd = Random();
    final digits = '0123456789';

    String getRandomDigits(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => digits.codeUnitAt(rnd.nextInt(digits.length))));

    return 'Giggles-${getRandomDigits(12)}';
  }

  Future<void> handleKYCResult(HyperKycResult result) async {
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Verification Cancelled'),
              content: Text('Would you like to try again or contact support?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text('Try Again'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement support contact
                    Navigator.pop(context);
                  },
                  child: Text('Contact Support'),
                ),
              ],
            ),
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

  Future<void> startKYCProcess() async {
    setState(() => _isLoading = true);

    try {
      final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
        appId: 'o811fk',
        appKey: '3ddhunl5z427du78rm10',
        workflowId: 'Aadhar_facematch',
        transactionId: generateTransactionId(),
      );

      final hyperKycResult =
          await HyperKyc.launch(hyperKycConfig: hyperKycConfig);
      await handleKYCResult(hyperKycResult);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting verification: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Header Image
              Hero(
                tag: 'verify_icon',
                child: RotationTransition(
                  turns: _animationController,
                  child: Image.asset(
                    'assets/tempImages/kyc_consent_bg.png',
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Header Text
              Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.03),

              // Description Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  'At Giggles, we ask all members to verify their profiles with Aadhar to keep our community safe and authentic. Only your masked aadhar is fetched via govt approved DigiLocker api.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.06),

              // Verify Button
              SizedBox(
                width: size.width * 0.8, // 80% of screen width
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
                  child: Semantics(
                    label: 'Verify identity with Aadhar',
                    hint: 'Double tap to start verification process',
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isPressed = true);
                              HapticFeedback.mediumImpact();
                              await startKYCProcess();
                              if (mounted) {
                                setState(() => _isPressed = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: size.width * 0.05,
                              width: size.width * 0.05,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
