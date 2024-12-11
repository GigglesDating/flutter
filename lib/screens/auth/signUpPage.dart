import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/constants/utils/snackbar_popup.dart';
import 'package:giggles/screens/auth/privacy.dart';
import 'package:giggles/screens/auth/terms_and_condition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/auth_provider.dart';
import 'aadhar_verification/adhar_verification_page.dart';

class SignUPPage extends StatefulWidget {
  SignUPPage({
    super.key,
  });

  @override
  State<SignUPPage> createState() => _SignUPPage();
}

class _SignUPPage extends State<SignUPPage> {
  final signupFormKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  ThemeMode _themeMode = ThemeMode.system;

  Future<void> saveLastScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastScreen', 'otpVerified');
  }

  @override
  void initState() {
    super.initState();
    saveLastScreen();
  }

  String? _gender;
  String? city;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> cityList = [
    'Bangalore',
    'Mumbai',
    'Pune',
    'Chennai',
    'Jaipur',
    'Noida',
    'Delhi',
    'Hyderabad',
    'Ahmedabad',
    'Lucknow',
    'Mysore',
    'Kolkata'
  ];
  DateTime? _selectedDate;
  bool isAgree = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _toggleThemeMode() {
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    if (_image == null) {
      _showErrorDialog('Please Pick an Image');
      return false;
    }
    if (emailController.text.isEmpty) {
      _showErrorDialog('Email cannot be empty');
      return false;
    }

    if (firstNameController.text.isEmpty) {
      _showErrorDialog('First Name cannot be empty');
      return false;
    }
    if (lastNameController.text.isEmpty) {
      _showErrorDialog('Last Name cannot be empty');
      return false;
    }

    return true;
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to another Page if needed
            },
          ),
        ],
      ),
    );
  }

  void _clear() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
  }

  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Future<String?> _uploadImage(File image) async {
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String filePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 500,
      maxWidth: 500,
      // cropStyle: CropStyle.circle,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/signupscreenbg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                child: Form(
                  key: signupFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // SizedBox(height: kToolbarHeight,),
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.width / 2.5,
                          width: MediaQuery.of(context).size.width / 2.5,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.white,
                                  // Theme.of(context).brightness ==
                                  //         Brightness.light
                                  //     ? AppColors.white
                                  //     : AppColors.black,
                                  width: 2)),
                          child: Image.asset(
                            'assets/images/logodarktheme.png',

                            // Theme.of(context).brightness == Brightness.light
                            //     ? 'assets/images/logodarktheme.png'
                            //     : 'assets/images/logolighttheme.png',
                            // height: 150,
                            // width: 150,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: kToolbarHeight,
                      ),
                      SizedBox(
                        height: kToolbarHeight,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              keyboardType: TextInputType.text,
                              enableSuggestions: false,
                              autocorrect: false,
                              inputFormatters: <TextInputFormatter>[
                                // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z ]')),
                              ],
                              style:
                                  AppFonts.titleMedium(color: AppColors.white),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: -4),
                                hintText: 'First Name',
                                hintStyle:
                                    AppFonts.hintTitle(color: AppColors.white),
                                filled: true,
                                fillColor: AppColors.signUpTextFieldColor,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                enabledBorder: const OutlineInputBorder(
                                  // Border when enabled
                                  borderSide:
                                      BorderSide(color: AppColors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                  borderSide:
                                      BorderSide(color: AppColors.error),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an first name';
                                }
                                // final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                // if (!emailRegex.hasMatch(value)) {
                                //   return 'Enter a valid email';
                                // }
                                return null; // No error
                              },
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              keyboardType: TextInputType.text,
                              inputFormatters: <TextInputFormatter>[
                                // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z ]')),
                              ],
                              style:
                                  AppFonts.titleMedium(color: AppColors.white),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: -4),
                                hintText: 'Last Name',
                                hintStyle:
                                    AppFonts.hintTitle(color: AppColors.white),
                                filled: true,
                                fillColor: AppColors.signUpTextFieldColor,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                    borderSide:
                                        BorderSide(color: AppColors.white)),
                                enabledBorder: const OutlineInputBorder(
                                  // Border when enabled
                                  borderSide:
                                      BorderSide(color: AppColors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                  borderSide:
                                      BorderSide(color: AppColors.error),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an last name';
                                }
                                return null; // No error
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      TextFormField(
                        controller: emailController,
                        style: AppFonts.titleMedium(color: AppColors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email address";
                          } else if (!RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Email',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: -4),
                          hintStyle: AppFonts.hintTitle(color: AppColors.white),
                          filled: true,
                          fillColor: AppColors.signUpTextFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(color: AppColors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(color: AppColors.white),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            borderSide: BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 48,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: AppColors.signUpTextFieldColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  // Shadow color
                                  // Shadow color
                                  offset: const Offset(0, 2),
                                  // Offset of the shadow
                                  blurRadius: 4,
                                  // Blur radius of the shadow
                                  spreadRadius:
                                      1, // Spread radius of the shadow
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton<String>(
                                dropdownColor: AppColors.black,
                                underline: Text(''),
                                hint: Text(
                                  'Gender',
                                  style: AppFonts.hintTitle(
                                      color: AppColors.white),
                                ),
                                style:
                                    AppFonts.hintTitle(color: AppColors.white),
                                value: _gender,
                                iconDisabledColor: AppColors.white,
                                iconEnabledColor: AppColors.white,
                                isExpanded: true,
                                items: _genderOptions.map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: AppFonts.hintTitle(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _gender = newValue;
                                  });
                                },
                              ),
                            ),
                          )),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.signUpTextFieldColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    // Shadow color
                                    offset: const Offset(0, 2),
                                    // Offset of the shadow
                                    blurRadius: 4,
                                    // Blur radius of the shadow
                                    spreadRadius:
                                        1, // Spread radius of the shadow
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.white,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedDate == null
                                            ? 'Birthday'
                                            : "${_selectedDate!.toLocal()}"
                                                .split(' ')[0],
                                        style: AppFonts.hintTitle(
                                            color: AppColors.white,
                                            fontSize: 14),
                                      ),
                                      Icon(
                                        Icons.calendar_month,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: AppColors.signUpTextFieldColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    // Shadow color
                                    // Shadow color
                                    offset: const Offset(0, 2),
                                    // Offset of the shadow
                                    blurRadius: 4,
                                    // Blur radius of the shadow
                                    spreadRadius:
                                        1, // Spread radius of the shadow
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.white,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  menuMaxHeight:
                                      MediaQuery.of(context).size.width / 2,
                                  underline: Text(''),
                                  dropdownColor: AppColors.black,
                                  style: AppFonts.hintTitle(
                                      color: AppColors.white),
                                  value: city,
                                  hint: Text('City',
                                      style: AppFonts.hintTitle(
                                          color: AppColors.white,
                                          fontSize: 14)),
                                  iconDisabledColor: AppColors.white,
                                  iconEnabledColor: AppColors.white,
                                  isExpanded: true,
                                  items: cityList.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(
                                        gender,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.hintTitle(
                                            color: AppColors.white,
                                            fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      city = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isAgree = !isAgree;
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  checkColor: AppColors.white,
                                  activeColor: AppColors.checkboxFillColor,
                                  value: isAgree,
                                  side: BorderSide(
                                    color: AppColors.checkboxFillColor,
                                    width: 2,
                                  ),
                                  visualDensity: VisualDensity(
                                      horizontal: 1, vertical: -4),
                                  onChanged: (value) {
                                    setState(() {
                                      isAgree = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'I agree to verify myself\nwith aadhar',
                                  style: AppFonts.titleRegular(
                                      color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'By using this application you agree with our ',
                            ),
                            TextSpan(
                              text: 'Terms of use',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TermsPrivacyScreen(),
                                      ));
                                },
                            ),
                            TextSpan(
                                text: ' & ',
                                recognizer: TapGestureRecognizer()),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivacyPolicy(),
                                      ));
                                },
                            ),
                          ],
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Checkbox(
                      //       checkColor: AppColors.white,
                      //       activeColor: AppColors.checkboxFillColor,
                      //       // isError: true,
                      //       value: isAgree,
                      //       side: BorderSide(
                      //           color: AppColors.checkboxFillColor, width: 2),
                      //       visualDensity:
                      //           VisualDensity(horizontal: 1, vertical: -4),
                      //       onChanged: (value) {
                      //         setState(() {
                      //           isAgree = value!;
                      //         });
                      //       },
                      //     ),
                      //     Text('I agree to verify myself\nwith aadhar',
                      //         style:
                      //             AppFonts.titleRegular(color: AppColors.white))
                      //   ],
                      // ),
                      SizedBox(
                        height: 22,
                      ),
                      Center(
                        child: Container(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // minimumSize: Size(250, 50),
                              // padding: EdgeInsets.symmetric(horizontal: 16),
                              // visualDensity: VisualDensity(horizontal: 16),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            onPressed: userProvider.isLoading
                                ? null
                                : () async {
                                    if (signupFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      if (_gender == null) {
                                        ShowDialog().showInfoDialog(
                                            context, 'Select Gender');
                                      } else if (city == null) {
                                        ShowDialog().showInfoDialog(
                                            context, 'Select City');
                                      } else if (_selectedDate == null) {
                                        ShowDialog().showInfoDialog(
                                            context, 'Select DOB');
                                      } else if (isAgree == false) {
                                        ShowDialog().showInfoDialog(
                                            context, 'Agree the Terms');
                                      } else {
                                        var signUpMap = {
                                          'first_name':
                                              firstNameController.text,
                                          'email': emailController.text,
                                          'last_name': lastNameController.text,
                                          'dob': DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate!),
                                          'city': city,
                                          'gender': _gender,
                                          'is_agree': isAgree,
                                        };
                                        print('signUpMap');
                                        print(signUpMap);
                                        final success = await userProvider
                                            .signUp(signUpMap);
                                        print(success);
                                        print(success.runtimeType);
                                        print(success?.message);
                                        if (success?.status == true) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AadharVerificationPage(),
                                              ));
                                        } else {
                                          // SnackBarHelper.showSuccess(context, message: userProvider.errorMessage);
                                          ShowDialog().showErrorDialog(context,
                                              userProvider.errorMessage);
                                        }
                                      }
                                    } else {
                                      // _showErrorDialog('userProvider.errorMessage');
                                    }
                                  },
                            child: userProvider.isLoading
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 0),
                                    child: Text(
                                      'JOIN',
                                      style: AppFonts.titleBold(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: kToolbarHeight,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
