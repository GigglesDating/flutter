import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';

class AppButton {
  static ElevatedButton button(Color color, String text, double,
      void Function() onTap, Color textColor, BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          fixedSize: Size(MediaQuery.of(context).size.width, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: AppFonts.titleBold(color: textColor, fontSize: 18),
        ));
  }

  static ElevatedButton buttonwithIcon(Color color, String text, double,
      void Function() onTap, Color textColor, BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          fixedSize: Size(MediaQuery.of(context).size.width, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,style: AppFonts.titleBold(color: textColor, fontSize: 18),),
            SizedBox(width: 8), // Spacing between icon and text
            Icon(Icons.info,color: AppColors.white,), // Your desired icon


          ],
        ));
  }
}
