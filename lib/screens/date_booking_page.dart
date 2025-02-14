import 'package:flutter/material.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:flutter_svg/svg.dart';

class DateBookingPage extends StatefulWidget {
  const DateBookingPage({Key? key}) : super(key: key);

  @override
  State<DateBookingPage> createState() => _DateBookingPage();
}

class _DateBookingPage extends State<DateBookingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Date Booking'),
          titleSpacing: 0,
          titleTextStyle: AppFonts.titleBold(
              fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.black,
              ),
            ),
            Text('Schedule  a date'),
            SizedBox(
              height: kToolbarHeight,
            ),
            Container(
              // padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromARGB(255, 241, 242, 242)
                    : const Color.fromARGB(255, 188, 188, 188),
                // Background color for entire tab section
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: TabBar(
                dividerHeight: 0,
                physics: const NeverScrollableScrollPhysics(),
                // labelPadding: EdgeInsets.all(0),
                isScrollable: false,
                // textScaler: TextScaler.noScaling,
                indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                labelStyle: AppFonts.titleBold(
                  fontSize: 18,
                ),
                unselectedLabelStyle: AppFonts.titleBold(
                  fontSize: 18,
                ),
                labelColor:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: "Upcoming Dates"),
                  Tab(text: "Date History"),
                ],
              ),
            ),
            SizedBox(height: 16,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBarView(children: [
                  Container(
                    height: MediaQuery.of(context).size.width / 1,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two images per row
                        childAspectRatio: 0.4, // Aspect ratio for images
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: 8,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          // Open image picker on tap
                          child: Stack(
                            children: [
                              // Display selected image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/date_booking_image.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Checkmark overlay when an image is selected

                              Positioned(
                                top: 16,

                                right: 10,
                                child: Row(
                                  children: [
                                    Center(
                                        child: Text(
                                      'Sanskriti',
                                      style: AppFonts.titleBold(
                                          color: Colors.black, fontSize: 16),
                                    )),
                                    SizedBox(width: 4,),
                                    const Icon(Icons.info_outline,size: 24,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width / 1,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two images per row
                        childAspectRatio: .8, // Aspect ratio for images
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: 8,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          // Open image picker on tap
                          child: Stack(
                            children: [
                              // Display selected image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/liked_you image.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Checkmark overlay when an image is selected

                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Center(
                                    child: Text(
                                  'Aditi Rao',
                                  style: AppFonts.titleBold(
                                      color: Colors.white, fontSize: 18),
                                )),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String imageUrl;
  final List<String> socialIcons;
  final String label;

  const ProfileCard({
    required this.imageUrl,
    required this.socialIcons,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.width / 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Octagon Shape with Profile Image
          ClipPath(
            clipper: OctagonClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 2,
              color: const Color.fromARGB(255, 148, 177, 67), // Border color
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ClipPath(
                  clipper: OctagonClipper(),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
          ),
          // Social Media Icons
          Positioned(
            left: 8,
            top: kToolbarHeight - 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: socialIcons
                  .map((icon) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: SvgPicture.asset(
                          icon,
                          width: 18,
                          height: 18,
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Arrow Icon
          Positioned(
            right: 8,
            top: kToolbarHeight + kToolbarHeight,
            child: Image.asset(
              color: Colors.white,
              'assets/images/right_swipe_image.png',
              width: 36,
              height: 18,
            ),
          ),
          Positioned(
            left: 8,
            top: kToolbarHeight + kToolbarHeight,
            child: Image.asset(
              color: Colors.white,
              'assets/images/left_swipe_image.png',
              width: 36,
              height: 18,
            ),
          ),
          Positioned(
            right: 8,
            top: 36,
            child: Icon(
              Icons.info_outline,
              color: const Color.fromARGB(255, 102, 179, 230),
              size: 18,
            ),
          ),
          // Optional Label
          if (label.isNotEmpty)
            Positioned(
              bottom: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  label,
                  style: AppFonts.titleMedium(
                      fontSize: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom ClipPath for Octagon
class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final factor = 0.2; // Adjust for desired octagon proportions

    path.moveTo(w * factor, 0);
    path.lineTo(w * (1 - factor), 0);
    path.lineTo(w, h * factor);
    path.lineTo(w, h * (1 - factor));
    path.lineTo(w * (1 - factor), h);
    path.lineTo(w * factor, h);
    path.lineTo(0, h * (1 - factor));
    path.lineTo(0, h * factor);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}