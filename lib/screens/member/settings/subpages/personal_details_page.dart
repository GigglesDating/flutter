import 'package:flutter/material.dart';


class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Detail',
        ),
        titleSpacing: 15,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
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
                      color: const Color.fromARGB(255, 82, 113, 255).withAlpha(30),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: const Color.fromARGB(255, 82, 113, 255),
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text('Premium Membership: 12 days remaining',
                              style: TextStyle(fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white : Colors.black, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  _buildInfoRow('First Name', 'Ramesh', 'Last Name', 'Patel', isDarkMode),
                  const SizedBox(height: 24),
                  _buildInfoRow('DOB', '05/02/1997', 'Aadhar', 'XX4234', isDarkMode),
                  const SizedBox(height: 24),
                  _buildInfoRow('City', 'Bangalore', 'Username', 'Unique102', isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label1, String value1, String label2, String value2, bool isDarkMode) {
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
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),
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
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
