
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:giggles/constants/appFonts.dart';

class SnackBarHelper {
  static void showSuccess(
      BuildContext context, {
        required String message,
      }) {
    final snackBar = AwesomeSnackbarContent(
      title: 'Success',
      message: message,
      inMaterialBanner: true,
      contentType: ContentType.success,
      titleTextStyle: AppFonts.titleRegular(color: Theme.of(context).colorScheme.tertiary,fontSize: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: snackBar,
        duration: Duration(seconds: 1), // Automatically close after 3 seconds
      ),
    );
  }
}