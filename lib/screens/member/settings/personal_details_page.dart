import 'package:flutter/material.dart';

import '../../../utilitis/appColors.dart';
import '../../../utilitis/appFonts.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Detail',
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: AppFonts.appBarTitle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        children: [
          // Profile Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Membership Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text('Premium Membership: 12 days remaining',
                              style: AppFonts.titleBold(
                                  color: AppColors.black, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  _buildInfoRow('First Name', 'Ramesh', 'Last Name', 'Patel'),
                  const SizedBox(height: 24),
                  _buildInfoRow('DOB', '05/02/1997', 'Aadhar', 'XX4234'),
                  const SizedBox(height: 24),
                  _buildInfoRow('City', 'Bangalore', 'Username', 'Unique102'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Column
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label1:',
                style: AppFonts.titleRegular(color: AppColors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: AppFonts.titleBold(fontSize: 18),
              ),
            ],
          ),
        ),
        // Second Column
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label2:',
                style: AppFonts.titleRegular(color: AppColors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: AppFonts.titleBold(fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
