import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class AddToStoryScreen extends StatefulWidget {
  @override
  _AddToStoryScreenState createState() => _AddToStoryScreenState();
}

class _AddToStoryScreenState extends State<AddToStoryScreen> {
  File? _mediaFile;
  bool isVideo = false;
  VideoPlayerController? _videoController;
  final TextEditingController _textController = TextEditingController();

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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Set to your desired color
          statusBarIconBrightness: Theme.of(context).brightness==Brightness.light? Brightness.dark: Brightness.light, // Use Brightness.dark for dark icons
        ),
        title: Text('Add to Story'),
        titleTextStyle: AppFonts.titleMedium(color: Theme.of(context).colorScheme.tertiary,fontSize: 20),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color:Theme.of(context).colorScheme.tertiary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields, color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              // Add text overlay
              _showTextInputDialog(context);
            },
          ),
          SizedBox(width: 16,),
          // IconButton(
          //   icon: Icon(Icons.brush, color: Colors.white),
          //   onPressed: () {
          //     // Add drawing functionality
          //     // Implement your drawing overlay logic here
          //   },
          // ),
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
            // Text overlay widget
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
        child: Icon(Icons.camera_alt, color: Theme.of(context).brightness==Brightness.light?Colors.white:Colors.black),
      ),
    );
  }

  // Show options to pick image or video
  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.photo, size: 30, color: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery);
              },
            ),
            IconButton(
              icon: Icon(Icons.camera, size: 30, color: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera);
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.videocam, size: 30, color: Colors.green),
            //   onPressed: () {
            //     Navigator.pop(context);
            //     _pickMedia(ImageSource.camera, pickVideo: true);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // Show dialog to add text overlay
  void _showTextInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Add Text', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _textController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter text',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}