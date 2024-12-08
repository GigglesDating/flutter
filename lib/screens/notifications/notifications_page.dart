import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends State<NotificationsPage> {
  List<String> userPRofile = [
    'assets/images/user1.png',
    'assets/images/user2.png',
    'assets/images/user3.png',
    'assets/images/user4.png',
    'assets/images/user5.png',
  ];
  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show multi-select dialog

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleTextStyle: AppFonts.titleBold(
            fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
      ),
      body: SingleChildScrollView(


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            height: 120,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: userPRofile.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:  EdgeInsets.only(left: index==0?8:16,right: index==0||index==1||index==2||index==3?0:16),
                  child: GestureDetector(
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
                    child:  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.userProfileBorderColor,width: 2,)
                          ),
                          child: CircleAvatar(
                            backgroundImage:
                            AssetImage(userPRofile[index]),
                            radius:40,
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text('Natuan',style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.tertiary),)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 1,color: Theme.of(context).colorScheme.tertiary,),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Today',style: AppFonts.titleBold(color: Theme.of(context).colorScheme.tertiary),),
          ),
            SizedBox(height: 10,),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: userPRofile.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:  EdgeInsets.all(8),
                  child: GestureDetector(
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
                    child:  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.userProfileBorderColor,width: 2,)
                          ),
                          child: CircleAvatar(
                            backgroundImage:
                            AssetImage(userPRofile[index]),
                            radius:30,
                          ),
                        ),
                        SizedBox(width: 12,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@Natuan Express',style: AppFonts.titleBold(color: Theme.of(context).colorScheme.tertiary,fontSize: 18),),
                            Text('Interest  2h',style: AppFonts.titleRegular(color: Theme.of(context).colorScheme.tertiary,fontSize: 14),)
                          ],
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Yesterday',style: AppFonts.titleBold(color: Theme.of(context).colorScheme.tertiary),),
          ),
            SizedBox(height: 10,),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding:  EdgeInsets.all(8),
                  child: GestureDetector(
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
                    child:  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.userProfileBorderColor,width: 2,)
                          ),
                          child: CircleAvatar(
                            backgroundImage:
                            AssetImage(userPRofile[index]),
                            radius:30,
                          ),
                        ),
                        SizedBox(width: 12,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@Natuan Express',style: AppFonts.titleBold(color: Theme.of(context).colorScheme.tertiary,fontSize: 18),),
                            Text('Interest ',style: AppFonts.titleRegular(color: Theme.of(context).colorScheme.tertiary,fontSize: 14),)
                          ],
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
SizedBox(height: 24,),


        ],),
      ),
    );
  }
}
