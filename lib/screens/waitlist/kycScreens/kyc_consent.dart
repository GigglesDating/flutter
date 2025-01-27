import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/network/think.dart';
import 'package:logger/logger.dart';

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
  final _logger = Logger();

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

        // Submit KYC data to backend using microtask
        Future.microtask(() async {
          try {
            final uuid = prefs.getString('uuid') ?? '';
            final kycJsonData = Map<String, dynamic>.from(result.details ?? {});

            final thinkProvider = ThinkProvider();
            final response = await thinkProvider.submitAadharInfo(
              uuid: uuid,
              kycData: kycJsonData,
            );

            if (response['status'] != 'success') {
              _logger.w('KYC data submission failed: ${response['message']}');
              await prefs.setString('aadhar_status', 'error');
            }
          } catch (e) {
            _logger.e('Error submitting KYC data', error: e);
            await prefs.setString('aadhar_status', 'error');
          }
        });
        break;

      case 'auto_declined':
        await prefs.setString('aadhar_status', 'failed');
        break;

      case 'needs_review':
        await prefs.setString('aadhar_status', 'inReview');
        break;

      case 'error':
        await prefs.setString('aadhar_status', 'error');
        break;

      case 'user_cancelled':
        if (!mounted) return;
        return showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Verification Cancelled'),
            content:
                const Text('Would you like to try again or contact support?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                },
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () async {
                  await prefs.setString('aadhar_status', 'failed');
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AadharStatusScreen()),
                  );
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        );

      default:
        await prefs.setString('aadhar_status', 'failed');
        break;
    }

    // Navigate to status screen for all cases except user_cancelled
    if (status != 'user_cancelled' && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AadharStatusScreen()),
      );
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
