import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/appColors.dart';
import '../../constants/appFonts.dart';

class LoginInfoScreen extends StatelessWidget {
  const LoginInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login Info',
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: AppFonts.appBarTitle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        children: [
          // Phone Number Container
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: AppFonts.titleMedium(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '9007848474',
                        style: AppFonts.titleBold(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _showEditPhoneBottomSheet(context);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Edit',
                          style: AppFonts.titleBold(
                              color: AppColors.primary, fontSize: 15),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.edit, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditPhoneBottomSheet(),
    );
  }
}

class EditPhoneBottomSheet extends StatefulWidget {
  const EditPhoneBottomSheet({super.key});

  @override
  State<EditPhoneBottomSheet> createState() => _EditPhoneBottomSheetState();
}

class _EditPhoneBottomSheetState extends State<EditPhoneBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpField = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleOtpVerification() {
    if (_otpController.text.length == 6) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Phone number updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Phone Number',
            style: AppFonts.titleBold(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            style: AppFonts.hintTitle(
                color:
                Theme.of(context).colorScheme.tertiary),
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: '+91| xxxxx xxxxx',
              labelStyle: AppFonts.hintTitle(
                  color:
                  Theme.of(context).colorScheme.tertiary),
              counterText: '',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary)),
              enabledBorder: const OutlineInputBorder(
                // Border when enabled
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
          ),
          if (_showOtpField) ...[
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: AppFonts.hintTitle(
                      color: Theme.of(context).colorScheme.tertiary),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    labelStyle: AppFonts.hintTitle(
                        color: Theme.of(context).colorScheme.tertiary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppColors.primary)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppColors.primary)),
                    enabledBorder: const OutlineInputBorder(
                      // Border when enabled
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: TextButton(
                    onPressed: () {
                      // Handle resend OTP
                    },
                    child: Text(
                      'Resend',
                      style: AppFonts.titleBold(
                          color: AppColors.primary, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
          ElevatedButton(
            onPressed: () {
              if (!_showOtpField) {
                setState(() {
                  _showOtpField = true;
                });
              } else {
                _handleOtpVerification();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _showOtpField ? 'Verify' : 'Send OTP',
              style: AppFonts.titleBold(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
