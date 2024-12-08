import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';

class AppFonts {
  static TextStyle titleBold({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      height: 1,
      fontWeight: fontWeight,
      color: color,
    );
  }static TextStyle titleBoldOverline({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      decoration:
      TextDecoration.lineThrough,
      decorationColor: Colors.red,
      decorationThickness: 2.0,
      height: 1,
      fontWeight: fontWeight,
      color: color,
    );
  }
  static TextStyle titleRegular({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      height: 1.0,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle titleMedium({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      height: 1.0,
      fontWeight: fontWeight,
      color: color,
    );
  }
  static TextStyle titleMediumUnderLine({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      height: 1.0,
      decoration: TextDecoration.underline,
      decorationColor: color,

      fontWeight: fontWeight,
      color: color,
    );
  }
  static TextStyle hintTitle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textFormFieldHintColor,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      fontWeight: fontWeight,
      color: color,
    );
  }
  static TextStyle appBarTitle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Sukar',
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Add more font styles as needed
  // static TextStyle myCustomFontStyle() { ... }
}
