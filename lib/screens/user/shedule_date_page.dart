import 'package:flutter/material.dart';
import 'package:giggles/constants/appFonts.dart';

import '../../constants/appColors.dart';

class SheduleDatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SheduleDatePage();
}

class _SheduleDatePage extends State<SheduleDatePage> {
  String? selectActivity;
  final List<String> selectActivityList = [
    'Gymming',
    'cooking',
    'Singing',
    'Coffee'
    'lunch'
    'Dinner'
    // 'Coffee or beer?',
    // "What's the most interesting thing you've read lately?",
    // "I find you interesting, let’s talk?",
    // "Who made your profile in here?",
    // "You must help make my profile",
    // "Let’s hunt for good restaurants?",
    // "You’re totally my type!",
    // "Maybe we’ll find out more...",
    // "Type your own prompt...",
  ];
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Schedule Date'),
        backgroundColor: AppColors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.white, // Change the back button color here
        ),
        titleTextStyle:
            AppFonts.titleBold(fontSize: 20, color: AppColors.white),
      ),
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: kToolbarHeight,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.8,
                height: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.white),
                child: Icon(
                  Icons.person,
                  size: MediaQuery.of(context).size.width * .5,
                ),
              ),
            ),
            SizedBox(height: 12,),
            Center(
              child: Text(
                'Choose a friend',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.hintTitle(
                    color: AppColors.white, fontSize: 16),
              ),
            ),
            SizedBox(
              height: kToolbarHeight,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 56,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: AppColors.white),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  underline: Text(''),
                  // dropdownColor: AppColors.black,
                  style: AppFonts.hintTitle(color: AppColors.black),
                  itemHeight: 56,
                  icon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: AppColors.black,
                    size: 32,
                  ),
                  value: selectActivity,
                  hint: Text('Please Select',
                      style: AppFonts.hintTitle(
                          color: AppColors.black, fontSize: 15)),
                  iconDisabledColor: AppColors.profileCreateOutlineBorder,
                  iconEnabledColor: AppColors.profileCreateOutlineBorder,
                  isExpanded: true,
                  items: selectActivityList.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        gender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.hintTitle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectActivity = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: ListTile(
                // visualDensity: VisualDensity(horizontal: -4,vertical: -2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                tileColor: AppColors.white,
                title: Text(
                  'Search Venue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppFonts.hintTitle(color: AppColors.black, fontSize: 15),
                ),

                trailing: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () {
                  // Action when a prompt is tapped
                  // print('Selected: ${prompts[index]}');
                },
              ),
            ),

            SizedBox(
              height: kToolbarHeight,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_sharp,
                    color: AppColors.white,
                    size: 80,
                  ),
                  Row(
                    children: [
                      Text(
                        'Request Date',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.hintTitle(
                            color: AppColors.white, fontSize: 20),
                      ),
                      SizedBox(width: 12,),
                      Image.asset(
                        'assets/images/date_booking_arrow_icon.png',
                        width: 60,
                        height: 48,
                      )
                    ],
                  )
                ],
              ),
            )
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: TextFormField(
            //     autocorrect: false,
            //     textAlignVertical: TextAlignVertical.center,
            //     textAlign: TextAlign.start,
            //
            //     // enableSuggestions: false,
            //     style: AppFonts.titleMedium(
            //         color: Theme.of(context).colorScheme.tertiary),
            //     minLines: 3,
            //     maxLines: 3,
            //     keyboardType: TextInputType.text,
            //     maxLength: 300,
            //     // controller: _addressController,
            //     onChanged: (value) {},
            //     decoration: InputDecoration(
            //       // errorMaxLines: 4,
            //       // alignLabelWithHint: true,
            //       hintTextDirection: TextDirection.ltr,
            //       // hintMaxLines: 4,
            //       suffixIcon: IconButton(
            //         icon: Icon(
            //           Icons.send,
            //           color: AppColors.black,
            //         ),
            //         onPressed: () {
            //           String message = commentController.text;
            //           if (message.isNotEmpty) {
            //             // Send the message
            //             print("Sending message: $message");
            //             commentController.clear();
            //           }
            //         },
            //       ),
            //       contentPadding: const EdgeInsets.all(14),
            //       floatingLabelBehavior: FloatingLabelBehavior.never,
            //       border: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(28)),
            //           borderSide: BorderSide(
            //               color: Theme.of(context).colorScheme.tertiary)),
            //       focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(28)),
            //           borderSide: BorderSide(
            //               color: Theme.of(context).colorScheme.primary)),
            //       enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(28)),
            //           borderSide: BorderSide(
            //               color: Theme.of(context).colorScheme.tertiary)),
            //       focusedErrorBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(28)),
            //           borderSide: BorderSide(color: AppColors.error)),
            //       labelText: 'Type your own prompt',
            //       labelStyle: AppFonts.hintTitle(),
            //     ),
            //     validator: (value) {
            //       // if (value!.isEmpty) {
            //       //   return 'Bio is empty';
            //       // }
            //       return null;
            //     },
            //   ),
            // ),
            // SizedBox(
            //   height: 16,
            // ),
          ],
        ),
      ),
    );
  }
}
