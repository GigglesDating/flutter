import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/barrel.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  bool _isLoading = true;
  List<Map<String, String>> _faqList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getFaqs();

      if (response['status'] == 'success') {
        final List<dynamic> faqs = response['faqs'];

        setState(() {
          _faqList = faqs
              .map((faq) => {
                    'question': faq['question'] as String,
                    'answer': faq['answer'] as String,
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load FAQs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading FAQs: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with support icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FAQs',
                    style: TextStyle(
                      fontSize: textScaler.scale(28),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.support_agent_outlined,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: textScaler.scale(28),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Subtitle
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                  bottom: size.height * 0.03,
                ),
                child: Text(
                  'Find Answers to Your Common Questions and Get\nthe Information You Need',
                  style: TextStyle(
                    fontSize: textScaler.scale(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),

              // Show loading indicator or error
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: textScaler.scale(16),
                    ),
                  ),
                )
              else
                // FAQ List
                ..._faqList.map((faq) => _FAQItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
                      isDarkMode: isDarkMode,
                    )),

              // Contact Support Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Contact support',
                      style: TextStyle(
                        fontSize: textScaler.scale(16),
                        decoration: TextDecoration.underline,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
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

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDarkMode;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isDarkMode,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: textScaler.scale(16),
                      fontWeight: FontWeight.w500,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: EdgeInsets.only(
              bottom: size.height * 0.015,
              right: size.width * 0.1,
            ),
            child: Text(
              widget.answer,
              style: TextStyle(
                fontSize: textScaler.scale(14),
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        Divider(
          color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
          height: 1,
        ),
      ],
    );
  }
}
