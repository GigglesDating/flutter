import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.grey,
              child: const Icon(Icons.support_agent),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _showCallConfirmation(context),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'end_chat',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('End Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rate',
                child: Row(
                  children: [
                    Icon(Icons.star_outline),
                    SizedBox(width: 8),
                    Text('Rate Support'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSupportMessage(
                  "I understand you're having trouble with your match preferences. Let me help you adjust your settings for better matches.",
                ),
                _buildUserMessage(
                  "Yes, I'm not getting matches from my preferred age group and location even though I've set them correctly.",
                ),
                _buildSupportMessage(
                  "I can help you review your profile settings. First, could you confirm if you've updated your preferences in both 'Match Settings' and 'Search Filters'?",
                ),
                _buildUserMessage(
                  "I've only updated it in Match Settings, I didn't know about Search Filters",
                ),
                _buildSupportMessage(
                  "That explains it! Let me guide you through updating your Search Filters. Go to your profile, tap on 'Search Filters' and you'll see options for age range, location radius, and other preferences.",
                ),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _handleAttachment,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Start typing',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.grey.withAlpha(40),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: _handleVoiceRecord,
                  color: _isRecording ? Colors.red : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(message),
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(message),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'end_chat':
        _showEndChatConfirmation();
        break;
      case 'rate':
        _showRateDialog();
        break;
      case 'clear':
        _showClearChatConfirmation();
        break;
    }
  }

  void _showCallConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text(
          'Support calls are only for emergencies and escalations. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportCallScreen(),
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _handleAttachment() {
    // Implement file attachment
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo'),
              onTap: () {
                // Implement photo selection
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Document'),
              onTap: () {
                // Implement document selection
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceRecord() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // Implement voice recording
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // Implement message sending
      _messageController.clear();
    }
  }

  void _showEndChatConfirmation() {
    // Implement end chat confirmation
  }

  void _showRateDialog() {
    double rating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star_rate_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Rate Support'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience with our support team?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < rating ? Colors.amber : Colors.grey,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              if (rating > 0) ...[
                const SizedBox(height: 20),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add your feedback (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      // Handle rating submission
                      Navigator.pop(context);
                      _showRatingSuccessMessage();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white),
            const SizedBox(width: 8),
            const Text('Thank you for your feedback!'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showClearChatConfirmation() {
    // Implement clear chat confirmation
  }
}

class SupportCallScreen extends StatefulWidget {
  const SupportCallScreen({super.key});

  @override
  State<SupportCallScreen> createState() => _SupportCallScreenState();
}

class _SupportCallScreenState extends State<SupportCallScreen> {
  bool isRecording = false;
  Duration callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Start call duration timer
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          callDuration += const Duration(seconds: 1);
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Support Agent Info
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child:
                      Icon(Icons.support_agent, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Customer Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${callDuration.inMinutes}:${(callDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Call Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(
                  icon: isRecording
                      ? Icons.stop_circle
                      : Icons.fiber_manual_record,
                  color: isRecording ? Colors.red : Colors.white,
                  label: isRecording ? 'Stop Recording' : 'Record Call',
                  onPressed: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                ),
                _buildCallButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  label: 'End Call',
                  onPressed: () => Navigator.pop(context),
                  isEndCall: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
    bool isEndCall = false,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          backgroundColor: isEndCall ? Colors.red : Colors.white24,
          onPressed: onPressed,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
