import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textScaler = MediaQuery.of(context).textScaler;

    // FAQ data structure
    final List<Map<String, String>> faqList = [
      {
        'question': 'Is my info secure ?',
        'answer':
            'Yes, your information is encrypted and securely stored. We follow strict privacy guidelines and never share your personal data with third parties.',
      },
      {
        'question': 'Can others see my details ?',
        'answer':
            'You control what others can see. Your personal information is private by default, and you can adjust your privacy settings at any time.',
      },
      {
        'question': 'How do I ensure safety ?',
        'answer':
            'We recommend verifying your profile, meeting in public places, and using our in-app communication features. Report any suspicious behavior immediately.',
      },
      {
        'question': 'How to register for events ?',
        'answer':
            "Browse available events, click on one you're interested in, and follow the registration process. You can manage your event registrations in your profile.",
      },
      {
        'question': 'How to delete my account',
        'answer':
            'Go to Settings > Account > Delete Account. Follow the prompts to permanently delete your account and data.',
      },
      {
        'question': 'How to delete my info ?',
        'answer':
            'You can manage and delete your information in Settings > Privacy > Data Management.',
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'FAQs',
                style: TextStyle(
                  fontSize: textScaler.scale(28),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              // Subtitle
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                  bottom: size.height * 0.03,
                ),
                child: Text(
                  'Find Answers to Your Common Questions and Get\nthe Information You Need',
                  style: TextStyle(
                    fontSize: textScaler.scale(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),

              // FAQ List
              ...faqList.map((faq) => _FAQItem(
                    question: faq['question']!,
                    answer: faq['answer']!,
                    isDarkMode: isDarkMode,
                  )),

              // Contact Support Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement contact support
                    },
                    child: Text(
                      'Contact support',
                      style: TextStyle(
                        fontSize: textScaler.scale(16),
                        decoration: TextDecoration.underline,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDarkMode;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isDarkMode,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: textScaler.scale(16),
                      fontWeight: FontWeight.w500,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: EdgeInsets.only(
              bottom: size.height * 0.015,
              right: size.width * 0.1,
            ),
            child: Text(
              widget.answer,
              style: TextStyle(
                fontSize: textScaler.scale(14),
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        Divider(
          color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
          height: 1,
        ),
      ],
    );
  }
}
