import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReportSheet extends StatefulWidget {
  final bool isDarkMode;
  final double screenWidth;

  const ReportSheet({
    super.key,
    required this.isDarkMode,
    required this.screenWidth,
  });

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  bool isDatingEveryOne = false;
  bool justdontlikeit = false;
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

  @override
  Widget build(BuildContext context) {
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
                    ' Report and Block the user',
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
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: Card(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                    msg: "Reported successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              },
                              child: Text(
                                "Report",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                              )),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 20, top: 10),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "I just don't like it",
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: justdontlikeit,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    justdontlikeit = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bullying or unwanted contact',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: bullying,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    bullying = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suicuide,self-injury',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: selfinjury,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    selfinjury = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nudity or sexuality',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: nudity,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    nudity = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scam, fruad or spam',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: scam,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    scam = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'False information',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: falseinformation,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    falseinformation = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pretending to be someone else',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: pretendingtobesomeone,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    pretendingtobesomeone = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selling or promoting restricted items',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: sellingrestricteditems,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    sellingrestricteditems = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Violence, hate or exploitation',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: violenceorhate,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    violenceorhate = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'The user maybe under 18 years',
                                style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                              ),
                              Checkbox(
                                checkColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                activeColor: widget.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                // isError: true,
                                value: userunderage,
                                side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),

                                onChanged: (value) {
                                  setState(() {
                                    userunderage = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
