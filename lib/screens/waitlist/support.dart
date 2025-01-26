import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/network/think.dart';
import 'dart:convert';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _concernController = TextEditingController();
  final FocusNode _concernFocusNode = FocusNode();
  final List<File> _screenshots = [];
  bool _isSubmitting = false;
  final int _maxWords = 350;

  @override
  void dispose() {
    _concernController.dispose();
    _concernFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress images for faster upload
    );

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
    if (_concernController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your concern'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final thinkProvider = ThinkProvider();
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('uuid') ?? '';

      // Convert images to base64 if they exist
      String? image1;
      String? image2;
      if (_screenshots.isNotEmpty) {
        image1 = base64Encode(await _screenshots[0].readAsBytes());
        if (_screenshots.length > 1) {
          image2 = base64Encode(await _screenshots[1].readAsBytes());
        }
      }

      final response = await thinkProvider.submitSupportTicket(
        uuid: uuid,
        screenName: 'KYC_Verification',
        supportText: _concernController.text.trim(),
        image1: image1,
        image2: image2,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        // Save ticket submission status
        await prefs.setBool('has_submitted_ticket', true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your ticket has been received. We\'ll contact you soon with a solution.'),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit ticket. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          title: const Text('Contact Support'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            physics: const BouncingScrollPhysics(),
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
                  focusNode: _concernFocusNode,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What went wrong? (max 350 words)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
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
                  Container(
                    height: 100,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _screenshots.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isDarkMode ? Colors.white30 : Colors.black26,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _screenshots[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _screenshots.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
                  style: TextButton.styleFrom(
                    foregroundColor: _screenshots.length < 3
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting || _concernController.text.isEmpty
                              ? null
                              : _submitTicket,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isIOS ? 30 : 25),
                        ),
                        elevation: 0,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
