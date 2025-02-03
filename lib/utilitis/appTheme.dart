import 'package:flutter/material.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';

final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: Colors.white,
      tertiary: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: AppColors.textFormFieldHintColor, // Light mode hint text color
      ),
      // Additional input decoration settings
    ),
    hintColor: AppColors.textFormFieldHintColor,
    scaffoldBackgroundColor: AppColors.white,
    useMaterial3: true
    // Add other theme properties as needed
    );

final ThemeData darkTheme = ThemeData(
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: AppColors.textFormFieldHintColor, // Light mode hint text color
    ),
    // Additional input decoration settings
  ),
  hintColor: AppColors.textFormFieldHintColor,
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.black,
  // Add other theme properties as needed
);