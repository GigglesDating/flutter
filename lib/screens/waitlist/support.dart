import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _concernController = TextEditingController();
  final List<File> _screenshots = [];
  bool _isSubmitting = false;
  final int _maxWords = 350;

  @override
  void dispose() {
    _concernController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _screenshots.add(File(image.path));
      });
    }
  }

  int _getWordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> _submitTicket() async {
    setState(() => _isSubmitting = true);

    // TODO: Implement API call to submit ticket
    await Future.delayed(const Duration(seconds: 2)); // Simulating API call

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Your ticket has been received. We\'ll contact you soon with a solution.'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Contact Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Describe your concern',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              TextField(
                controller: _concernController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What went wrong? (max 350 words)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (text) {
                  if (_getWordCount(text) > _maxWords) {
                    _concernController.text = text
                        .trim()
                        .split(RegExp(r'\s+'))
                        .take(_maxWords)
                        .join(' ');
                    _concernController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _concernController.text.length),
                    );
                  }
                  setState(() {});
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${_getWordCount(_concernController.text)}/$_maxWords words',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                'Add Screenshots (optional)',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              if (_screenshots.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _screenshots.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(
                              _screenshots[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _screenshots.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              TextButton.icon(
                onPressed: _screenshots.length < 3 ? _pickImage : null,
                icon: Icon(Icons.add_photo_alternate),
                label: Text('Add Screenshot (${_screenshots.length}/3)'),
              ),
              SizedBox(height: size.height * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _concernController.text.isEmpty
                      ? null
                      : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: size.width * 0.05,
                          width: size.width * 0.05,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
