import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blocked',
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

          // Blocked Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 1, // Example count
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Nithya K A',
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Blocked on 23/09/24',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Unblock Button
                      TextButton(
                        onPressed: () {
                          // Handle unblock action
                          _showUnblockConfirmation(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.black : Colors.white,
                          foregroundColor: isDarkMode ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child:  Text(
                          'Unblock',
                          style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockConfirmation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        titleTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
        content:  Text(
          'Are you sure you want to unblock this user? They will be able to see your profile and contact you.',
          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: isDarkMode ? Colors.white : Colors.black),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle unblock action
              Navigator.pop(context);
            },
            child: Text('Unblock',style: TextStyle(color:Colors.red),),
          ),
        ],
      ),
    );
  }
}