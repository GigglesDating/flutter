import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Background Image with Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.event['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(77),
                    Colors.black.withAlpha(230),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Top Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entries Left',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.event['entries'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.event['type'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.event['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Date and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      Text(
                        widget.event['date'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      Text(
                        widget.event['time'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Venue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Venue',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement maps navigation
                        },
                        child: Row(
                          children: [
                            Text(
                              widget.event['venue'] ?? 'TBA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: size.width * 0.01),
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: size.width * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Description
                  Text(
                    widget.event['description'] ?? 'No description available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Unregister Button
                      Container(
                        width: size.width * 0.4,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius:
                              BorderRadius.circular(size.width * 0.08),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius:
                                BorderRadius.circular(size.width * 0.08),
                            child: Center(
                              child: Text(
                                'Unregister',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Like Button and Count
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                widget.event['isLiked'] =
                                    !widget.event['isLiked'];
                              });
                              HapticFeedback.selectionClick();
                            },
                            icon: Icon(
                              widget.event['isLiked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.event['isLiked']
                                  ? Colors.red
                                  : Colors.white,
                              size: size.width * 0.06,
                            ),
                          ),
                          Text(
                            '${widget.event['likes'] ?? 0}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
