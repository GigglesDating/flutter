import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';

enum AadharStatus { verified, failed, inReview }

class AadharStatusScreen extends StatefulWidget {
  const AadharStatusScreen({super.key});

  @override
  State<AadharStatusScreen> createState() => _AadharStatusScreenState();
}

class _AadharStatusScreenState extends State<AadharStatusScreen> {
  late AadharStatus _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAadharStatus();
  }

  Future<void> _checkAadharStatus() async {
    // Simulating API call delay
    await Future.delayed(const Duration(seconds: 1));

    // For testing different scenarios, change this value:
    // AadharStatus.verified
    // AadharStatus.failed
    // AadharStatus.inReview
    setState(() {
      _status = AadharStatus.inReview; // Change this to test different states
      _isLoading = false;
    });

    // Later, this will be replaced with actual SharedPreferences check:
    // final prefs = await SharedPreferences.getInstance();
    // final status = prefs.getString('aadhar_status');
    // setState(() {
    //   _status = _getStatusFromString(status);
    //   _isLoading = false;
    // });
  }

  // This will be useful later when reading from SharedPreferences
  //AadharStatus _getStatusFromString(String? status) {
  //  switch (status) {
  //    case 'verified':
  //      return AadharStatus.verified;
  //    case 'failed':
  //      return AadharStatus.failed;
  //    case 'in_review':
  //      return AadharStatus.inReview;
  //    default:
  //      return AadharStatus.failed;
  //  }
  //}

  Widget _buildStatusIcon(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.25; // 25% of screen width

    switch (_status) {
      case AadharStatus.verified:
        return Icon(
          Icons.check_circle_outline,
          size: iconSize,
          color: Colors.green,
        );
      case AadharStatus.failed:
        return Icon(
          Icons.error_outline,
          size: iconSize,
          color: Colors.red,
        );
      case AadharStatus.inReview:
        return Icon(
          Icons.pending_outlined,
          size: iconSize,
          color: Colors.orange,
        );
    }
  }

  String _getStatusMessage() {
    switch (_status) {
      case AadharStatus.verified:
        return 'Your identity has been verified! Go ahead and personalize your profile.';
      case AadharStatus.failed:
        return 'Your Aadhar verification failed. Please try again.';
      case AadharStatus.inReview:
        return 'Your Aadhar verification needs manual review. Our support team will contact you soon.';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: ElevatedButton(
        onPressed: () {
          switch (_status) {
            case AadharStatus.verified:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileCreation1()),
              );
              break;
            case AadharStatus.failed:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const KycConsentScreen()),
              );
              break;
            case AadharStatus.inReview:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
              break;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _status == AadharStatus.verified
              ? Colors.green
              : _status == AadharStatus.failed
                  ? Colors.red
                  : Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.08,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 8 : 4),
          ),
        ),
        child: Text(
          _status == AadharStatus.verified
              ? 'Personalize Profile'
              : _status == AadharStatus.failed
                  ? 'Retry Verification'
                  : 'Contact Support',
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.05,
                  padding.top,
                  size.width * 0.05,
                  padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusIcon(context),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      'Aadhar Verification Status',
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      _getStatusMessage(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
    );
  }
}
