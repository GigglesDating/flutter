import 'package:flutter/material.dart';


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
          style: TextStyle(color: textColor, fontSize: 18),
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
            Text(text,style: TextStyle(color: textColor, fontSize: 18),),
            SizedBox(width: 8), // Spacing between icon and text
            Icon(Icons.info,color: Colors.white,), // Your desired icon


          ],
        ));
  }
}