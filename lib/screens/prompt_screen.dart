
import 'package:flutter/material.dart';
import 'package:giggles/constants/appFonts.dart';

import '../constants/appColors.dart';

class PromptScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_PromptScreen();

}
class _PromptScreen extends  State<PromptScreen>{
  final List<String> prompts = [
    'Coffee or beer?',
    "What's the most interesting thing you've read lately?",
    "I find you interesting, let’s talk?",
    "Who made your profile in here?",
    "You must help make my profile",
    "Let’s hunt for good restaurants?",
    "You’re totally my type!",
    "Maybe we’ll find out more...",
    "Type your own prompt...",
  ];
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send a Prompt'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleTextStyle: AppFonts.titleBold(
            fontSize: 20, color: Theme.of(context).colorScheme.tertiary),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              itemCount: prompts.length,
              shrinkWrap: true,physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                  child: ListTile(
                    // visualDensity: VisualDensity(horizontal: -4,vertical: -2),
        
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(color: Theme.of(context).colorScheme.tertiary)
                    ),
                    title: Text(
                      prompts[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.tertiary),
                    ),
                    trailing: Icon(Icons.send,color: Theme.of(context).colorScheme.tertiary,),
                    onTap: () {
                      // Action when a prompt is tapped
                      print('Selected: ${prompts[index]}');
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                autocorrect: false,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.start,

                // enableSuggestions: false,
                style: AppFonts.titleMedium(
                    color: Theme.of(context).colorScheme.tertiary),
                minLines: 3,
                maxLines: 3,
                keyboardType: TextInputType.text,
                maxLength: 300,
                // controller: _addressController,
                onChanged: (value) {},
                decoration: InputDecoration(
                  // errorMaxLines: 4,
                  // alignLabelWithHint: true,
                  hintTextDirection: TextDirection.ltr,
                  // hintMaxLines: 4,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send,color: AppColors.black,),
                    onPressed: () {
                      String message = commentController.text;
                      if (message.isNotEmpty) {
                        // Send the message
                        print("Sending message: $message");
                        commentController.clear();
                      }
                    },
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(color: AppColors.error)),
                  labelText: 'Type your own prompt',
                  labelStyle: AppFonts.hintTitle(),
                ),
                validator: (value) {
                  // if (value!.isEmpty) {
                  //   return 'Bio is empty';
                  // }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16,),

          ],
        ),
      ),
    );
  }
}