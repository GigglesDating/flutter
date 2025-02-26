import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserReportSheet extends StatefulWidget {
  final bool isDarkMode;
  final double screenWidth;

  const UserReportSheet({
    super.key,
    required this.isDarkMode,
    required this.screenWidth,
  });

  @override
  State<UserReportSheet> createState() => _UserReportSheetState();
}

class _UserReportSheetState extends State<UserReportSheet> {
  bool bullying = false;
  bool selfinjury = false;
  bool nudity = false;
  bool scam = false;
  bool falseinformation = false;
  bool pretendingtobesomeone = false;
  bool sellingrestricteditems = false;
  bool violenceorhate = false;
  bool userunderage = false;

  final WidgetStateProperty<Color?> trackColor =
      WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(255, 76, 175, 80);
      }
      return null;
    },
  );

  final WidgetStateProperty<Color?> overlayColor =
      WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return Colors.black;
      }
      return null;
    },
  );

  bool isAnyCheckboxSelected() {
    return bullying ||
        selfinjury ||
        nudity ||
        scam ||
        falseinformation ||
        pretendingtobesomeone ||
        sellingrestricteditems ||
        violenceorhate ||
        userunderage;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.black.withAlpha(50)
                  : Colors.white.withAlpha(50),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.white.withAlpha(38)
                    : Colors.black.withAlpha(26),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: widget.screenWidth * 0.02),
                      width: widget.screenWidth * 0.1,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.white.withAlpha(77)
                            : Colors.black.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    ' Report / Block',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: widget.isDarkMode
                            ? Colors.grey[100]
                            : Colors.grey[900]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Spacer(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                bullying = !bullying;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bullying or unwanted contact',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: bullying,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      bullying = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selfinjury = !selfinjury;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Suicide,self-injury',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: selfinjury,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      selfinjury = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                nudity = !nudity;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nudity or sexuality',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: nudity,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      nudity = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                scam = !scam;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Scam, fruad or spam',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: scam,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      scam = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                falseinformation = !falseinformation;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'False information',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: falseinformation,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      falseinformation = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                pretendingtobesomeone = !pretendingtobesomeone;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pretending to be someone else',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: pretendingtobesomeone,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      pretendingtobesomeone = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sellingrestricteditems =
                                    !sellingrestricteditems;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selling or promoting restricted items',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: sellingrestricteditems,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      sellingrestricteditems = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                violenceorhate = !violenceorhate;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Violence, hate or exploitation',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: violenceorhate,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      violenceorhate = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                userunderage = !userunderage;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'The user maybe under 18 years',
                                  style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      fontWeight: FontWeight.w700),
                                ),
                                Checkbox(
                                  checkColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: widget.isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  value: userunderage,
                                  side: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      userunderage = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // spacing: 3,
                        children: [
                          SizedBox(
                            width: 200,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "Blocked",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              backgroundColor:
                                  isDarkMode ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Block',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          ElevatedButton(
                            onPressed: isAnyCheckboxSelected()
                                ? () {
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            "Thank you for your valuable feedback, this will help us keep our community clean.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: widget.isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                        textColor: widget.isDarkMode
                                            ? Colors.grey[900]
                                            : Colors.grey[100],
                                        fontSize: 16.0);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: widget.isDarkMode
                                            ? Colors.black87
                                            : Colors.white,
                                        elevation: 100,
                                        content: Text(
                                            "Would you also preffer to block this account?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                  msg: "Blocked",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      widget.isDarkMode
                                                          ? Colors.grey[100]
                                                          : Colors.grey[900],
                                                  textColor: widget.isDarkMode
                                                      ? Colors.grey[900]
                                                      : Colors.grey[100],
                                                  fontSize: 16.0);
                                            },
                                            child: Text(
                                              "Yes",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No",
                                                  style:
                                                      TextStyle(fontSize: 17))),
                                        ],
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Report',
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
