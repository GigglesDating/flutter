import 'package:flutter_frontend/network/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../barrel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phoneNumber = '';
  String _otp = '';
  String? _requestId;
  String? _regProcess;
  bool _isPressed = false;
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _errorMessage;
  bool _canResendOtp = false;
  int _resendTimer = 30;
  final TextEditingController _inputController = TextEditingController();

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResendOtp = false;
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  Future requestOtp() async {
    if (_phoneNumber.length != 10) {
      setState(
        () {
          _errorMessage = 'Please enter a valid 10-digit phone number';
        },
      );
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
      _inputController.clear();
      _startResendTimer();
    });
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a valid 4-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final response = await authProvider.verifyOtp(
        phoneNumber: '+91$_phoneNumber',
        otp: _otp,
        requestId: _requestId!,
      );

      if (!mounted) return;

      if (response['status'] == true || response['success'] == true) {
        setState(() {
          _isLoading = false;
        });

        // Navigate based on registration process status
        if (mounted) {
          // If reg_process is null or not in response, navigate to IntroVideo
          if (response['reg_process'] == null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => SignupScreen(),
              ),
              (route) => false,
            );
            return;
          }

          // Store the registration process status
          _regProcess = response['reg_process'].toString();

          switch (_regProcess) {
            case 'new_user':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => SignupScreen(),
                ),
                (route) => false,
              );
              break;

            case 'reg_started':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AadharStatusScreen(),
                ),
                (route) => false,
              );
              break;

            case 'aadhar_failed':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AadharStatusScreen(),
                ),
                (route) => false,
              );
              break;

            case 'aadhar_successful':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ProfileCreation1(),
                ),
                (route) => false,
              );
              break;

            case 'profile_creation2':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ProfileCreation2(),
                ),
                (route) => false,
              );
              break;

            case 'profile_creation3':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ProfileCreation3(),
                ),
                (route) => false,
              );
              break;

            case 'waitlisted':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const WaitlistScreen(),
                ),
                (route) => false,
              );
              break;

            default:
              // If reg_process is unknown, also start from beginning
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => SplashScreen(),
                ),
                (route) => false,
              );
              break;
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              response['message'] ?? response['error'] ?? 'Invalid OTP';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to verify OTP';
      });
    }
  }

  void _showEditNumberSheet() {
    String tempNumber = _phoneNumber;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              controller: TextEditingController(text: tempNumber),
              onChanged: (value) => tempNumber = value,
              decoration: InputDecoration(
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (tempNumber.length == 10) {
                  Navigator.pop(context);
                  setState(() {
                    _phoneNumber = tempNumber;
                    _isOtpSent = false;
                    _otp = '';
                    _inputController.clear();
                  });

                  // Call requestOtp API with new number
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  final response = await authProvider.requestOtp(
                    phoneNumber: _phoneNumber,
                  );

                  if (!mounted) return;

                  if (response['status'] == true ||
                      response['success'] == true ||
                      response['requestId'] != null) {
                    setState(() {
                      _isLoading = false;
                      _isOtpSent = true;
                      _requestId = response['requestId'];
                      _otp = '';
                      _inputController.clear();
                      _startResendTimer();
                    });
                  } else {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = response['message'] ??
                          response['error'] ??
                          'Failed to send OTP';
                    });
                  }
                }
              },
              child: const Text('Update & Request OTP'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final logoSize = size.width * 0.4;
    final minLogoSize = 160.0;
    final maxLogoSize = 240.0;

    final adaptiveLogoSize = logoSize.clamp(minLogoSize, maxLogoSize);

    final topPadding = padding.top + (size.height * 0.20);

    final authProvider = Provider.of<AuthProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight =
            constraints.maxHeight - padding.top - padding.bottom;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Image.asset(
                  isDarkMode
                      ? 'assets/light/bgs/loginbg.png'
                      : 'assets/dark/bgs/loginbg.png',
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * 0.06,
                        right: size.width * 0.06,
                        top: topPadding,
                        bottom: bottomInset + 24,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(0,
                            bottomInset > 0 ? -availableHeight * 0.15 : 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: adaptiveLogoSize,
                                height: adaptiveLogoSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDarkMode
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    isDarkMode
                                        ? 'assets/light/favicon.png'
                                        : 'assets/dark/favicon.png',
                                    width: adaptiveLogoSize * 0.75,
                                    height: adaptiveLogoSize * 0.75,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: availableHeight * 0.25),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                minHeight: 50,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(26),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (!_isOtpSent)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        '+91',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: TextField(
                                      controller: _inputController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(
                                            _isOtpSent ? 4 : 10),
                                      ],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          if (_isOtpSent) {
                                            _otp = value;
                                          } else {
                                            _phoneNumber = value;
                                          }
                                          _errorMessage = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            _isOtpSent ? 'Enter OTP' : 'Phone',
                                        hintStyle: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 15,
                                        ),
                                        suffixIcon: _isOtpSent
                                            ? TextButton(
                                                onPressed: _canResendOtp
                                                    ? () async {
                                                        // Call requestOtp API when resend is pressed
                                                        final authProvider =
                                                            Provider.of<
                                                                    AuthProvider>(
                                                                context,
                                                                listen: false);

                                                        setState(() {
                                                          _isLoading = true;
                                                          _errorMessage = null;
                                                        });

                                                        final response =
                                                            await authProvider
                                                                .requestOtp(
                                                          phoneNumber:
                                                              _phoneNumber,
                                                        );

                                                        if (!mounted) return;

                                                        if (response['status'] == true ||
                                                            response[
                                                                    'success'] ==
                                                                true ||
                                                            response[
                                                                    'requestId'] !=
                                                                null) {
                                                          setState(() {
                                                            _isLoading = false;
                                                            _requestId =
                                                                response[
                                                                    'requestId'];
                                                            _otp = '';
                                                            _inputController
                                                                .clear();
                                                            _startResendTimer();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            _isLoading = false;
                                                            _errorMessage = response[
                                                                    'message'] ??
                                                                response[
                                                                    'error'] ??
                                                                'Failed to send OTP';
                                                          });
                                                        }
                                                      }
                                                    : null,
                                                child: Text(
                                                  _canResendOtp
                                                      ? 'Resend OTP'
                                                      : 'Resend in ${_resendTimer}s',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            : _phoneNumber.length == 10
                                                ? const Icon(Icons.check_circle,
                                                    color: Colors.green)
                                                : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_errorMessage != null)
                              AnimatedSlide(
                                duration: const Duration(milliseconds: 300),
                                offset:
                                    Offset(0, _errorMessage == null ? 1 : 0),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red[400]),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Container(
                              width: size.width * 0.4,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(26),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTapDown: (_) =>
                                      setState(() => _isPressed = true),
                                  onTapUp: (_) =>
                                      setState(() => _isPressed = false),
                                  onTapCancel: () =>
                                      setState(() => _isPressed = false),
                                  onTap: _isLoading
                                      ? null
                                      : () async {
                                          if (_isOtpSent) {
                                            if (_otp.length == 4) {
                                              await _verifyOtp();
                                            } else {
                                              setState(() {
                                                _errorMessage =
                                                    'Please enter a valid 4-digit OTP';
                                              });
                                            }
                                          } else {
                                            if (_phoneNumber.length == 10) {
                                              setState(() {
                                                _isLoading = true;
                                                _errorMessage = null;
                                              });

                                              final response =
                                                  await authProvider.requestOtp(
                                                phoneNumber: _phoneNumber,
                                              );

                                              if (!mounted) return;

                                              if (response['status'] == true ||
                                                  response['success'] == true ||
                                                  response['requestId'] !=
                                                      null) {
                                                setState(() {
                                                  _isLoading = false;
                                                  _isOtpSent = true;
                                                  _requestId =
                                                      response['requestId'];
                                                  _otp = '';
                                                  _inputController.clear();
                                                  _startResendTimer();
                                                });
                                              } else {
                                                setState(() {
                                                  _isLoading = false;
                                                  _errorMessage =
                                                      response['message'] ??
                                                          response['error'] ??
                                                          'Failed to send OTP';
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                _errorMessage =
                                                    'Please enter a valid 10-digit phone number';
                                              });
                                            }
                                          }
                                        },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(_isPressed ? 0.98 : 1.0),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            )
                                          : Text(
                                              _isOtpSent ? 'Submit' : 'Get OTP',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isOtpSent)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextButton(
                                  onPressed: _showEditNumberSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(140),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Wrong number? $_phoneNumber',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
