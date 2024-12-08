import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';

import 'package:giggles/constants/appFonts.dart';

class authPage extends StatefulWidget {
  const authPage({super.key});

  @override
  State<authPage> createState() => _authPageState();
}

class _authPageState extends State<authPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Container(
              //   height: 500,
              //   width: MediaQuery.of(context).size.width,
              //   child: SmartFaceCamera(
              //     autoCapture: true,
              //     defaultCameraLens: CameraLens.front,
              //     message: 'Center your face in the square',
              //     onCapture: (File? image) {},
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Shadow color
                        // Shadow color
                        offset: const Offset(0, 2), // Offset of the shadow
                        blurRadius: 4, // Blur radius of the shadow
                        spreadRadius: 1, // Spread radius of the shadow
                      ),
                    ],
                  ),
                  child: TextFormField(
                    style: AppFonts.titleMedium(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: Colors.black,
                      ),
                      labelText: 'Addar Number',
                      labelStyle: AppFonts.hintTitle(),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100, 50),
                  // TODO: do not hardcode colors - use theming instead!
                  foregroundColor: Colors.black, // foreground (text) color
                  backgroundColor: Colors.white, // background color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => authPage(),
                    ),
                  );
                },
                child: Text(
                  'Request OTP',
                  style: AppFonts.titleBold(),
                ),
              ),
              SizedBox(
                height: 22,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      // TODO: do not hardcode colors - use theming instead!
                      foregroundColor: Colors.black, // foreground (text) color
                      backgroundColor: Colors.white, // background color
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => authPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Resend OTP',
                      style: AppFonts.titleBold(),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      // TODO: do not hardcode colors - use theming instead!
                      foregroundColor: Colors.black, // foreground (text) color
                      backgroundColor: Colors.white, // background color
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => authPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Verify OTP',
                      style: AppFonts.titleBold(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
