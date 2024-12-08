import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giggles/screens/user/user_likes_page.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/appColors.dart';
import '../../constants/appFonts.dart';
import '../dashboard/home_tab/home_tab.dart';
import '../settingsPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  bool isLiked = false;
  File? _croppedImage;

  ScrollController scrollController = ScrollController();
  final ScrollController outerScrollController = ScrollController();
  final ScrollController innerScrollController = ScrollController();
  TextEditingController bioController =TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() async {
      _image = pickedFile;
      if (pickedFile != null) {
        // Crop the picked image
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
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
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('No Image Selected'),
            );
          },
        );
      }
    });
  }

  // Future<String?> _uploadImage(XFile image) async {
  //   try {
  //     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //     Reference ref =
  //         FirebaseStorage.instance.ref().child('user_images').child(fileName);
  //     UploadTask uploadTask = ref.putFile(File(image.path));
  //     TaskSnapshot taskSnapshot = await uploadTask;
  //     return await taskSnapshot.ref.getDownloadURL();
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  // void _showPickupDialog(String parameter) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       content: Text('Confirm Upload ?'),
  //       actions: <Widget>[
  //         TextButton(
  //           child: Text('Okay'),
  //           onPressed: () async {
  //             if (_image != null) {
  //               String? value = await _uploadImage(_image!);
  //               await Provider.of<UserProvider>(context, listen: false)
  //                   .updateUser('${parameter}', value!);
  //               Navigator.of(ctx).pop();
  //             } else {
  //               print('Some Error');
  //             }
  //             // Navigate to another Page if needed
  //           },
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String calculateAge(String dobStr) {
    DateTime dob = DateFormat('yyyy-MM-dd').parse(dobStr);

    DateTime today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    // Return the age as a string
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      // Light icons for dark theme
      statusBarBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.dark
          : Brightness.light, // For iOS devices
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 8,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  // user!.coverBGurl == ''
                  //     ? Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   color: AppColors.primaryCoverBG,
                  // )
                  //     :
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Image.asset(
                      'assets/images/usert_profile_banner_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                          iconSize: 28,
                          color: AppColors.black,
                          icon: const Icon(
                            Icons.settings,
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       isLiked = !isLiked;
                        //     });
                        //   },
                        //   iconSize: 28,
                        //   color: isLiked
                        //       ? AppColors.likebuttonfillColor
                        //       : AppColors.black,
                        //   icon: Icon(isLiked
                        //       ? Icons.favorite
                        //       : Icons.favorite_outline),
                        // ),
                        Stack(
                          alignment: Alignment.center,
                          // clipBehavior: Clip.none,
                          children: [
                            // Positioned.fill(child: SvgPicture.asset('assets/icons/calendar.svg' ,width: 70,
                            //   height: 70,)),
                            // SvgPicture.asset(
                            //   'assets/icons/calendar.svg', // Replace with your image URL
                            //   width: 44,
                            //   height: 44, // Adjust height as needed
                            //   fit: BoxFit.cover, // Ensures the image covers the area
                            // ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLikesPage()));
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color:
                                AppColors.likebuttonfillColor,
                                size: 36,),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text('20',
                                style: AppFonts.titleBold(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: IconButton(
                      onPressed: () {
                        // _pickImage();
                        _pickImage();
                        // _showPickupDialog('coverBGUrl');
                      },
                      // iconSize: 18,
                      color: Colors.white,
                      icon: SvgPicture.asset(
                        'assets/icons/share_icon.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: InkWell(
                      onTap: () {
                        _pickImage();
                        // _showPickupDialog('imageUrl');
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.profileOutlineColor,
                              width: 2,
                            )),
                        child: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user1.png'),
                            radius: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 100,
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child:
                            SvgPicture.asset('assets/icons/verified_icon.svg')),
                  ),
                  Positioned(
                      bottom: 64,
                      left: 140,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riyaz Khan',
                            style: AppFonts.titleMedium(
                                color: AppColors.white, fontSize: 20),
                            maxLines: 1,
                          ),
                          Text(
                            '@guynexdoor',
                            style: AppFonts.titleRegular(
                                color: AppColors.white, fontSize: 16),
                            maxLines: 1,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            SingleChildScrollView(
              // physics: ScrollPhysics(),
              controller: scrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    controller: innerScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width * 2,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary),
                          bottom: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/birthday_png.png',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${calculateAge('1998-09-20')}',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                height: 16,
                                width: 16,
                                'assets/icons/male_icon.svg',
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.black
                                    : AppColors.white,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text('Male',
                                  style: AppFonts.titleMedium(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: SvgPicture.asset(
                                      'assets/icons/location_icon.svg')),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Jaipur',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                child: const Image(
                                  image: AssetImage(
                                      'assets/images/no_smoking_png.png'),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Container(
                                child: Text(
                                  'Smoking',
                                  style: AppFonts.titleMedium(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/no_smoking_png.png'),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'weed',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.travel_explore,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'user ethincity',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/no_drinking_png.png'),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Drinker',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.height,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              Text(
                                '5.11',
                                style: AppFonts.titleMedium(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Bio:',
                                  style: AppFonts.titleBold(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: (){
                                showBio(context);


                              },
                              child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    shape: BoxShape
                                        .circle, // Makes the container circular
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(
                                      'assets/icons/edit_icon.svg')),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'I can make you coffee healthier. will probably beat you at go-carting and prefer sunset over sunrise anytime',
                          style: AppFonts.titleRegular(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Posts',
                          style: AppFonts.titleBold(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 1.8,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          controller: ScrollController(),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/post1_image.png',
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  fit: BoxFit.cover,
                                  height:
                                      MediaQuery.of(context).size.width / 1.8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Social Accounts',
                          style: AppFonts.titleBold(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 1.8,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          controller: ScrollController(),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Stack(children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/socialmedia_bg.png',
                                    width:
                                        MediaQuery.of(context).size.width / 1.8,
                                    fit: BoxFit.cover,
                                    height:
                                        MediaQuery.of(context).size.width / 1.8,
                                  ),
                                ),
                              ),
                              Positioned(
                                  left: 16,
                                  top:8,
                                  child: SvgPicture.asset(
                                    'assets/icons/instagram_icon.svg',
                                    width: 32,
                                    height: 32,
                                  ))
                            ]);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: kToolbarHeight + kToolbarHeight + 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showBio(BuildContext context) {
    showDialog(
      context: context,
      // useSafeArea: false,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 16),

          title: Text('Edit Bio', style: TextStyle(color: AppColors.black)),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child:  TextFormField(
              autocorrect: false,
              textAlignVertical: TextAlignVertical.top,
              controller: bioController,
              enableSuggestions: false,
              style: AppFonts.titleMedium(
                  color: Theme.of(context).colorScheme.tertiary),
              minLines: 4,
              maxLines: 4,
              keyboardType: TextInputType.text,
              maxLength: 300,
              // textAlign: TextAlign.start,
              // controller: _addressController,
              onChanged: (value) {},
              decoration: InputDecoration(
                errorMaxLines: 1,
                hintMaxLines: 1,
                contentPadding: const EdgeInsets.all(14),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: AppColors.error)),
                hintText: 'Write About Yourself',
                hintStyle: AppFonts.hintTitle(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Bio is empty';
                }
                return null;
              },
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color:AppColors.black)),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Add', style: TextStyle(color: AppColors.black)),
            ),
          ],
        );
      },
    );
  }
}
