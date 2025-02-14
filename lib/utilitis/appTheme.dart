import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 82, 113, 255),

    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 82, 113, 255),
      onPrimary: Colors.white,

      secondary: Colors.white,
      tertiary: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: const Color.fromARGB(255, 84, 81, 74), // Light mode hint text color
      ),
      // Additional input decoration settings
    ),
    hintColor: const Color.fromARGB(255, 84, 81, 74),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true
    // Add other theme properties as needed
    );

final ThemeData darkTheme = ThemeData(
  primaryColor: const Color.fromARGB(255, 82, 113, 255),
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 82, 113, 255),
    onPrimary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: const Color.fromARGB(255, 84, 81, 74), // Light mode hint text color
    ),
    // Additional input decoration settings
  ),
  hintColor: const Color.fromARGB(255, 84, 81, 74),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  // Add other theme properties as needed
);