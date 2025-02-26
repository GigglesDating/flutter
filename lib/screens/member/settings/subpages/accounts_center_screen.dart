import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/member/settings/subpages/delete_account.dart';
import 'package:flutter_frontend/screens/member/settings/subpages/login_info.dart';
import 'package:flutter_frontend/screens/member/settings/subpages/personal_details_page.dart';

class AccountCenterScreen extends StatelessWidget {
  const AccountCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Accounts Center',
          ),
        ),
        titleSpacing: 0,
        // foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      body: Column(
        spacing: 12,
        children: [
          Divider(
            thickness: 0.5,
            color: isDarkMode ? Colors.white : Colors.black,
            height: 0.5,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalDetailsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person,
                      size: 24,
                      color: isDarkMode ? Colors.white : Colors.black),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Personal Details',
                    style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 15),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginInfoScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.key_outlined,
                      size: 24,
                      color: isDarkMode ? Colors.white : Colors.black),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Login Info',
                    style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 15),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.delete,
                      size: 24, color: const Color.fromARGB(255, 176, 0, 32)),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color.fromARGB(255, 176, 0, 32)),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      color: const Color.fromARGB(255, 176, 0, 32), size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
