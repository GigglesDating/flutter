import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dotted_border/dotted_border.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<String> _getThemeBasedImages(bool isDarkMode) {
    final themeFolder = isDarkMode ? 'dark' : 'light';
    return [
      "assets/$themeFolder/subscription/1.png",
      "assets/$themeFolder/subscription/2.png",
      "assets/$themeFolder/subscription/3.png",
      "assets/$themeFolder/subscription/4.png",
      "assets/$themeFolder/subscription/5.png",
      "assets/$themeFolder/subscription/6.png",
    ];
  }

  void _shareAppInvite() {
    Share.share(
      'Join me on Giggles Dating! Download now: https://gigglesdating.com/invite',
      subject: 'Giggles Dating App Invite',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Get theme-specific images
    final activityImages = _getThemeBasedImages(isDarkMode);

    // Calculate safe area heights
    final safeAreaHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: safeAreaHeight * 0.02),

                // Improved carousel with full-width images
                CarouselSlider(
                  options: CarouselOptions(
                    height: safeAreaHeight * 0.3,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0, // Full width
                    onPageChanged: (index, reason) {
                      // Optional: Add page indicator update here
                    },
                  ),
                  items: activityImages.map((image) {
                    return Container(
                      width: size.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0), // Remove margin
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: safeAreaHeight * 0.04),

                // Membership Text
                Text(
                  "Claim your membership",
                  style: TextStyle(
                    color: Colors.orange[400],
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'CustomFont',
                  ),
                ),

                SizedBox(height: safeAreaHeight * 0.02),

                // Bold subtext
                Text(
                  "Everything the app has to offer\nunder 1 membership and no auto renewals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w700, // Made bold
                    fontFamily: 'CustomFont',
                  ),
                ),

                SizedBox(height: safeAreaHeight * 0.04),

                // Premium 3D membership card with dotted border
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(0.05), // Slight tilt
                  alignment: FractionalOffset.center,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(20),
                    color: Colors.orange[300]!,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.05),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.orange[50]!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "Save 40%",
                              style: TextStyle(
                                color: Colors.orange[400],
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: safeAreaHeight * 0.02),
                          Text(
                            "1 Month",
                            style: TextStyle(
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹4999",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Text(
                                "₹2543",
                                style: TextStyle(
                                  color: Colors.orange[400],
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: safeAreaHeight * 0.04),

                // Get Membership Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement payment gateway
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    minimumSize: Size(size.width * 0.8, size.width * 0.14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Get exclusive membership",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: safeAreaHeight * 0.02),

                // Updated Share button with options
                ElevatedButton(
                  onPressed: _shareAppInvite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: Size(size.width * 0.8, size.width * 0.14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Give it to a friend",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Icon(Icons.share, color: Colors.black87),
                    ],
                  ),
                ),

                SizedBox(height: safeAreaHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
