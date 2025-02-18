import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends State<NotificationsPage> {
  final List<String> userProfile = [
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 22,
              ),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.15,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                itemCount: userProfile.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left:
                          index == 0 ? screenWidth * 0.02 : screenWidth * 0.04,
                      right: index == userProfile.length - 1
                          ? screenWidth * 0.04
                          : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to profile
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white.withAlpha(38)
                                    : Colors.black.withAlpha(26),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(userProfile[index]),
                              radius: screenWidth * 0.1,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            'Natuan',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Divider(
                thickness: 1,
                color: isDarkMode
                    ? Colors.white.withAlpha(38)
                    : Colors.black.withAlpha(26),
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            _buildNotificationSection(
                'Today', userProfile, isDarkMode, screenWidth),
            SizedBox(height: screenWidth * 0.03),
            _buildNotificationSection('Yesterday', userProfile.sublist(0, 3),
                isDarkMode, screenWidth),
            SizedBox(height: screenWidth * 0.06),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
      String title, List<String> items, bool isDarkMode, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _buildNotificationItem(items[index], isDarkMode, screenWidth),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
      String profileImage, bool isDarkMode, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to profile
        },
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withAlpha(38)
                      : Colors.black.withAlpha(26),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage(profileImage),
                radius: screenWidth * 0.075,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@Natuan Express',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                Text(
                  'Interest • 2h',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withAlpha(204)
                        : Colors.black.withAlpha(204),
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
