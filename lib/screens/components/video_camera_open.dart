import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoCameraScreen extends StatefulWidget {
  @override
  _VideoCameraScreenState createState() => _VideoCameraScreenState();
}

class _VideoCameraScreenState extends State<VideoCameraScreen> {
  CameraController? _controller; // Nullable controller
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Fetch available cameras
      final cameras = await availableCameras();
      // Select the first camera (typically the back camera)
      final camera = cameras.first;

      // Initialize the controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true, // Enable audio for video recording
      );

      // Initialize the controller and update the state when done
      await _controller?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller != null && _controller!.value.isInitialized && !_controller!.value.isRecordingVideo) {
      await _controller?.startVideoRecording();
    }
  }

  Future<void> _stopRecording() async {
    if (_controller != null && _controller!.value.isRecordingVideo) {
      final file = await _controller?.stopVideoRecording();
      if (file != null) {
        print('Video saved to: ${file.path}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Camera')),
      body: _isCameraInitialized && _controller != null
          ? CameraPreview(_controller!)
          : Center(child: CircularProgressIndicator()), // Show loading indicator until camera is initialized

    );
  }
}
