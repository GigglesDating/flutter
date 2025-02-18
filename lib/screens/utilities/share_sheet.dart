import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareSheet extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, dynamic> post;
  final double screenWidth;

  const ShareSheet({
    super.key,
    required this.isDarkMode,
    required this.post,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withAlpha(240)
                  : Colors.white.withAlpha(240),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withAlpha(38)
                    : Colors.black.withAlpha(26),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                    width: screenWidth * 0.1,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withAlpha(77)
                          : Colors.black.withAlpha(77),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Share to',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      context,
                      icon: Icons.message_outlined,
                      label: 'Message',
                      onTap: () {
                        // TODO: Implement in-app messaging
                        Navigator.pop(context);
                      },
                    ),
                    _buildShareOption(
                      context,
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      onTap: () {
                        // TODO: Implement WhatsApp sharing
                        Navigator.pop(context);
                      },
                    ),
                    _buildShareOption(
                      context,
                      icon: Icons.link_rounded,
                      label: 'Copy Link',
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text: 'https://yourapp.com/post/${post['id']}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black,
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}
