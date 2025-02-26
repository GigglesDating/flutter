import 'package:flutter/material.dart';

class Banned extends StatefulWidget {
  const Banned({super.key});

  @override
  State<Banned> createState() => _BannedState();
}

class _BannedState extends State<Banned> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(child: isDarkMode ? Image.asset('assets/dark/bgs/Banned_screen_dark_mode.png'):Image.asset('assets/light/bgs/Banned_screen.png')),
    );
  }
}
