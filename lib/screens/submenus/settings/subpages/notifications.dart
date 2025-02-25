import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool dndEnabled = false;
  bool p2pMuted = false;
  bool groupsMuted = false;
  bool dateRemindersMuted = false;
  bool eventRemindersMuted = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Notifications',
        ),
        titleSpacing: 15,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DND Section
          _buildNotificationSection(
            title: 'Do Not Disturb',
            subtitle: 'Mute all notifications',
            icon: Icons.do_not_disturb_on_outlined,
            value: dndEnabled,
            onChanged: (value) {
              setState(() {
                dndEnabled = value;
                if (value) {
                  // If DND is enabled, mute everything
                  p2pMuted = true;
                  groupsMuted = true;
                  dateRemindersMuted = true;
                  eventRemindersMuted = true;
                }
              });
            },
            isDestructive: true,
          ),

          if (!dndEnabled) ...[
            // Chat & Calls Section
            _buildNotificationSection(
              title: 'Chats & Calls',
              subtitle: 'Mute messages and call notifications',
              icon: Icons.chat_bubble_outline,
              value: p2pMuted,
              onChanged: (value) => setState(() => p2pMuted = value),
            ),

            // Groups Section
            _buildNotificationSection(
              title: 'Groups',
              subtitle: 'Mute group notifications',
              icon: Icons.group_outlined,
              value: groupsMuted,
              onChanged: (value) => setState(() => groupsMuted = value),
            ),

            // Date Reminders Section
            _buildNotificationSection(
              title: 'Date Reminders',
              subtitle: 'Mute upcoming date notifications',
              icon: Icons.favorite_outline,
              value: dateRemindersMuted,
              onChanged: (value) => setState(() => dateRemindersMuted = value),
            ),

            // Event Reminders Section
            _buildNotificationSection(
              title: 'Event Reminders',
              subtitle: 'Mute event notifications',
              icon: Icons.event_outlined,
              value: eventRemindersMuted,
              onChanged: (value) => setState(() => eventRemindersMuted = value),
            ),
          ],

          if (dndEnabled)
            const Padding(
              padding: EdgeInsets.only(
                left: 25,
                top: 7,
              ),
              child: Text(
                'All notifications are currently muted. Turn off Do Not Disturb to manage individual notification settings.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isDestructive = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color.fromARGB(255, 244, 67, 54).withAlpha(40)
                : const Color.fromARGB(255, 82, 113, 255).withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? const Color.fromARGB(255, 244, 67, 54)
                : const Color.fromARGB(255, 82, 113, 255),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: isDestructive ? Colors.red : Colors.blue,
        ),
      ),
    );
  }
}
