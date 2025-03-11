import 'package:flutter/material.dart';
import '../barrel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnipsScreen extends StatefulWidget {
  const SnipsScreen({super.key});

  @override
  State<SnipsScreen> createState() => _SnipsScreenState();
}

class _SnipsScreenState extends State<SnipsScreen> {
  final PageController _pageController = PageController();
  final SnipCacheManager _cacheManager = SnipCacheManager();
  final _thinkProvider = ThinkProvider();
  String? _uuid;

  List<SnipModel> _snips = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasMore = true;
  int? _nextPage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initUuid();
  }

  Future<void> _initUuid() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('uuid');
    if (uuid != null) {
      setState(() => _uuid = uuid);
      _loadInitialSnips();
    } else {
      setState(() => _error = 'User ID not found. Please login again.');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    VideoService.disposeAllControllers();
    _cacheManager.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSnips() async {
    if (_uuid == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 1. Make API call
      final apiResponse = await _thinkProvider.getSnips(
        uuid: _uuid!,
        page: 1,
      );

      // 2. Parse the response
      final parsedResponse = await SnipParser.parseSnipResponse(apiResponse);

      // 3. Convert to model
      final response = SnipsResponse.fromApiResponse(parsedResponse);

      if (!mounted) return;

      // 4. Update state with model data
      setState(() {
        _snips = response.snips;
        _hasMore = response.hasMore;
        _nextPage = response.nextPage;
        _isLoading = false;
      });

      // 5. Preload videos using VideoService
      if (_snips.isNotEmpty) {
        final urls = _snips.take(2).map((snip) => snip.video.source).toList();
        await VideoService.preloadVideos(urls);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreSnips() async {
    if (!_hasMore || _nextPage == null || _uuid == null) return;

    try {
      // 1. Make API call with pagination
      final apiResponse = await _thinkProvider.getSnips(
        uuid: _uuid!,
        page: _nextPage!,
      );

      // 2. Parse the response
      final parsedResponse = await SnipParser.parseSnipResponse(apiResponse);

      // 3. Convert to model
      final response = SnipsResponse.fromApiResponse(parsedResponse);

      if (!mounted) return;

      // 4. Update state with model data
      setState(() {
        _snips.addAll(response.snips);
        _hasMore = response.hasMore;
        _nextPage = response.nextPage;
      });

      // 5. Preload new videos
      if (response.snips.isNotEmpty) {
        final urls =
            response.snips.take(2).map((snip) => snip.video.source).toList();
        await VideoService.preloadVideos(urls);
      }
    } catch (e) {
      debugPrint('Error loading more snips: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Load more snips when reaching near the end
    if (_hasMore && index >= _snips.length - 2) {
      _loadMoreSnips();
    }

    // Manage video playback using VideoService
    if (index + 2 < _snips.length) {
      final nextUrls = _snips
          .sublist(index + 1, index + 3)
          .map((snip) => snip.video.source)
          .toList();
      VideoService.preloadVideos(nextUrls);
    }

    // Pause previous video
    if (index > 0) {
      final prevUrl = _snips[index - 1].video.source;
      VideoService.pause(prevUrl);
    }

    // Play current video
    final currentUrl = _snips[index].video.source;
    VideoService.play(currentUrl);
  }

  Future<void> _onRefresh() async {
    _nextPage = null;
    await _loadInitialSnips();
  }

  Future<void> _onLike(SnipModel snip) async {
    try {
      // TODO: Implement like API call once available
      debugPrint('Like tapped for snip ${snip.snipId}');

      // Optimistic update
      setState(() {
        final index = _snips.indexWhere((s) => s.snipId == snip.snipId);
        if (index != -1) {
          _snips[index] = snip.copyWith(
            likesCount: snip.likesCount + 1,
          );
        }
      });
    } catch (e) {
      debugPrint('Error liking snip: $e');
      // Revert optimistic update on error
      setState(() {
        final index = _snips.indexWhere((s) => s.snipId == snip.snipId);
        if (index != -1) {
          _snips[index] = snip;
        }
      });
    }
  }

  Future<void> _onComment(SnipModel snip) async {
    // Navigate to comments screen
    final result = await Navigator.pushNamed(
      context,
      '/comments',
      arguments: snip,
    );

    // Refresh snip if comments were added
    if (result == true) {
      _loadInitialSnips();
    }
  }

  Future<void> _onShare(SnipModel snip) async {
    // TODO: Implement share API call once available
    debugPrint('Share tapped for snip ${snip.snipId}');
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialSnips,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No snips available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
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

    if (_error != null) {
      return Scaffold(body: _buildErrorView());
    }

    if (_snips.isEmpty) {
      return Scaffold(body: _buildEmptyView());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Snips',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: _snips.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _snips.length) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final snip = _snips[index];
            return SnipCard(
              key: ValueKey(snip.snipId),
              snip: snip,
              isVisible: index == _currentIndex,
              onLike: () => _onLike(snip),
              onComment: () => _onComment(snip),
              onShare: () => _onShare(snip),
            );
          },
        ),
      ),
    );
  }
}
