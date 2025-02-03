import 'package:flutter/material.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';


class AccountPrivacyScreen extends StatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  State<AccountPrivacyScreen> createState() => _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends State<AccountPrivacyScreen> {
  bool shareWithEveryone = false;
  bool shareWithMatches = false;
  String selectedGroup = 'Favourites';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Privacy',
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
          // Content Sharing Settings Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Content sharing settings',
              style: AppFonts.titleMedium(
                fontSize: 16,
                color: AppColors.grey,
                // fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Share with Everyone Option
          _buildPrivacyOption(
            title: 'Share with everyone',
            description:
                'By choosing "Share with Everyone," your content becomes publicly accessible to all users, including those outside your immediate network.',
            value: shareWithEveryone,
            onChanged: (value) {
              setState(() {
                shareWithEveryone = value;
                if (value) {
                  shareWithMatches = false;
                }
              });
            },
            icon: Icons.public,
          ),

          const SizedBox(height: 12),

          // Share with Matches Option
          _buildPrivacyOption(
            title: 'Share only with matches',
            description:
                'By selecting "Share Only with Matches," your content will be visible exclusively to your approved connections. This option ensures that your updates, photos, and posts remain within your trusted circle.',
            value: shareWithMatches,
            onChanged: (value) {
              setState(() {
                shareWithMatches = value;
                if (value) {
                  shareWithEveryone = false;
                }
              });
            },
            icon: Icons.favorite_border,
          ),

          const SizedBox(height: 12),

          // Custom Share Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_border,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Share only with',
                    style: AppFonts.titleBold(
                      fontSize: 16,
                      // fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: selectedGroup,

                    items: ['Favourites', 'Close Matches', 'Best Matches']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == 'Favourites'
                                  ? Icons.star
                                  : value == 'Close Matches'
                                      ? Icons.favorite
                                      : Icons.thumb_up,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(value,style: AppFonts.titleBold(fontSize: 14),),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedGroup = newValue;
                        });
                      }
                    },
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      // size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: value
                        ? AppColors.primary.withAlpha(40)
                        : AppColors.grey.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: value
                        ? AppColors.primary
                        : AppColors.primary.withAlpha(40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.titleBold(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                description,
                style: AppFonts.titleMedium(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}