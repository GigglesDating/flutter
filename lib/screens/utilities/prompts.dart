import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../barrel.dart';

class PromptsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const PromptsScreen({
    required this.profile,
    super.key,
  });

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  final List<String> _conversationStarters = [
    "Just coffee? let's try Tiramisu",
    "We should definitely hangout",
    "Seeing your profile for the 3rd time"
  ];

  List<Offset> _tilePlacements = [];
  final TextEditingController _messageController = TextEditingController();
  final Random _random = Random();

  // Add these constants at the top of the class
  final double tileWidth = 130.0;
  final double tileHeight = 170.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTilePlacements();
    });
  }

  void _initializeTilePlacements() {
    final size = MediaQuery.of(context).size;

    // Define safe area boundaries
    final backButtonSafeArea = size.width * 0.15;
    final topSafeArea = size.height * 0.08;
    final maxHeight = size.height * 0.35; // Restrict to above location text

    // Calculate boundaries for tile placement
    final leftBoundary = backButtonSafeArea;
    final rightBoundary = size.width - tileWidth;
    final topBoundary = topSafeArea;
    final bottomBoundary = maxHeight - tileHeight;

    setState(() {
      _tilePlacements = List.generate(
        widget.profile['images'].length,
        (index) => Offset(
          leftBoundary + _random.nextDouble() * (rightBoundary - leftBoundary),
          topBoundary + _random.nextDouble() * (bottomBoundary - topBoundary),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Back Button
          Positioned(
            top: size.height * 0.02,
            left: size.width * 0.04,
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? Colors.white.withAlpha(51)
                      : Colors.black.withAlpha(26),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ),

          // Report Button
          Positioned(
            top: size.height * 0.02,
            right: size.width * 0.04,
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? Colors.white.withAlpha(51)
                      : Colors.black.withAlpha(26),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => UserReportSheet(
                    isDarkMode: isDarkMode,
                    screenWidth: size.width,
                    onReportComplete: _handleReportComplete,
                  ),
                );
              },
            ),
          ),

          // Profile Info (Moved higher)
          Positioned(
            top: size.height * 0.35, // Adjust this percentage as needed
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.04,
              ),
              child: Column(
                children: [
                  // Name and Age
                  Center(
                    child: Text(
                      "${widget.profile['name']}, ${widget.profile['age']}",
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Location
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: size.width * 0.04,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          widget.profile['location'],
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prompts Section (Moved higher)
          Positioned(
            bottom: size.height * 0.1, // Adjust this percentage as needed
            child: Container(
              width: size.width,
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Spark",
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  ..._conversationStarters
                      .map((starter) => _buildPromptButton(starter)),
                  _buildCustomMessageInput(),
                ],
              ),
            ),
          ),

          // Draggable Image Tiles (using swipe.dart implementation)
          ..._buildImageTiles(),
        ],
      ),
    );
  }

  List<Widget> _buildImageTiles() {
    return List.generate(
      widget.profile['images'].length,
      (index) => Positioned(
        left: _tilePlacements[index].dx,
        top: _tilePlacements[index].dy,
        child: Draggable(
          feedback: Container(
            width: tileWidth,
            height: tileHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(widget.profile['images'][index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Container(
              width: tileWidth,
              height: tileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(widget.profile['images'][index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          onDragEnd: (details) {
            setState(() {
              _tilePlacements[index] = Offset(
                details.offset.dx,
                details.offset.dy - MediaQuery.of(context).padding.top,
              );
            });
          },
          child: Container(
            width: tileWidth,
            height: tileHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(widget.profile['images'][index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptButton(String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // TODO: Implement API call to send prompt
        Navigator.pop(
            context, true); // true indicates we should load next profile
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMessageInput() {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withAlpha(230)
                        : Colors.white.withAlpha(230),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withAlpha(51)
                          : Colors.black.withAlpha(51),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: size.width * 0.15,
                        height: 4,
                        margin: EdgeInsets.only(bottom: size.width * 0.04),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withAlpha(38)
                              : Colors.black.withAlpha(26),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      TextField(
                        controller: _messageController,
                        autofocus: true, // This will open keyboard immediately
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your own message...',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withAlpha(128)
                                : Colors.black.withAlpha(128),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (value) {
                          Navigator.pop(context);
                          Navigator.pop(context); // Return to previous screen
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Write your own message...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to handle report completion
  void _handleReportComplete() {
    // Pop twice to go back to swipe screen
    Navigator.pop(context); // Close report sheet
    Navigator.pop(context); // Close prompts screen
    Navigator.pop(context); // Pop the current profile in swipe screen
  }
}
