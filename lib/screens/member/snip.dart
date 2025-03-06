import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../barrel.dart';
import '../../network/auth_provider.dart';
import 'package:provider/provider.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTabState();
}

class _SnipTabState extends State<SnipTab>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<VideoPlayerController?> _controllers = [];
  List<Map<String, dynamic>> _snips = [];
  int _currentSnipIndex = 0;
  bool _isMuted = false;
  bool _isLiked = false;
  bool _showHeart = false;
  bool isPlaying = true;
  bool _isLoading = false;
  bool _hasMore = false;
  String? _nextPage;
  late AnimationController _animationController;
  final int _preloadLimit = 1; // Preload one video on each side
  bool _isActive = false;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  bool _showVolumeIndicator = false;
  Timer? _volumeIndicatorTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadInitialSnips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're the active route
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _activate();
    } else {
      _deactivate();
    }
  }

  void _activate() {
    if (!_isActive) {
      _isActive = true;
      // Only re-initialize if controllers are not already initialized.
      if (_controllers.isEmpty || _controllers[_currentSnipIndex] == null) {
        _initializeControllers();
      } else {
        // If already initialized, just play.
        _controllers[_currentSnipIndex]?.play();
      }
    }
  }

  void _deactivate() {
    if (_isActive) {
      _isActive = false;
      // Pause, but *don't* dispose, unless outside preload limit.
      _pauseCurrentController();
    }
  }

  void _pauseCurrentController() {
    if (_controllers[_currentSnipIndex] != null) {
      _controllers[_currentSnipIndex]?.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background or navigated away
      _pauseCurrentController(); // Use the helper function
    }
    if (state == AppLifecycleState.resumed) {
      // App is back in foreground.  Play *only* if we are the active route.
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _controllers[_currentSnipIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  Future<void> _loadInitialSnips() async {
    setState(() => _isLoading = true);
    try {
      final thinkProvider = ThinkProvider();
      final uuid = Provider.of<AuthProvider>(context, listen: false).uuid;

      if (uuid == null) {
        debugPrint('Error: UUID is null');
        return;
      }

      final result = await thinkProvider.getSnips(uuid: uuid, page: 1);
      debugPrint('Raw Snips Response: ${result.toString()}');

      if (result['status'] == 'success') {
        final snips = result['data']['snips'] as List<dynamic>;
        debugPrint('First snip data: ${snips.first.toString()}');

        setState(() {
          _snips = List<Map<String, dynamic>>.from(result['data']['snips']);
          _hasMore = result['data']['has_more'];
          _nextPage = result['data']['next_page'];
        });
        _initializeControllers();
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading snips: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreSnips() async {
    if (!_hasMore || _isLoading || _nextPage == null) return;

    setState(() => _isLoading = true);
    try {
      final thinkProvider = ThinkProvider();
      final uuid = Provider.of<AuthProvider>(context, listen: false).uuid;

      // Handle null uuid
      if (uuid == null) {
        debugPrint('Error: UUID is null');
        return;
      }

      final result =
          await thinkProvider.getSnips(uuid: uuid, page: int.parse(_nextPage!));
      if (result['status'] == 'success') {
        setState(() {
          _snips
              .addAll(List<Map<String, dynamic>>.from(result['data']['snips']));
          _hasMore = result['data']['has_more'];
          _nextPage = result['data']['next_page'];
        });
        _initializeControllers();
      }
    } catch (e) {
      debugPrint('Error loading more snips: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(_snips.length, (_) => null);
    _initializeControllerAtIndex(_currentSnipIndex);
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    debugPrint('Initializing video controller for index: $index');
    if (index < 0 || index >= _snips.length) {
      debugPrint('Invalid index: $index');
      return;
    }

    if (_controllers[index] != null) {
      await _controllers[index]!.dispose();
    }

    try {
      final videoUrl = _snips[index]['video']['source'];
      debugPrint('Loading video from URL: $videoUrl');

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controllers[index] = controller;
      });

      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (index == _currentSnipIndex) {
        controller.play();
        setState(() => isPlaying = true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing video at index $index: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading && _snips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Snip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withAlpha(80)
                    : Colors.black.withAlpha(26),
              ),
              child: SvgPicture.asset(
                'assets/icons/snip/snip_upload.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.white : Colors.black.withAlpha(204),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withAlpha(80)
                    : Colors.black.withAlpha(26),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color:
                      isDarkMode ? Colors.white : Colors.black.withAlpha(204),
                  size: 24,
                ),
                onPressed: _showReportSheet,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen PageView for videos
          Positioned.fill(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _snips.length,
              onPageChanged: (index) {
                if (index == _snips.length - 1) {
                  _loadMoreSnips();
                }
                _handlePageChange(index);
              },
              itemBuilder: (context, index) {
                final snip = _snips[index];
                return VisibilityDetector(
                  key: Key('video_$index'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (mounted) {
                      if (visibilityInfo.visibleFraction > 0.8) {
                        if (index == _currentSnipIndex &&
                            (ModalRoute.of(context)?.isCurrent ?? false)) {
                          _controllers[index]?.play();
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      } else {
                        _controllers[index]?.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      }
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (!isPlaying) {
                        // Resume video if paused
                        togglePlay();
                      } else {
                        // Toggle mute if playing
                        toggleVolume();
                      }
                    },
                    onDoubleTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isLiked = !_isLiked;
                        _showHeart = true;
                      });
                      _animationController.forward().then((_) {
                        _animationController.reverse().then((_) {
                          setState(() => _showHeart = false);
                        });
                      });
                    },
                    onLongPressStart: (_) {
                      if (isPlaying) {
                        togglePlay(); // Pause video
                      }
                    },
                    onLongPressEnd: (_) {
                      // Don't auto-resume on long press end
                      // User needs to tap once to resume
                    },
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          // Video Player with all gesture detectors
                          GestureDetector(
                            onTap: () {
                              if (!isPlaying) {
                                // Resume video if paused
                                togglePlay();
                              } else {
                                // Toggle mute if playing
                                toggleVolume();
                              }
                            },
                            onDoubleTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isLiked = !_isLiked;
                                _showHeart = true;
                              });
                              _animationController.forward().then((_) {
                                _animationController.reverse().then((_) {
                                  setState(() => _showHeart = false);
                                });
                              });
                            },
                            onLongPressStart: (_) {
                              if (isPlaying) {
                                togglePlay(); // Pause video
                              }
                            },
                            onLongPressEnd: (_) {
                              // Don't auto-resume on long press end
                              // User needs to tap once to resume
                            },
                            child: Container(
                              color: Colors.black,
                              child: Center(
                                child:
                                    _controllers[index]?.value.isInitialized ??
                                            false
                                        ? SizedBox(
                                            width: screenWidth,
                                            height: screenHeight,
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: _controllers[index]!
                                                    .value
                                                    .size
                                                    .width,
                                                height: _controllers[index]!
                                                    .value
                                                    .size
                                                    .height,
                                                child: VideoPlayer(
                                                    _controllers[index]!),
                                              ),
                                            ),
                                          )
                                        : const CircularProgressIndicator(
                                            color: Colors.white),
                              ),
                            ),
                          ),

                          // Play/Pause indicator overlay
                          if (!isPlaying)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 102),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white.withValues(alpha: 217),
                                ),
                              ),
                            ),

                          // Mute indicator
                          if (_showVolumeIndicator)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 102),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  size: 40,
                                  color: Colors.white.withValues(alpha: 217),
                                ),
                              ),
                            ),

                          // Like animation overlay
                          if (_showHeart)
                            Positioned.fill(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _showHeart ? 1.0 : 0.0,
                                child: Center(
                                  child: ScaleTransition(
                                    scale: _animationController,
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.white.withAlpha(255),
                                      size: screenWidth * 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Action bar
                          Positioned(
                            right: screenWidth * 0.04,
                            bottom: screenWidth * 0.15,
                            child: ActionBar(
                              isDarkMode: isDarkMode,
                              isLiked: _isLiked,
                              onLikeTap: () => _handleLike(snip),
                              onCommentTap: () =>
                                  _showCommentsSheet(context, snip),
                              onShareTap: () => _showShareSheet(snip),
                              orientation: ActionBarOrientation.vertical,
                              backgroundColor: isDarkMode
                                  ? Colors.black.withAlpha(230)
                                  : Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Map<String, dynamic> snip) {
    _controllers[_currentSnipIndex]?.pause();
    setState(() => isPlaying = false);

    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        post: snip,
        screenHeight: size.height,
        screenWidth: size.width,
      ),
    ).then((_) {
      if (mounted) {
        _controllers[_currentSnipIndex]?.play();
        setState(() => isPlaying = true);
      }
    });
  }

  void _handleLike(Map<String, dynamic> snip) {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _showHeart = true;
    });
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        setState(() => _showHeart = false);
      });
    });
  }

  void _showShareSheet(Map<String, dynamic> snip) {
    // Pause the video *before* showing the bottom sheet.
    _controllers[_currentSnipIndex]?.pause();
    setState(() {
      isPlaying = false;
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
      builder: (context) => ShareSheet(
        isDarkMode: isDarkMode,
        post: snip,
        screenWidth: MediaQuery.of(context).size.width,
      ),
    ).then((_) {
      // Resume playback *after* the bottom sheet is closed.
      if (mounted) {
        // Crucially, *remove* the seekTo. Just play.
        _controllers[_currentSnipIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

  void _showReportSheet() {
    // Pause *before* showing the sheet.
    _controllers[_currentSnipIndex]?.pause();
    setState(() {
      isPlaying = false;
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
      builder: (context) => ContentReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
      ),
    ).then((_) {
      // Resume *after* the sheet is closed.
      if (mounted) {
        // *Remove* seekTo.
        _controllers[_currentSnipIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

  void _handlePageChange(int index) async {
    // Pause the *current* video.
    _pauseCurrentController();

    // Dispose controllers *outside* the preload range.
    for (var i = 0; i < _controllers.length; i++) {
      if (i < index - _preloadLimit || i > index + _preloadLimit) {
        if (_controllers[i] != null) {
          await _controllers[i]!.dispose();
          setState(() {
            _controllers[i] = null;
          });
        }
      }
    }

    // Initialize videos *within* preload range.
    for (var i = index - _preloadLimit; i <= index + _preloadLimit; i++) {
      if (i >= 0 && i < _snips.length && _controllers[i] == null) {
        await _initializeControllerAtIndex(i);
      }
    }

    setState(() {
      _currentSnipIndex = index;
    });

    // Play the *new* current video.
    _controllers[index]?.play();
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    _volumeIndicatorTimer?.cancel();
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> toggleVolume() async {
    if (_controllers[_currentSnipIndex] == null) return;

    setState(() {
      _isMuted = !_isMuted;
      _showVolumeIndicator = true;
    });

    await _controllers[_currentSnipIndex]!.setVolume(_isMuted ? 0.0 : 1.0);

    // Hide volume indicator after delay
    _volumeIndicatorTimer?.cancel();
    _volumeIndicatorTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showVolumeIndicator = false);
      }
    });
  }

  void togglePlay() {
    if (_controllers[_currentSnipIndex] != null) {
      setState(() {
        isPlaying = !isPlaying;
        if (isPlaying) {
          _controllers[_currentSnipIndex]?.play();
        } else {
          _controllers[_currentSnipIndex]?.pause();
        }
      });
    }
  }
}
