import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AadharStatus { verified, failed, inReview, error }

class AadharStatusScreen extends StatefulWidget {
  const AadharStatusScreen({super.key});

  @override
  State<AadharStatusScreen> createState() => _AadharStatusScreenState();
}

class _AadharStatusScreenState extends State<AadharStatusScreen> {
  late AadharStatus _status;
  bool _isLoading = true;
  bool _hasContactedSupport = false;

  @override
  void initState() {
    super.initState();
    _checkAadharStatus();
  }

  Future<void> _checkAadharStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('aadhar_status');

    setState(() {
      switch (status) {
        case 'verified':
          _status = AadharStatus.verified;
          break;
        case 'failed':
          _status = AadharStatus.failed;
          break;
        case 'inReview':
          _status = AadharStatus.inReview;
          break;
        case 'error':
          _status = AadharStatus.error;
          break;
        default:
          _status = AadharStatus.error;
      }
      _isLoading = false;
    });
  }

  Widget _buildStatusIcon(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.25;

    switch (_status) {
      case AadharStatus.verified:
        return Icon(Icons.check_circle_outline,
            size: iconSize, color: Colors.green);
      case AadharStatus.failed:
        return Icon(Icons.error_outline, size: iconSize, color: Colors.red);
      case AadharStatus.inReview:
        return Icon(Icons.pending_outlined,
            size: iconSize, color: Colors.orange);
      case AadharStatus.error:
        return Icon(Icons.warning_amber_rounded,
            size: iconSize, color: Colors.red);
    }
  }

  String _getStatusMessage() {
    switch (_status) {
      case AadharStatus.verified:
        return 'Your identity has been verified successfully! You can now proceed to create your profile.';
      case AadharStatus.failed:
        return 'We couldn\'t verify your Aadhar. Please try again with clear documents.';
      case AadharStatus.inReview:
        return 'Your verification is under review. Our team will process it shortly.';
      case AadharStatus.error:
        return 'Sorry, something unexpected happened. Please try again or contact support.';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (_status == AadharStatus.error) {
      return Column(
        children: [
          SizedBox(
            width: size.width * 0.8,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const KycConsentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
                ),
                elevation: 0,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            width: size.width * 0.8,
            child: ElevatedButton(
              onPressed: _hasContactedSupport
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SupportScreen()),
                      );
                      setState(() => _hasContactedSupport = true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                _hasContactedSupport ? 'Support Contacted' : 'Contact Support',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildSingleActionButton(context);
  }

  Widget _buildSingleActionButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return SizedBox(
      width: size.width * 0.8,
      child: ElevatedButton(
        onPressed: () => _handleButtonPress(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
          ),
          elevation: 0,
        ),
        child: Text(
          _getButtonText(),
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_status) {
      case AadharStatus.verified:
        return 'Create Profile';
      case AadharStatus.failed:
        return 'Try Again';
      case AadharStatus.inReview:
        return 'Contact Support';
      case AadharStatus.error:
        return 'Try Again';
    }
  }

  void _handleButtonPress() {
    switch (_status) {
      case AadharStatus.verified:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileCreation1()),
        );
        break;
      case AadharStatus.failed:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KycConsentScreen()),
        );
        break;
      case AadharStatus.inReview:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupportScreen()),
        );
        break;
      case AadharStatus.error:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KycConsentScreen()),
        );
        break;
    }
  }

  Color _getButtonColor() {
    switch (_status) {
      case AadharStatus.verified:
        return Colors.green;
      case AadharStatus.failed:
      case AadharStatus.error:
        return Colors.red;
      case AadharStatus.inReview:
        return Colors.orange;
    }
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
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
    );
  }
}
