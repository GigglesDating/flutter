import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show pi;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../barrel.dart';

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedEventIndex;
  late AnimationController _expandController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _setupFadeAnimation();
    _setupStatusCheck();
    _fetchEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _setupFadeAnimation() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _setupStatusCheck() {
    _checkMemberStatus();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkMemberStatus();
    });
  }

  Future<void> _checkMemberStatus() async {
    if (_isCheckingStatus) return;
    _isCheckingStatus = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      if (uuid == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.checkMemberStatus(uuid: uuid);

      if (!mounted) return;

      if (response['status'] == 'success' &&
          response['data']['member'] == 'yes') {
        Navigator.of(context).pushReplacementNamed('/navigation');
      }
    } catch (e) {
      debugPrint('Error checking member status: $e');
    } finally {
      _isCheckingStatus = false;
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _precacheImages() async {
    if (!mounted) return;

    // Keep only the background image
    await precacheImage(
      const AssetImage('assets/tempImages/waitlist_bg.jpg'),
      context,
    );

    if (!mounted) return;

    // Precache network images from events
    if (_events.isNotEmpty) {
      await Future.wait([
        for (var event in _events)
          precacheImage(
            NetworkImage(event['image']),
            context,
          ),
      ]);
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final thinkProvider = ThinkProvider();
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');

      // Fetch events and liked events in parallel
      final results = await Future.wait([
        thinkProvider.getEvents(),
        if (uuid != null)
          thinkProvider.updateEventLike(uuid: uuid, action: 'check')
      ]);

      final eventsResponse = results[0];
      final likedEventsResponse = uuid != null ? results[1] : null;

      if (eventsResponse['status'] == 'success') {
        final eventsList =
            List<Map<String, dynamic>>.from(eventsResponse['data']);
        final likedEventIds = likedEventsResponse?['status'] == 'success'
            ? Set<String>.from(likedEventsResponse!['data']['liked_events'])
            : <String>{};

        final events = eventsList
            .map((event) {
              // Parse date string (e.g., "17-03-2025")
              final DateTime eventDate =
                  DateFormat('dd-MM-yyyy').parse(event['date']);

              // Parse time string and extract hour (e.g., "10:30:00" -> 10)
              final timeString = event['time'];
              final hour = int.parse(timeString.split(':')[0]);

              // Convert 24-hour format to 12-hour format with AM/PM
              final formattedHour =
                  hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
              final amPm = hour >= 12 ? 'PM' : 'AM';

              // Skip events in past or today
              if (eventDate.isBefore(DateTime.now())) {
                return null;
              }

              return {
                'name': event['event_name'],
                'type': event['sport'],
                'entries_left': event['entries_left'],
                'entries_total': event['entries_total'],
                'image': event['event_image'],
                'price': event['price'],
                'venue': event['venue'],
                'description': event['description'],
                'likes_count': event['likes_count'],
                'event_id': event['event_id'],
                'date': DateFormat('MMM dd').format(eventDate),
                'time': '$formattedHour $amPm',
                'isLiked': likedEventIds.contains(event['event_id']),
              };
            })
            .where((event) => event != null)
            .toList();

        if (mounted) {
          setState(() {
            _events = events.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        }
      } else {
        throw Exception(eventsResponse['message'] ?? 'Failed to fetch events');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _events = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'If you delete your account your waitlist number may increase the next time around.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                try {
                  // Get UUID from SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final uuid = prefs.getString('user_uuid');

                  if (uuid == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID not found')),
                    );
                    return;
                  }

                  final thinkProvider = ThinkProvider();
                  final response = await thinkProvider.deleteAccount(
                    uuid: uuid,
                  );

                  if (!mounted) return;

                  if (response['status'] == 'success') {
                    // Clear stored data
                    await prefs.remove('user_uuid');
                    await prefs.remove('reg_process');

                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            response['message'] ?? 'Failed to delete account'),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: $e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomMenu() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.edit_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Will implement Edit Profile navigation
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          'FAQs',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.support_agent_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          'Customer Support',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        onTap: () async {
                          if (!mounted) return;

                          try {
                            // Get UUID from SharedPreferences
                            final prefs = await SharedPreferences.getInstance();
                            final uuid = prefs.getString('user_uuid');

                            if (uuid == null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('User ID not found')),
                              );
                              return;
                            }

                            final thinkProvider = ThinkProvider();
                            final response = await thinkProvider.logout(
                              uuid: uuid,
                            );

                            if (!mounted) return;

                            if (response['status'] == 'success') {
                              // Clear stored data
                              await prefs.remove('user_uuid');
                              await prefs.remove('reg_process');

                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const SplashScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      response['message'] ?? 'Logout failed'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error during logout: $e')),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation();
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEventRegistration(int index) {
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedEventIndex == index) {
        _selectedEventIndex = null;
        _expandController.reverse();
      } else {
        _selectedEventIndex = index;
        _expandController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDarkMode ? const Color(0xFF121212) : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        body: Column(
          children: [
            Container(
              height: size.height * 0.28,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tempImages/waitlist_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    color: isDarkMode
                        ? Colors.black.withAlpha(180)
                        : Colors.white.withAlpha(180),
                  ),
                  SafeArea(
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '2154',
                                style: TextStyle(
                                  fontSize: size.width * 0.12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'waiting list',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WaitlistVideo(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? Colors.white.withAlpha(25)
                                        : Colors.black.withAlpha(25),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    size: size.width * 0.06,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 16,
                          child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 0, 0, 0),
                              size: size.width * 0.06,
                            ),
                            onPressed: () {
                              //         HapticFeedback.mediumImpact();
                              _showBottomMenu();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(
                    0,
                    _selectedEventIndex != null
                        ? 0 // Remove negative offset for expanded view
                        : -size.height *
                            0.045, // Keep original offset for waitlist view
                    0),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF121212) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: _selectedEventIndex != null
                    ? _buildExpandedEventView(_events[_selectedEventIndex!])
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                size.width * 0.06,
                                size.height * 0.01,
                                size.width * 0.06,
                                padding.bottom +
                                    (isIOS
                                        ? size.width * 0.08
                                        : size.width * 0.06),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'While you are waiting',
                                    style: TextStyle(
                                      fontSize: size.width * 0.07,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'Finding the one, but also the fun!',
                                    style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.015),
                                  Text(
                                    'Participate in one of our free online / offline fun competitions,'
                                    ' if you win, you can skip the waitlist instantly.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.50,
                              child: CarouselSlider.builder(
                                itemCount: _events.isEmpty ? 0 : _events.length,
                                options: CarouselOptions(
                                  height: size.height * 0.50,
                                  viewportFraction: 0.85,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  if (_events.isEmpty) return Container();
                                  final event = _events[index];
                                  return EventCard(
                                    event: event,
                                    onLike: () => _handleLike(index),
                                    onRegister: _handleEventRegistration,
                                    index: index,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedEventView(Map<String, dynamic> event) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (event['image'] == null) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(size.width * 0.08),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, child) {
        if (_rotationAnimation.value < pi / 2) {
          // First half of flip (original card)
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_rotationAnimation.value),
            child: Transform.translate(
              offset:
                  Offset(size.width * (_rotationAnimation.value / pi) * 0.2, 0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event['image']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.08),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size.width * 0.08),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.black.withAlpha(230),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.06,
                      size.width * 0.15, // Top padding for content
                      size.width * 0.06,
                      size.width * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Entries and Event Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entries Left',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                Text(
                                  "${event['entries_left']}/${event['entries_total']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  event['type'] ?? 'Talk Show',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                Text(
                                  event['name'] ?? 'The Exchange',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.08),

                        // Event Details (Date, Time, Venue)
                        _buildDetailRow('Date', event['date'] ?? '25th August'),
                        SizedBox(height: size.height * 0.08),
                        _buildDetailRow('Time', event['time'] ?? '05:00 PM'),
                        SizedBox(height: size.height * 0.08),

                        // Clickable Venue Row
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${event['venue'] ?? 'Koramangala'}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Venue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    event['venue'] ?? 'Koramangala',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.045,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: size.width * 0.05,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // Description
                        Text(
                          event['description'] ??
                              'Lorem ipsum dolor sit amet...',
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
                              width: size.width * 0.70,
                              height: size.height * 0.065,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.13),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (_selectedEventIndex != null) {
                                      HapticFeedback.mediumImpact();
                                      _handleEventRegistration(
                                          _selectedEventIndex!);
                                    }
                                  },
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.13),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.06),
                                        child: Text(
                                          'Unregister',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.042,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.height * 0.055,
                                        height: size.height * 0.055,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Like Button with Count
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      event['isLiked'] =
                                          !(event['isLiked'] ?? false);
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Icon(
                                    event['isLiked'] ?? false
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: event['isLiked'] ?? false
                                        ? Colors.red
                                        : Colors.white,
                                    size: size.width * 0.08,
                                  ),
                                ),
                                SizedBox(height: size.width * 0.01),
                                Text(
                                  '${event['likes_count'] ?? 312}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.035,
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
              ),
            ),
          );
        } else {
          // Second half of flip (expanded view)
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi - _rotationAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event['image']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.08),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size.width * 0.08),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.black.withAlpha(230),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Entries and Event Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entries Left',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                Text(
                                  "${event['entries_left']}/${event['entries_total']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  event['type'] ?? 'Talk Show',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                Text(
                                  event['name'] ?? 'The Exchange',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.08),

                        // Event Details (Date, Time, Venue)
                        _buildDetailRow('Date', event['date'] ?? '25th August'),
                        SizedBox(height: size.height * 0.08),
                        _buildDetailRow('Time', event['time'] ?? '05:00 PM'),
                        SizedBox(height: size.height * 0.08),

                        // Clickable Venue Row
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${event['venue'] ?? 'Koramangala'}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Venue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    event['venue'] ?? 'Koramangala',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.045,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: size.width * 0.05,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // Description
                        Text(
                          event['description'] ??
                              'Lorem ipsum dolor sit amet...',
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
                              width: size.width * 0.70,
                              height: size.height * 0.065,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.13),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (_selectedEventIndex != null) {
                                      HapticFeedback.mediumImpact();
                                      _handleEventRegistration(
                                          _selectedEventIndex!);
                                    }
                                  },
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.13),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.06),
                                        child: Text(
                                          'Unregister',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.042,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.height * 0.055,
                                        height: size.height * 0.055,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Like Button with Count
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      event['isLiked'] =
                                          !(event['isLiked'] ?? false);
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Icon(
                                    event['isLiked'] ?? false
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: event['isLiked'] ?? false
                                        ? Colors.red
                                        : Colors.white,
                                    size: size.width * 0.08,
                                  ),
                                ),
                                SizedBox(height: size.width * 0.01),
                                Text(
                                  '${event['likes_count'] ?? 312}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.035,
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
              ),
            ),
          );
        }
      },
    );
  }

  // Helper method for detail rows
  Widget _buildDetailRow(String label, String value) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.045,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.045,
          ),
        ),
      ],
    );
  }

  // Add this method for handling likes
  Future<void> _handleLike(int index) async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');
      if (uuid == null) return;

      final event = _events[index];
      final thinkProvider = ThinkProvider();

      final response = await thinkProvider.updateEventLike(
          uuid: uuid, eventId: event['event_id'], action: 'like');

      if (response['status'] == 'success') {
        if (mounted) {
          setState(() {
            _events[index]['isLiked'] = response['data']['is_liked'];
            _events[index]['likes_count'] = response['data']['likes_count'];
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to update like')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating like: $e')),
        );
      }
    }
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onLike;
  final Function(int) onRegister;
  final int index;

  const EventCard({
    super.key,
    required this.event,
    required this.onLike,
    required this.onRegister,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Event Image
            Image.network(
              event['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(size.width * 0.04), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section with entries and heart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entries Left',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.03,
                            ),
                          ),
                          Text(
                            "${event['entries_left']}/${event['entries_total']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: onLike,
                        icon: Icon(
                          event['isLiked']
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: event['isLiked'] ? Colors.red : Colors.white,
                          size: size.width * 0.06,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Event type
                  Text(
                    event['type'],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),

                  // Event name
                  Text(
                    event['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),

                  // Price section
                  Row(
                    children: [
                      Text(
                        '₹${event['price']}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width * 0.04,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          decorationThickness: 2,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        '₹0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),

                  // Pills row with horizontal scroll if needed
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPill(context, event['date']),
                        SizedBox(width: size.width * 0.02),
                        _buildPill(context, event['time']),
                        SizedBox(width: size.width * 0.02),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                          },
                          child: _buildPill(
                            context,
                            'Venue',
                            isClickable: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  // Register button
                  _buildRegisterButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(BuildContext context, String text,
      {bool isClickable = false}) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.008,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: isClickable ? Border.all(color: Colors.white30) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.035,
            ),
          ),
          if (isClickable) ...[
            SizedBox(width: size.width * 0.01),
            Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: size.width * 0.035,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(size.width * 0.06),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onRegister(index);
          },
          borderRadius: BorderRadius.circular(size.width * 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: size.width * 0.08,
                  height: size.width * 0.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(30),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: size.width * 0.05,
                    ),
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
