import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show pi;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../network/auth_provider.dart';
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
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  final Set<String> _likedEvents = {};

  @override
  void initState() {
    super.initState();
    _precacheImages();
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
    _checkLikedEvents();
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

    await precacheImage(
      const AssetImage(
          'assets/tempImages/waitlist_bg.jpg'), // Keep only background
      context,
    );

    if (!mounted) return;

    // Precache network images from events
    if (_events.isNotEmpty) {
      await Future.wait([
        for (var event in _events)
          precacheImage(
            NetworkImage(event['event_image']),
            context,
          ),
      ]);
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getEvents();

      if (response['status'] == 'success') {
        setState(() {
          _events = List<Map<String, dynamic>>.from(response['data']['events']);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  Future<void> _checkLikedEvents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uuid = authProvider.uuid;
      if (uuid == null) return;

      final thinkProvider = ThinkProvider();
      final response =
          await thinkProvider.updateEventLike(uuid: uuid, action: 'check');

      if (response['status'] == 'success') {
        setState(() {
          _likedEvents
              .addAll(Set<String>.from(response['data']['liked_events']));
        });
      }
    } catch (e) {
      debugPrint('Error checking liked events: $e');
    }
  }

  Future<void> _toggleLike(String eventId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uuid = authProvider.uuid;
      if (uuid == null) return;

      final action = _likedEvents.contains(eventId) ? 'unlike' : 'like';

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.updateEventLike(
          uuid: uuid, eventId: eventId, action: action);

      if (response['status'] == 'success') {
        setState(() {
          if (action == 'like') {
            _likedEvents.add(eventId);
          } else {
            _likedEvents.remove(eventId);
          }

          // Update likes count in events list
          final eventIndex =
              _events.indexWhere((e) => e['event_id'] == eventId);
          if (eventIndex != -1) {
            _events[eventIndex]['likes_count'] =
                response['data']['likes_count'];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
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

  // void _handleEventRegistration(int index) {
  //   try {
  //     HapticFeedback.mediumImpact();
  //     setState(() {
  //       _selectedEventIndex = index;
  //     });
  //     _expandController.forward();
  //   } catch (e) {
  //     setState(() {
  //       _selectedEventIndex = index;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                                itemCount: _events.length,
                                options: CarouselOptions(
                                  height: size.height * 0.50,
                                  viewportFraction: 0.75,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: true,
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  final event = _events[index];
                                  return EventCard(
                                    event: event,
                                    likedEvents: _likedEvents,
                                    onLikePressed: _toggleLike,
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
                    image: AssetImage(event['image']),
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
                                  '${event['entries'] ?? '14/20'}',
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
                                  event['title'] ?? 'The Exchange',
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
                            if (event['venue'] == null) return;
                            final Uri url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${event['venue']}');
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
                                    event['venue'] ?? '',
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
                                    HapticFeedback.mediumImpact();
                                    _handleUnregister();
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
                                    _toggleLike(event['event_id']);
                                  },
                                  child: Icon(
                                    _likedEvents.contains(event['event_id'])
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        _likedEvents.contains(event['event_id'])
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
                    image: AssetImage(event['image']),
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
                                  '${event['entries'] ?? '14/20'}',
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
                                  event['title'] ?? 'The Exchange',
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
                            if (event['venue'] == null) return;
                            final Uri url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${event['venue']}');
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
                                    event['venue'] ?? '',
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
                                    HapticFeedback.mediumImpact();
                                    _handleUnregister();
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
                                    _toggleLike(event['event_id']);
                                  },
                                  child: Icon(
                                    _likedEvents.contains(event['event_id'])
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        _likedEvents.contains(event['event_id'])
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

  // Add this method to handle going back to the waitlist view
  void _handleUnregister() {
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    _expandController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _selectedEventIndex = null;
      });
    });
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final Set<String> likedEvents;
  final Function(String) onLikePressed;

  const EventCard({
    super.key,
    required this.event,
    required this.likedEvents,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLiked = likedEvents.contains(event['event_id']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              event['event_image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event['event_name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => onLikePressed(event['event_id']),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.sports,
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      event['sport'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                // ... rest of your existing card UI with real data
              ],
            ),
          ),
        ],
      ),
    );
  }
}
