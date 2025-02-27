import 'dart:ui';
import 'package:flutter/material.dart';

class ContentReportSheet extends StatelessWidget {
  final bool isDarkMode;
  final double screenWidth;
  final VoidCallback? onReportComplete;

  const ContentReportSheet({
    required this.isDarkMode,
    required this.screenWidth,
    this.onReportComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withAlpha(50)
                  : Colors.white.withAlpha(50),
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
                // Report options
                ListTile(
                  onTap: () {
                    // TODO: Implement report API call here
                    if (onReportComplete != null) {
                      onReportComplete!();
                    }
                    Navigator.pop(context);
                  },
                  title: Text(
                    'Report User',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: Icon(
                    Icons.report_problem,
                    color: Colors.red,
                  ),
                ),
                ListTile(
                  onTap: () {
                    // TODO: Implement block API call here
                    if (onReportComplete != null) {
                      onReportComplete!();
                    }
                    Navigator.pop(context);
                  },
                  title: Text(
                    'Block User',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: Icon(
                    Icons.block,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
