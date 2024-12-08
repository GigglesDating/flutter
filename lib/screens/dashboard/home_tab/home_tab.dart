import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/screens/messenger/messenger_page.dart';
import 'package:giggles/screens/user/add_to_story_page.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/userDashboardComponent.dart';
import '../../components/userDashboardNavbar.dart';
import '../../notifications/notifications_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> userPRofile = [
    'assets/images/user2.png',
    'assets/images/user3.png',
    'assets/images/user4.png',
    'assets/images/user5.png',
  ];
  File? _croppedImage;
  var ImageUrl;
  final ImagePicker _picker = ImagePicker();
  var filePath;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              // Add Posts
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         CreatePostPage(currentUser: userProvider.user),
              //   ),
              // );
              showImageModalSheet();
            },
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.add_outlined,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : AppColors.black,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => userNotificationPage(),
                //   ),
                // );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ));
              },
              icon: const Icon(
                Icons.notifications,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessengerPage(),
                    ));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => UserInboxPage(),
                //   ),
                // );
              },
              icon: Image(
                image: AssetImage(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/images/inbox_png.png'
                      : 'assets/images/inbox_white_png.png',
                ),
              ),
            ),
          ],
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 28,),
              Image(
                height: 24,
                width: 24,
                image: AssetImage(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/images/logolighttheme.png'
                      : 'assets/images/logodarktheme.png',
                ),
              ),
              Text('iggles'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,

                    children: [

                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.userProfileBorderColor,
                                width: 2,
                              )),
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user1.png'),
                            radius: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 3,
                        // left: 0,
                        right: 2,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: ElevatedButton(
                            onPressed: () {
                              // showImageModalSheet();

                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddToStoryScreen(),));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              // fixedSize: Size(16, 16),
                              padding: EdgeInsets.zero,
                              // Adjust padding as needed
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiary, // Customize color
                            ),
                            child: Center(
                                child: Icon(Icons.add,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.white
                                        : AppColors.black,size: 18,)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 80,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: index == 0 ? 8 : 16,
                              right: index == 0 || index == 1 || index == 2
                                  ? 0
                                  : 16),
                          child: UserDashboardNavbar(
                            imageUrl: userPRofile[index],
                            sizeRadius: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 6,
                itemBuilder: (context, index) {
                  // PostModel post = userProvider.followingPosts[index];
                  // UserModel? author = userProvider.getUserById(post.authorId);
                  return UserDashboardComponent();
                },
              ),
            ),
          ],
        ));
  }

  void showImageModalSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        // constraints: BoxConstraints(maxHeight: 200),
        context: context,
        builder: (builder) {
          return Container(
            decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35.0),
                    topRight: Radius.circular(35.0))),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Add Post',
                        style: AppFonts.titleBold(
                            color: AppColors.black, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 23,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              pickImage(ImageSource.camera);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.1))),
                              height: 91,
                              width: 91,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: SvgPicture.asset(
                                  "assets/icons/camera_icon.svg", width: 40,
                                  height: 36,
                                  // fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 24),
                            child: Text('Camera',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    color: Color(0xff575651),
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              pickImage(ImageSource.gallery);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.1))),
                              height: 91,
                              width: 91,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: SvgPicture.asset(
                                  "assets/icons/gallery_icon.svg",
                                  width: 40,
                                  height: 36,
                                  // fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 24),
                            child: Text('Gallery',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    color: Color(0xff575651),
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  pickImage(ImageSource imageType) async {
    try {
      XFile? pickedImage = await _picker.pickImage(source: imageType);
      if (pickedImage != null) {
        // Crop the picked image
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPresetCustom(),
              ],
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPresetCustom(),
                // IMPORTANT: iOS supports only one custom aspect ratio in preset list
              ],
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        if (croppedImage != null) {
          setState(() {
            _croppedImage = File(croppedImage.path);
          });
        }
      }
      // if (pickedImage == null) {
      //   return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.only(
      //         bottom: MediaQuery.of(context).size.height - 120,
      //         left: 20.0, // Add left margin for spacing
      //         right: 20.0 // Add right margin for spacing
      //     ),
      //     content: const Text('Please Select Image'),
      //   ));
      // } else {
      //   final tempImage = File(pickedImage.path);
      //   setState(() {
      //     ImageUrl = tempImage;
      //   });
      //   setState(() {
      //     filePath = pickedImage.path;
      //   });
      //
      // }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
