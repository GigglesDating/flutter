import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class AddToStoryScreen extends StatefulWidget {
  @override
  _AddToStoryScreenState createState() => _AddToStoryScreenState();
}

class _AddToStoryScreenState extends State<AddToStoryScreen> with WidgetsBindingObserver {
  File? _mediaFile;
  bool isVideo = false;
  VideoPlayerController? _videoController;
  final TextEditingController _textController = TextEditingController();
  final _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);
  bool _isSdkInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeBanuba();
  }

  Future<void> _initializeBanuba() async {
    try {
      await _banubaSdkManager.initialize(
        [],  // Add your effects paths here
        'YOUR_TOKEN_HERE',
        SeverityLevel.info
      );
      
      setState(() {
        _isSdkInitialized = true;
      });

      // Request permissions
      final granted = await requestPermissions();
      if (granted) {
        debugPrint('All permissions granted');
      } else {
        debugPrint('Not all permissions granted');
      }
    } catch (e) {
      print('Failed to initialize Banuba SDK: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera effects')),
        );
      }
    }
  }

  Future<void> _openCamera() async {
    if (!_isSdkInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera effects are initializing...')),
      );
      return;
    }

    try {
      await _banubaSdkManager.openCamera();
      await _banubaSdkManager.attachWidget(_epWidget.banubaId);
      await _banubaSdkManager.startPlayer();
      // Load your effect
      await _banubaSdkManager.loadEffect("effects/YourEffect", false);
    } catch (e) {
      print('Error opening camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera effects')),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _banubaSdkManager.startPlayer();
    } else {
      _banubaSdkManager.stopPlayer();
    }
  }

  Future<bool> requestPermissions() async {
    final requiredPermissions = Platform.isAndroid 
      ? [Permission.camera, Permission.microphone, Permission.storage]
      : [Permission.camera, Permission.microphone];

    for (var permission in requiredPermissions) {
      var status = await permission.status;
      if (!status.isGranted) {
        status = await permission.request();
        if (!status.isGranted) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _openBanubaEditor() async {
    if (!_isSdkInitialized || _banubaSdkManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera effects are initializing...')),
      );
      return;
    }

    try {
      final result = await _banubaSdkManager.openVideoEditor(
        config: VideoEditorConfig(
          trim: TrimConfig(
            enabled: true,
            minDuration: 1,
            maxDuration: 60,
          ),
          music: MusicConfig(enabled: true),
          filters: FiltersConfig(enabled: true),
          aspectRatio: AspectRatioConfig(
            enabled: true,
            ratios: [AspectRatio.original],
          ),
        ),
      );

      if (result != null && result.videoPath != null) {
        setState(() {
          _mediaFile = File(result.videoPath!);
          isVideo = true;
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) => setState(() {}))
            ..setLooping(true)
            ..play();
        });
      }
    } catch (e) {
      print('Error using Banuba editor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera effects')),
        );
      }
    }
  }

  Future<void> _pickMedia(ImageSource source, {bool pickVideo = false}) async {
    final picker = ImagePicker();
    final pickedFile = await (pickVideo
        ? picker.pickVideo(source: source)
        : picker.pickImage(source: source));

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        isVideo = pickVideo;
        if (isVideo) {
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) => setState(() {}))
            ..setLooping(true)
            ..play();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    _banubaSdkManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        title: Text('Add to Story',
            style: AppFonts.titleMedium(
                color: Theme.of(context).colorScheme.tertiary, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.tertiary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              _showTextInputDialog(context);
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            if (_mediaFile != null)
              isVideo
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : Image.file(_mediaFile!),
            if (_textController.text.isNotEmpty)
              Positioned(
                top: 100,
                left: 20,
                child: Text(
                  _textController.text,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        onPressed: () => _showMediaPickerOptions(),
        child: Icon(Icons.camera_alt,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.white
                : AppColors.black),
      ),
    );
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_enhance,
                color: Theme.of(context).colorScheme.tertiary),
            title: Text('Camera with Effects'),
            onTap: () {
              Navigator.pop(context);
              _openCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.blue),
            title: Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickMedia(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.red),
            title: Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickMedia(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}
