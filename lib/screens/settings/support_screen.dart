import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import '../../constants/appFonts.dart';
import 'support_chat_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support',
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: AppFonts.appBarTitle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FAQs Title and Description
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAQs',
                  style: AppFonts.titleBold(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find answers to commonly asked questions',
                  style: AppFonts.titleMedium(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // FAQ Items in Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFAQItem(
                    'Can I delete my profile?',
                    'Yes, you can delete your profile through Account Settings > Delete Account. Please note that this action is permanent and cannot be undone.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'How do I report someone?',
                    'To report a user, visit their profile, tap the menu icon (three dots), and select "Report." Follow the prompts to submit your report.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'Can I block someone?',
                    'Yes, you can block a user by visiting their profile, tapping the menu icon (three dots), and selecting "Block." This will prevent them from contacting you.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'How do I change my profile picture?',
                    'To change your profile picture, go to Account Settings > Personal Details and tap on your current profile picture.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'What should I do if I need help?',
                    'If you need assistance, you can contact our support team using the button below. We\'re here to help!',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Contact Support Button (Fixed at bottom)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportChatScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppFonts.titleBold(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: AppFonts.titleMedium(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
