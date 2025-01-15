import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/constants/utils/show_dialog.dart';
import 'package:giggles/screens/user/while_waiting_events_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../constants/utils/multi_select_dialog.dart';
import '../../models/user_interests_model.dart';
import '../../network/auth_provider.dart';

class UserProfileCreationPage extends StatefulWidget {
  List<UserInterestsData>? userInterestList;

  UserProfileCreationPage({super.key, this.userInterestList});

  @override
  State<UserProfileCreationPage> createState() => _UserProfileCreationPage();
}

class _UserProfileCreationPage extends State<UserProfileCreationPage> {
  bool _isLoading = false;
  final List<String> genderOrientationList = [
    'Straight',
    'Homosexual',
    'Bisexual',
    'Asexual'
  ];

  // List<UserInterestsData> userInterestList = [];
  final data = [1, 2, 3, 4, 5, 6];

  double heightfactor = 1.0;
  final List<String> genderList = ['All', 'Male', 'Female'];
  String? genderOrientation;
  String? datingPreference;
  String? gender;
  var filePath;
  TextEditingController bioTextController = TextEditingController();
  RangeValues _currentRangeValues = const RangeValues(18, 34);
  final List<String> datingPreferenceList = [
    'Companionship',
    'Relationship',
    'Friendship'
  ];
  final List<String> _selectedDatingPrefrencesItems = [];

  // List of options
  final List<String> _options = [
    'Coffee ',
    'Shooping',
    'Clubing',
    'Cinema',
    'Pet Club'
  ];
  bool isYes = false;
  bool isNo = false;

  // List to store selected options
  // List<String> selectedInterest = [];

  // final List<Map<String, dynamic>> userInterestList = [
  //   {"name": "Coffee", "icon": Icons.local_cafe},
  //   {"name": "Shopping", "icon": Icons.shopping_bag},
  //   {"name": "Clubbing", "icon": Icons.local_bar},
  //   {"name": "Cinema", "icon": Icons.movie},
  //   {"name": "Cycling", "icon": Icons.directions_bike},
  //   {"name": "Gymming", "icon": Icons.fitness_center},
  //   {"name": "Hiking", "icon": Icons.hiking},
  //   {"name": "Swimming", "icon": Icons.pool},
  //   {"name": "Pet Club", "icon": Icons.pets},
  //   {"name": "Pottery", "icon": Icons.brush},
  //   {"name": "Cooking", "icon": Icons.kitchen},
  //   {"name": "Karaoke", "icon": Icons.mic},
  //   {"name": "Yoga", "icon": Icons.self_improvement},
  //   {"name": "Book Club", "icon": Icons.menu_book},
  //   {"name": "Long Drive", "icon": Icons.directions_car},
  // ];

  // List images = [null, null, null, null, null,null]; // 3 images max for demo
  final picker = ImagePicker();
  List<File> images = [];
  final int maxGridSize = 6;

  // Function to pick image from gallery or camera
  Future<void> pickImage() async {
    if (images.length < maxGridSize) {
      final List<XFile>? pickedFile = await picker.pickMultiImage();
      if (pickedFile != null) {
        // filePath = pickedFile.path;
        setState(() {
          for (var file in pickedFile) {
            images.add(File(file.path)); // Add each selected file's path
          }
          print(images);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum limit of images reached')),
      );
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final File movedItem = images.removeAt(oldIndex);
      images.insert(newIndex, movedItem);
    });
  }

  // Set to keep track of selected items
  List<String> selectedActivities = [];

  // Method to toggle selection
  void _toggleSelection(String id) {
    setState(() {
      if (selectedActivities.contains(id)) {
        selectedActivities.remove(id);
      } else {
        selectedActivities.add(id);
      }
    });
  }

  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void openMultiSelectDropdown() async {
    final selectedItems = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: datingPreferenceList,
          selectedItems: _selectedDatingPrefrencesItems,
        );
      },
    );

    if (selectedItems != null) {
      setState(() {
        _selectedDatingPrefrencesItems
          ..clear()
          ..addAll(selectedItems);
      });
    }
  }

  List<UserInterestsData>? userInterestList;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   Future.microtask(() async {
  //     // Fetch data when the screen appears
  //     Provider.of<AuthProvider>(context, listen: false)
  //         .fetchUserInterestList()
  //         .then(
  //       (value) {
  //         if (value?.status == true) {
  //           setState(() {
  //             userInterestList = value!.data!;
  //           });
  //         }
  //       },
  //     );
  //   });
  // }

  bool isLoading = true;

  Future<void> saveLastScreen() async {
    await SharedPref.digiScreenSave();
  }

  @override
  void initState() {
    super.initState();
    saveLastScreen();
    fetchUserInterestList();
  }

  Future<void> fetchUserInterestList() async {
    try {
      var value = await Provider.of<AuthProvider>(context, listen: false)
          .fetchUserInterestList();
      if (value?.status == true) {
        setState(() {
          userInterestList = value!.data!;
        });
      }
    } catch (e) {
      // Handle any errors here
      print("Error fetching user interests: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show multi-select dialog

  @override
  Widget build(BuildContext context) {
    final userProfileCreation = context.watch<AuthProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (isBool,didPop){
        // logic
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleTextStyle: AppFonts.titleBold(
              fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender Orientation',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 46,
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
                        spreadRadius: 1, // Spread radius of the shadow
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.profileCreateOutlineBorder
                          : AppColors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      underline: const Text(''),
                      dropdownColor: AppColors.sosbuttonBgColor,
                      style:
                          AppFonts.hintTitle(color: AppColors.sosbuttonBgColor),
                      value: genderOrientation,
                      hint: Text('Select Your Gender',
                          style: AppFonts.hintTitle(
                              color: AppColors.sosbuttonBgColor, fontSize: 14)),
                      iconDisabledColor: AppColors.profileCreateOutlineBorder,
                      iconEnabledColor: AppColors.profileCreateOutlineBorder,
                      isExpanded: true,
                      items: genderOrientationList.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.hintTitle(
                                color: AppColors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          genderOrientation = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Dating Preference',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () => openMultiSelectDropdown(),
                  child: Container(
                    height: 46,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(8),
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
                          spreadRadius: 1, // Spread radius of the shadow
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.profileCreateOutlineBorder
                            : AppColors.white,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedDatingPrefrencesItems.isEmpty
                            ? 'Select Dating Preferences'
                            : _selectedDatingPrefrencesItems.join(", "),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.hintTitle(
                            color: _selectedDatingPrefrencesItems.isEmpty
                                ? AppColors.sosbuttonBgColor
                                : AppColors.white,
                            fontSize: 14),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: DropdownButton<String>(
                    //     underline: Text(''),
                    //     dropdownColor: AppColors.black,
                    //     style:
                    //     AppFonts.hintTitle(color: AppColors.sosbuttonBgColor),
                    //     value: datingPreference,
                    //     hint: Text('Select Your Option',
                    //         style: AppFonts.hintTitle(
                    //             color: AppColors.sosbuttonBgColor, fontSize: 14)),
                    //     iconDisabledColor: AppColors.profileCreateOutlineBorder,
                    //     iconEnabledColor: AppColors.profileCreateOutlineBorder,
                    //     isExpanded: true,
                    //     items: datingPreferenceList.map((String gender) {
                    //       return DropdownMenuItem<String>(
                    //         value: gender,
                    //         child: Text(
                    //           gender,
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style: AppFonts.hintTitle(
                    //               color: AppColors.white, fontSize: 14),
                    //         ),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String? newValue) {
                    //       setState(() {
                    //         datingPreference = newValue;
                    //       });
                    //     },
                    //   ),
                    // ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Gender Preference',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 46,
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
                        spreadRadius: 1, // Spread radius of the shadow
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.profileCreateOutlineBorder
                          : AppColors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      underline: const Text(''),
                      dropdownColor: AppColors.sosbuttonBgColor,
                      style:
                          AppFonts.hintTitle(color: AppColors.sosbuttonBgColor),
                      value: gender,
                      hint: Text('Select Your Option',
                          style: AppFonts.hintTitle(
                              color: AppColors.sosbuttonBgColor, fontSize: 14)),
                      iconDisabledColor: AppColors.profileCreateOutlineBorder,
                      iconEnabledColor: AppColors.profileCreateOutlineBorder,
                      isExpanded: true,
                      items: genderList.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.hintTitle(
                                color: AppColors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          gender = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Age Preference',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.tertiary),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Between ${_currentRangeValues.start.round().toString()} and ${_currentRangeValues.end.round().toString()}',
                        style: AppFonts.titleBold(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      RangeSlider(
                        values: _currentRangeValues,
                        min: 18,
                        max: 60,
                        divisions: 82,
                        activeColor: Theme.of(context).colorScheme.tertiary,
                        inactiveColor: AppColors.profileCreateOutlineBorder,
                        overlayColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.tertiary),
                        labels: RangeLabels(
                          _currentRangeValues.start.round().toString(),
                          _currentRangeValues.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Interests',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                // InkWell(
                //   onTap:(){
                //     setState(() {
                //       _showMultiSelectDialog();
                //     });
                //   },
                //   child: Container(
                //     padding: EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //         border: Border.all(width: 1,color: Theme.of(context).colorScheme.tertiary),
                //         borderRadius: BorderRadius.circular(20)
                //     ),
                //     child: Text(
                //       'Interests: ${_selectedOptions.join(', ')}',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
                // ),
                Container(
                  height: MediaQuery.of(context).size.width / 2,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.tertiary),
                      borderRadius: BorderRadius.circular(20)),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : userInterestList == null || userInterestList!.isEmpty
                          ? const Center(
                              child: Text('No interests found.'),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              physics: const ScrollPhysics(),
                              itemCount: userInterestList?.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                String activity =
                                    userInterestList![index].name.toString();
                                String selectedInterestId =
                                    userInterestList![index].id.toString();
                                bool isSelected = selectedActivities
                                    .contains(selectedInterestId);

                                return GestureDetector(
                                  onTap: () =>
                                      _toggleSelection(selectedInterestId),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            activity,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFonts.fullBold(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Colors.white
                                                        : Colors.black
                                                    : Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Colors.black
                                                        : Colors.white,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 13),
                                          ),
                                        ),
                                        // const SizedBox(width: 4),
                                        // Icon(
                                        //   icon,
                                        //   size: 12,
                                        //   color: isSelected ? Theme.of(context).brightness==Brightness.light?Colors.white:Colors.black :Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,
                                        // ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Bio',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  // autocorrect: false,
                  textAlignVertical: TextAlignVertical.top,
                  // enableSuggestions: false,
                  style: AppFonts.titleMedium(
                      color: Theme.of(context).colorScheme.tertiary),
                  minLines: 4,
                  maxLines: 4,
                  maxLength: 300,
                  // textAlign: TextAlign.start,
                  controller: bioTextController,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    errorMaxLines: 1,
                    hintMaxLines: 1,
                    contentPadding: const EdgeInsets.all(14),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary)),
                    focusedErrorBorder: const OutlineInputBorder(
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
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Photos and Videos',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: ReorderableGridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    // Aspect ratio for images
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    onReorder: reorderImages,
                    children: [
                      for (int index = 0; index < maxGridSize; index++)
                        GestureDetector(
                          key: ValueKey(index),
                          onTap: index == images.length
                              ? pickImage
                              : null, // Pick image on tap if it's the last slot
                          child: index < images.length
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        images[index],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (index ==
                                        0) // Display the checkmark overlay only for the default image
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: SvgPicture.asset(
                                          'assets/icons/green_check_icon.svg',
                                          width: 32,
                                          height: 32,
                                        ),
                                      ),
                                  ],
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, size: 50),
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),

                // Container(
                //     height: MediaQuery.of(context).size.height * 0.35,
                //     child:
                //         ReorderableStaggeredGridScreen()
                //     ReorderableGridView.count(
                //   crossAxisSpacing: 10,
                //   mainAxisSpacing: 10,
                //   crossAxisCount: 3,
                //   children: data.map((e) {
                //     return    Card(
                //       key: ValueKey(e),
                //       child: Text(e.toString()),
                //     );
                //   }
                //    ).toList(),
                //   onReorder: (oldIndex, newIndex) {
                //     setState(() {
                //       final element = data.removeAt(oldIndex);
                //       data.insert(newIndex, element);
                //     });
                //   },
                // )
                // ),
                // Container(
                //   height: MediaQuery.of(context).size.width,
                //   child: GridView.builder(
                //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 2, // Two images per row
                //       childAspectRatio: 1, // Aspect ratio for images
                //       mainAxisSpacing: 10,
                //       crossAxisSpacing: 10,
                //     ),
                //     itemCount: _images.length,
                //     physics: ScrollPhysics(),
                //     shrinkWrap: true,
                //     itemBuilder: (context, index) {
                //       // var item =_images[index];
                //       double heightFactor = (index == 0) ? 2.0 : 1.0; // Double height for the first item
                //       return GestureDetector(
                //         onTap: () => _pickImage(index),
                //         // Open image picker on tap
                //         child: _images[index] == null
                //             ? Container(
                //                 height: 300 * heightFactor,
                //                 decoration: BoxDecoration(
                //                   border: Border.all(
                //                       width: 1.0,
                //                       color:
                //                           Theme.of(context).colorScheme.tertiary),
                //                   borderRadius: BorderRadius.circular(15),
                //                 ),
                //                 child: Center(
                //                   child: Icon(Icons.add, size: 50),
                //                 ),
                //               )
                //             : Stack(
                //                 children: [
                //                   // Display selected image
                //                   ClipRRect(
                //                     borderRadius: BorderRadius.circular(15),
                //                     child: Image.file(
                //                       _images[index]!,
                //                       width: double.infinity,
                //                       height: double.infinity,
                //                       fit: BoxFit.cover,
                //                     ),
                //                   ),
                //                   // Checkmark overlay when an image is selected
                //                   if (index == 0)
                //                     Positioned(
                //                       top: 8,
                //                       left: 8,
                //                       child: SvgPicture.asset(
                //                         'assets/icons/green_check_icon.svg',
                //                         width: 32,
                //                         height: 32,
                //                       ),
                //                     ),
                //                 ],
                //               ),
                //       );
                //     },
                //   ),
                // ),
                // SizedBox(height: 16,),
                Text(
                  'Is this your first application to Giggles?',
                  style: AppFonts.titleBold(
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      checkColor: AppColors.white,
                      activeColor: AppColors.checkboxFillColor,
                      // isError: true,
                      value: isYes,
                      side: const BorderSide(
                          color: AppColors.checkboxFillColor, width: 2),
                      visualDensity:
                          const VisualDensity(horizontal: 1, vertical: -4),
                      onChanged: (value) {
                        setState(() {
                          isYes = value!;
                          isNo = false;
                        });
                      },
                    ),
                    Text('Yes',
                        style: AppFonts.titleBold(
                            color: Theme.of(context).colorScheme.tertiary)),
                    const SizedBox(
                      width: 20,
                    ),
                    Checkbox(
                      checkColor: AppColors.white,
                      activeColor: AppColors.checkboxFillColor,
                      // isError: true,
                      value: isNo,
                      side: const BorderSide(
                          color: AppColors.checkboxFillColor, width: 2),
                      visualDensity:
                          const VisualDensity(horizontal: 1, vertical: -4),
                      onChanged: (value) {
                        setState(() {
                          isNo = value!;
                          isYes = false;
                        });
                      },
                    ),
                    Text('No',
                        style: AppFonts.titleBold(
                            color: Theme.of(context).colorScheme.tertiary)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Center(
                //   child: Container(
                //     height: 46,
                //     //width:MediaQuery.of(context).size.width/2.5,
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: AppColors.primary,
                //         side: BorderSide(
                //           color: Theme.of(context).colorScheme.tertiary,
                //         ),
                //       ),
                //       onPressed: () async {
                //         // Navigator.push(context, MaterialPageRoute(builder: (context) => const WhiteWaitingEventsPage(),));
                //         if (genderOrientation == null) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Select gender orientation');
                //         } else if (_selectedDatingPrefrencesItems.isEmpty) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Select dating preference');
                //         } else if (gender == null) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Select gender preference');
                //         } else if (_currentRangeValues.start
                //             .round()
                //             .toString()
                //             .isEmpty) {
                //           ShowDialog()
                //               .showInfoDialog(context, 'Select minimum age');
                //         } else if (_currentRangeValues.end
                //             .round()
                //             .toString()
                //             .isEmpty) {
                //           ShowDialog()
                //               .showInfoDialog(context, 'Select maximum age');
                //         } else if (selectedActivities.isEmpty) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Please select interest');
                //         } else if (selectedActivities.length < 5) {
                //           print('selectedActivities');
                //           print(selectedActivities);
                //           print(selectedActivities.length);
                //           ShowDialog().showInfoDialog(
                //               context, 'Please select minimum 5 interest');
                //         } else if (bioTextController.text.isEmpty) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Please write about yourself');
                //         } else if (images.isEmpty) {
                //           ShowDialog()
                //               .showInfoDialog(context, 'Please add photos');
                //         } else if (images.length < 3) {
                //           ShowDialog().showInfoDialog(
                //               context, 'Please select minimum 3 photos');
                //         } else if (isYes == false && isNo == false) {
                //           ShowDialog().showInfoDialog(context,
                //               'check the box to clarify Is this your first application to Giigles');
                //         } else {
                //           // List<String> selectPref = _selectedDatingPrefrencesItems.map((item) => item.toString()).toList();
                //           var userProfileMap = {
                //             "gender_orientation": genderOrientation,
                //             "gender_preferences": gender,
                //             "age_min":
                //                 _currentRangeValues.start.round().toString(),
                //             "age_max":
                //                 _currentRangeValues.end.round().toString(),
                //             // "dating_preferencesq": _selectedDatingPrefrencesItems,
                //             // "interests":selectedActivities,
                //             "bio": bioTextController.text,
                //             // 'images': images,
                //             "is_first_time": isYes == true
                //                 ? "True"
                //                 : isNo == true
                //                     ? 'False'
                //                     : null,
                //           };
                //           print('filePath');
                //           print(filePath);
                //           final userProfileCreate =
                //               await userProfileCreation.userProfileCreation(
                //                   userProfileMap,
                //                   images,
                //                   _selectedDatingPrefrencesItems,
                //                   selectedActivities);
                //           if (userProfileCreate?.status == true) {
                //             // final prefs = await SharedPreferences.getInstance();
                //             await SharedPref.eventScreenSave();
                //             // await prefs.setString('lastScreen', 'eventPage');
                //             Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                   builder: (context) =>
                //                       const WhiteWaitingEventsPage(),
                //                 ));
                //             ShowDialog().showSuccessDialog(
                //                 context, userProfileCreation.successMessage);
                //           } else {
                //             ShowDialog().showErrorDialog(
                //                 context, userProfileCreation.errorMessage);
                //           }
                //         }
                //       },
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
                //         child: Text('Submit',
                //             style: AppFonts.titleBold(
                //                 color: AppColors.white, fontSize: 14)),
                //       ),
                //     ),
                //   ),
                // ),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator() // Show loader while loading
                      : Container(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            onPressed: () async {
                              // Disable interactions while loading
                              setState(() {
                                _isLoading = true;
                              });
                              print('gender');
                              print(gender);
                              print(gender.runtimeType);

                              if (genderOrientation == null) {
                                ShowDialog().showInfoDialog(
                                    context, 'Select gender orientation');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (_selectedDatingPrefrencesItems
                                  .isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Select dating preference');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (gender == null) {
                                ShowDialog().showInfoDialog(
                                    context, 'Select gender preference');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (_currentRangeValues.start
                                  .round()
                                  .toString()
                                  .isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Select minimum age');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (_currentRangeValues.end
                                  .round()
                                  .toString()
                                  .isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Select maximum age');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (selectedActivities.isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Please select interest');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (selectedActivities.length < 5) {
                                print('selectedActivities');
                                print(selectedActivities);
                                print(selectedActivities.length);
                                ShowDialog().showInfoDialog(context,
                                    'Please select minimum 5 interest');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (bioTextController.text.isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Please write about yourself');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (images.isEmpty) {
                                ShowDialog().showInfoDialog(
                                    context, 'Please add photos');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (images.length < 3) {
                                ShowDialog().showInfoDialog(
                                    context, 'Please select minimum 3 photos');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (isYes == false && isNo == false) {
                                ShowDialog().showInfoDialog(context,
                                    'check the box to clarify Is this your first application to Giigles');
                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                // API call and navigation logic
                                var userProfileMap = {
                                  "gender_orientation": genderOrientation,
                                  "gender_preferences": gender,
                                  "age_min": _currentRangeValues.start
                                      .round()
                                      .toString(),
                                  "age_max": _currentRangeValues.end
                                      .round()
                                      .toString(),
                                  "bio": bioTextController.text,
                                  "is_first_time":
                                      isYes == true ? "True" : "False",
                                };

                                final userProfileCreate =
                                    await userProfileCreation
                                        .userProfileCreation(
                                  userProfileMap,
                                  images,
                                  _selectedDatingPrefrencesItems,
                                  selectedActivities,
                                );

                                if (userProfileCreate?.status == true) {
                                  await SharedPref.eventScreenSave();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WhileWaitingEventsPage(),
                                    ),
                                  );
                                  ShowDialog().showSuccessDialog(context,
                                      userProfileCreation.successMessage);
                                } else {
                                  ShowDialog().showErrorDialog(context,
                                      userProfileCreation.errorMessage);
                                }

                                setState(() {
                                  _isLoading =
                                      false; // Stop loading after API call
                                });
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Submit',
                                style: AppFonts.titleBold(
                                    color: AppColors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(
                  height: kToolbarHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
