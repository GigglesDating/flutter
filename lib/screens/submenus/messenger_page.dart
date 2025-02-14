import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../utilitis/appFonts.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({
    super.key,
  });

  @override
  State<MessengerPage> createState() => _MessengerPage();
}

class _MessengerPage extends State<MessengerPage> {
  bool isAkashSwitched = false;
  bool isRiyazSwitched = true;
  bool isMessagesSwitched = true;
  final _controller = SuperTooltipController();

  DraggableScrollableController _draggableScrollableController=DraggableScrollableController();
  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  final WidgetStateProperty<Color?> trackColor =
  WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
      // Track color when the switch is selected.
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(255, 76, 175, 80);
      }
      // Otherwise return null to set default track color
      // for remaining states such as when the switch is
      // hovered, focused, or disabled.
      return null;
    },
  );
  final WidgetStateProperty<Color?> overlayColor =
  WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
      // Material color when switch is selected.
      if (states.contains(MaterialState.selected)) {
        return Colors.amber.withOpacity(0.54);
      }
      // Material color when switch is disabled.
      if (states.contains(WidgetState.disabled)) {
        return Colors.black;
      }
      // Otherwise return null to set default material color
      // for remaining states such as when the switch is
      // hovered, or focused.
      return null;
    },
  );

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
          title: const Text('Messeges'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          titleTextStyle: AppFonts.titleBold(
              fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
        ),

      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              
             color: const Color.fromARGB(255, 34, 97, 96),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24)

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    await _controller.showTooltip();
                  },
                  child: SuperTooltip(
                    controller: _controller,
                    popupDirection: TooltipDirection.down,
                    backgroundColor: Colors.white,
                    showCloseButton: false,
                    // left: 30,
                    // right: 30,
                    // bottom: 200,
                    arrowTipDistance: 20.0,
                    // minimumOutsideMargin: 120,
                    arrowBaseWidth: 20.0,
                    arrowLength: 20.0,
                    borderWidth: 0.0,
                    // constraints: const BoxConstraints(
                    //   minHeight: 0.0,
                    //   maxHeight: 100,
                    //   minWidth: 0.0,
                    //   maxWidth: 100,
                    // ),
                    touchThroughAreaShape: ClipAreaShape.rectangle,
                    touchThroughAreaCornerRadius: 30,
                    // barrierColor: Color.fromARGB(26, 47, 45, 47),
                    content: Container(
                    height: 200,
                      width: MediaQuery.of(context).size.width,
                      child:  Stack(

                        // clipBehavior: Clip.none,
                        // alignment: Alignment.center,
                        children: [
                          // Image section
                          SizedBox(height: 4,),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                              child: Image.asset(
                                'assets/images/cinema_image.png', // Your image asset here
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180, // Adjust height based on need
                              ),
                            ),
                          ),
                          // SizedBox(height: 12),
                          // Location row

                          Positioned(
                            bottom: 10,
                            left: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text(
                                        'Cinepolis, Koramangala',
                                        style: AppFonts.titleBold(fontSize: 18,color: Colors.white)
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Time row
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text(
                                        '6.30 PM',
                                        style: AppFonts.titleMedium(fontSize: 16,color: Colors.white)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    child: CalendarWidget(day: '2',hasProfile: true,),
                  ),
                ),
                // InkWell(
                //   onTap: (){
                //     // showEventCard(context);
                //   },
                //     child: CalendarWidget(day: '2',hasProfile: true,)),
                CalendarWidget(day: '22',hasProfile: true,),
                CalendarWidget(day: '22',hasProfile: true,),
                CalendarWidget(day: ''),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            Text(
              'Messages',
              style: AppFonts.titleBold(fontSize: 20,color: Theme.of(context).colorScheme.tertiary),
            ),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                // This bool value toggles the switch.
                value: isMessagesSwitched,

                onChanged: (value) {
                  setState(() {
                    isMessagesSwitched=value;
                  });
                },
                overlayColor: overlayColor,
                trackColor: trackColor,
                // thumbColor:  WidgetStatePropertyAll(Theme.of(context).brightness==Brightness.light?AppColors.black:AppColors.white),

              ),
            )
          ],),
        ),
        const SizedBox(height: 10,),
        isMessagesSwitched?Expanded(
          child: ListView(
            children: [
              buildChatTile(
                'Akash',
                'Yep, make a group ch...',
                'assets/akash.jpg',
                isAkashSwitched,
                    (value) {
                  setState(() {
                    isAkashSwitched = value;
                  });
                },
                1,
              ),
              buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                1,
              ),buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                0,
              ),buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                1,
              ),buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                0,
              ),buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                0,
              ),buildChatTile(
                'Riyaz',
                'So what are we thinking',
                'assets/riyaz.jpg',
                isRiyazSwitched,
                    (value) {
                  setState(() {
                    isRiyazSwitched = value;
                  });
                },
                0,
              ),
            ],
          ),
        ):SizedBox(),
      ],),
    );
  }


  void showEventCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isDismissible: true,
      isScrollControlled: true, // Make it full screen
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4, // Set initial height of bottom sheet
          minChildSize: 0.25, // Minimum height
          maxChildSize: 1.0, // Maximum height

          controller: _draggableScrollableController,
          builder: (_, controller) {
            return
              Container(
              padding: EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, icon: Icon(Icons.close)),
                  ),
                  SizedBox(height: 4,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    child: Image.asset(
                      'assets/images/cinema_image.png', // Your image asset here
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180, // Adjust height based on need
                    ),
                  ),
                  SizedBox(height: 12),
                  // Location row
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        'Cinepolis, Koramangala',
                        style: AppFonts.titleBold(fontSize: 18,color: Colors.black)
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Time row
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '6.30 PM',
                        style: AppFonts.titleMedium(fontSize: 16,color: Colors.black)
                      ),
                    ],
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }

  // Chat list tile widget
  Widget buildChatTile(String name, String message, String imageUrl,
      bool switchValue, Function(bool) onSwitchChanged, int unreadCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 148, 177, 67),
                  width: 2,
                )),
            child: CircleAvatar(
              backgroundImage:
              AssetImage('assets/images/user1.png'),
              radius: 32,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppFonts.titleBold(fontSize: 20,color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        // This bool value toggles the switch.
                        value: switchValue,

                        onChanged: onSwitchChanged,
                        overlayColor: overlayColor,
                        trackColor: trackColor,
                        // thumbColor:  WidgetStatePropertyAll(Theme.of(context).brightness==Brightness.light?AppColors.black:AppColors.white),

                      ),
                    )
                  ],
                ),
                Text(
                  message,
                  style: AppFonts.titleMedium(fontSize: 15,color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final String day;
  final bool hasProfile;

  CalendarWidget({required this.day, this.hasProfile = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Positioned.fill(child: SvgPicture.asset('assets/icons/calendar.svg' ,width: 70,
        //   height: 70,)),
        SvgPicture.asset(
          'assets/icons/calendar.svg', // Replace with your image URL
          width: 44,
          height: 44, // Adjust height as needed
          fit: BoxFit.cover, // Ensures the image covers the area
        ),
        const SizedBox(height: 8,),
        Text(
            '20',
            style: AppFonts.titleBold(color: Colors.black,fontSize: 15)
        ),
        if(hasProfile)
          Positioned(
            bottom: -5,
            right: -5,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 148, 177, 67),
                    width: 1,
                  )),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user1.png'),
                radius: 10,
              ),
            ),
          ),
      ],
    );
  }
}