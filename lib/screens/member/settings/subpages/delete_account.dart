import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Account',
        ),
        titleSpacing: 15,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Not using our service? Cancel subscription or deactivate account. If you\'re sure you want to delete, note that all data will be permanently deleted. Click one of the options below to confirm.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildActionButton(
                  context: context,
                  title: 'Cancel Subscription',
                  icon: Icons.cancel_outlined,
                  onTap: () => _showConfirmationDialog(
                    context,
                    'Cancel Subscription',
                    'Are you sure you want to cancel your subscription?',
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context: context,
                  title: 'Deactivate Your Account',
                  icon: Icons.pause_circle_outline,
                  onTap: () => _showConfirmationDialog(
                    context,
                    'Deactivate Account',
                    'Are you sure you want to deactivate your account? You can reactivate it later.',
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context: context,
                  title: 'Delete Your Account',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDestructive
            ? const Color.fromARGB(255, 218, 33, 67)
            : const Color.fromARGB(255, 152, 152, 154),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          message,
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle the action
              Navigator.pop(context);
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 82, 113, 255),
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This action cannot be undone. We will send an OTP to confirm your identity.',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showOtpVerification(context);
            },
            style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 176, 0, 32)),
            child: Text(
              'Send OTP',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color.fromARGB(255, 82, 113, 255)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpVerification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeleteAccountOtpSheet(),
    );
  }
}

class DeleteAccountOtpSheet extends StatefulWidget {
  const DeleteAccountOtpSheet({super.key});

  @override
  State<DeleteAccountOtpSheet> createState() => _DeleteAccountOtpSheetState();
}

class _DeleteAccountOtpSheetState extends State<DeleteAccountOtpSheet> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify Account Deletion',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  labelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 82, 113, 255))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 82, 113, 255))),
                  enabledBorder: const OutlineInputBorder(
                    // Border when enabled
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 82, 113, 255)),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 176, 0, 32)),
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
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color.fromARGB(255, 82, 113, 255)),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Handle account deletion
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 176, 0, 32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
