import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/submenus/messenger_page.dart';
import 'package:flutter_frontend/utilitis/appColors.dart';
import 'package:flutter_frontend/utilitis/appFonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UserDashboardComponent extends StatefulWidget {
  const UserDashboardComponent({
    Key? key,
  }) : super(key: key);

  @override
  State<UserDashboardComponent> createState() => _UserDashboardComponentState();
}

class _UserDashboardComponentState extends State<UserDashboardComponent> {
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();
  bool isFlag = false;
  var ImageUrl;
  final ImagePicker _picker = ImagePicker();
  var filePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentController.addListener(
      () {
        setState(() {
          isFlag = commentController.text.isNotEmpty;
        });
      },
    );
    commentFocusNode.addListener(() {
      setState(() {
        isFlag = commentFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void showCommentBottomSheet(BuildContext context) async {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
        ),
        isScrollControlled: true,
        backgroundColor: AppColors.white.withOpacity(0.9),
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                        child: Container(
                            width: 80,
                            height: 16,
                            child: SvgPicture.asset(
                              'assets/icons/bottomsheet_top_icon.svg',
                              // color: AppColors.black,
                            ))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Comments',
                            style: AppFonts.titleBold(color: AppColors.black),
                          ),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            // CommentModel comment = comments[index];
                            return ListTile(
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: 0),
                              contentPadding: EdgeInsets.zero,
                              leading: ClipOval(
                                child: Image.asset(
                                    'assets/images/nitanshu_profile_image.png'),
                              ),
                              title: Text('Nitanshu'),
                              titleTextStyle: AppFonts.titleBold(
                                  fontSize: 14, color: AppColors.black),
                              subtitle: Text('i want to be there next time'),
                              subtitleTextStyle: AppFonts.titleMedium(
                                  fontSize: 12, color: AppColors.black),
                              trailing: Icon(
                                Icons.replay,
                                color: AppColors.black,
                              ),
                            );
                          },
                        ),
                        ListTile(
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: 0),
                          contentPadding: EdgeInsets.only(left: 50),
                          leading: ClipOval(
                            child: Image.asset(
                              'assets/images/user2.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          title: Text('sree'),
                          titleTextStyle: AppFonts.titleBold(
                              fontSize: 14, color: AppColors.black),
                          subtitle: Text('see you soon'),
                          subtitleTextStyle: AppFonts.titleMedium(
                              fontSize: 12, color: AppColors.black),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: TextFormField(
                        controller: commentController,
                        focusNode: commentFocusNode,

                        style: AppFonts.titleMedium(color: AppColors.black),

                        cursorHeight: 20,
                        cursorColor: AppColors.black,
                        // maxLength: 10,
                        maxLines: 1,
                        minLines: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {});
                          }
                        },

                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'Post your comment',
                          hintStyle: AppFonts.hintTitle(color: AppColors.black),
                          // suffix: Container(
                          //   width: 40,
                          //   height: 40,
                          //   child: ElevatedButton(
                          //     onPressed: () async {
                          //       // await userProvider.addComment(
                          //       //     widget.postId, _commentController.text);
                          //
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content:
                          //           Text('Comment added successfully!'),
                          //           duration: Duration(seconds: 2),
                          //         ),
                          //       );
                          //
                          //       commentController.clear();
                          //       Navigator.pop(context);
                          //     },
                          //     style: ButtonStyle(
                          //         backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                          //       // fixedSize: WidgetStatePropertyAll(Size(36,24))
                          //     ),
                          //     child:  Icon(Icons.send,color: AppColors.white,),),
                          // ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: AppColors.black,
                            ),
                            onPressed: () {
                              // Handle send button press here
                              String message = commentController.text;
                              if (message.isNotEmpty) {
                                // Send the message
                                print("Sending message: $message");
                                commentController.clear();
                              }
                            },
                          ),

                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.black)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.black)),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.black)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // isFlag
                    //     ? Row(
                    //         mainAxisSize: MainAxisSize.max,
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [
                    //           ElevatedButton(
                    //             onPressed: () async {
                    //               // await userProvider.addComment(
                    //               //     widget.postId, _commentController.text);
                    //
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 SnackBar(
                    //                   content:
                    //                       Text('Comment added successfully!'),
                    //                   duration: Duration(seconds: 2),
                    //                 ),
                    //               );
                    //
                    //               commentController.clear();
                    //               Navigator.pop(context);
                    //             },
                    //             style: ButtonStyle(
                    //               backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
                    //             ),
                    //             child:  Icon(Icons.send,color: AppColors.white,),),
                    //
                    //         ],
                    //       )
                    //     : SizedBox(),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // void handleLike() {
    //   Provider.of<UserProvider>(context, listen: false).likePost(widget.postId);
    // }

    return Stack(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  // BoxShadow(
                  //   color: Colors.grey.withOpacity(0.3),
                  //   offset: const Offset(0, 2),
                  //   blurRadius: 4,
                  //   spreadRadius: 1,
                  // ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.0),
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/feed_image1.png'),
                ),
              ),
            ),
            Positioned(
              // top: 10,
              // bottom: 10,
              // left: 10,
              right: 22,
              // right: 20,
              // bottom: 10,
              // top: 10,
              child: Container(
                width: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: () {
                          // handleLike();
                        },
                        icon: SvgPicture.asset('assets/icons/like_icon.svg'),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                          onPressed: () => showCommentBottomSheet(context),
                          icon: SvgPicture.asset(
                              'assets/icons/comment_icon.svg')),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                          key: _buttonKey,
                          onPressed: () async {
                            // Get button's position
                            showPopupMenu();
                          },
                          icon: SvgPicture.asset('assets/icons/ping_icon.svg')),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 50,
                child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/quotationmark_icon.svg',
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              SizedBox(
                                  width: 40,
                                  child: Divider(
                                      color: AppColors.white,
                                      thickness: 1,
                                      height: 0))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                                // width: 10,
                                // The total width of the divider widget, including spacing
                                // indent: 10,
                                // Optional: adds padding before the divider starts
                                // endIndent:
                                //     10, // Optional: adds padding at the end of the divider
                              ),
                              Text(
                                'if you can change your mind, you can change your life ',
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.titleRegular(
                                    color: AppColors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )))
          ],
        ),
        Positioned(
          left: 40,
          // top: -5,
          child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Theme.of(context).colorScheme.onPrimary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/reel_profile_image.png'),
                        fit: BoxFit.cover)),
              )),
        ),
      ],
    );
  }

  void showPopupMenu() {
    // Get button's position
    final RenderBox button =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(
      button.localToGlobal(Offset.zero, ancestor: overlay).dx, // X position
      button.localToGlobal(Offset.zero, ancestor: overlay).dy -
          button.size.height, // Y position above button
      button.localToGlobal(Offset.zero, ancestor: overlay).dx +
          button.size.width,
      button.localToGlobal(Offset.zero, ancestor: overlay).dy,
    );

    showMenu(
      context: context,
      position: position,

      items: [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.message),
              ),
              SizedBox(
                width: 4,
              ),
              Text("Send Message"),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0,left: 6),
                child: Icon(Icons.report),
              ),
              SizedBox(
                width: 4,
              ),
              Text("Report"),
            ],
          ),
        ),
        // PopupMenuItem<int>(
        //   value: 1,
        //   child: Text("Option 2"),
        // ),
        // PopupMenuItem<int>(
        //   value: 2,
        //   child: Text("Option 3"),
        // ),
      ],
    ).then((value) {
      if (value != null) {
        if (value==1) {
          Fluttertoast.showToast(
              msg: "Reported successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
          // Navigator.pop(context);


        }  else{
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessengerPage(),
              ));
        }

      }
    });
  }
}