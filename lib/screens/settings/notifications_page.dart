import 'package:flutter/material.dart';

import '../../constants/appColors.dart';
import '../../constants/appFonts.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: AppFonts.appBarTitle(
            color: Theme.of(context).colorScheme.tertiary,
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
              onChanged: (value) =>
                  setState(() => dateRemindersMuted = value),
            ),

            // Event Reminders Section
            _buildNotificationSection(
              title: 'Event Reminders',
              subtitle: 'Mute event notifications',
              icon: Icons.event_outlined,
              value: eventRemindersMuted,
              onChanged: (value) =>
                  setState(() => eventRemindersMuted = value),
            ),
          ],

          if (dndEnabled)
            const Padding(
              padding: EdgeInsets.all(16.0),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ?  Colors.red.withAlpha(40)
                : AppColors.primary.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive
                ?  Colors.red
                : AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style:  AppFonts.titleBold(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:  AppFonts.titleBold(
            color: AppColors.grey,
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
