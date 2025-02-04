import 'package:flutter/material.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';




class UserDashboardNavbar extends StatefulWidget {
  String imageUrl;
  double sizeRadius;

  UserDashboardNavbar({super.key,required this.imageUrl,required this.sizeRadius});



  @override
  State<UserDashboardNavbar> createState() => _UserDashboardNavbar();
}

class _UserDashboardNavbar extends State<UserDashboardNavbar> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => datingProfilePage(
        //
        //     ),
        //   ),
        // );
      },
      child:  Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.userProfileBorderColor,width: 2,)
        ),
        child: CircleAvatar(
          backgroundImage:
          AssetImage(widget.imageUrl),
          radius: widget.sizeRadius,
        ),
      ),
    );
  }
}