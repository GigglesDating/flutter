import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/screens/user/while_waiting_events_page.dart';

class ShowDialog {
  //show Error Dialog
  void showInfoDialogPopUp(
      BuildContext context, String message, void Function() onPressed) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.info,
            color: AppColors.primary,
            size: 56,
          ),
          alignment: Alignment.center,
          content: Text(
            message,
            textAlign: TextAlign.left,
            style: AppFonts.titleMedium(
                color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      // Add rounded corners
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(width: 1, color: AppColors.primary)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style:
                      AppFonts.titleBold(color: AppColors.white, fontSize: 15),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    // Add rounded corners
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  'Confirm',
                  style:
                      AppFonts.titleBold(color: AppColors.white, fontSize: 15),
                )),
          ],
        );
      },
    );
  }

  void showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.info,
            color: AppColors.primary,
            size: 56,
          ),
          alignment: Alignment.center,
          content: Text(
            message,
            textAlign: TextAlign.left,
            style: AppFonts.titleMedium(
                color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    // Add rounded corners
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Ok',
                  style:
                      AppFonts.titleBold(color: AppColors.white, fontSize: 15),
                )),
          ],
        );
      },
    );
  }

  //show Error Dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.error,
            color: AppColors.error,
            size: 56,
          ),
          content: Text(
            message,
            textAlign: TextAlign.left,
            style: AppFonts.titleMedium(
                color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    // Add rounded corners
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Ok',
                  style:
                      AppFonts.titleBold(color: AppColors.white, fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  // show Success Dialog
  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 56,
          ),
          content: Text(
            message,
            textAlign: TextAlign.left,
            style: AppFonts.titleMedium(
                color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    // Add rounded corners
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => WhiteWaitingEventsPage()),
                  // );
                },
                child: Text(
                  'Ok',
                  style:
                      AppFonts.titleBold(color: AppColors.white, fontSize: 15),
                )),
          ],
        );
      },
    );
  }
}
