
import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';

class SwipeComponent extends StatefulWidget {

  SwipeComponent({
    super.key,
  });

  @override
  State<SwipeComponent> createState() => _SwipeComponentState();
}

class _SwipeComponentState extends State<SwipeComponent> {
  List<String> posts=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // final _cardsController = SwipeableCardsStackController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SwipeableCardsStack(
        //   cardController: _cardsController,
        //   context: context,
        //   items: posts.map((post) {
        //     return ClipRRect(
        //       borderRadius: BorderRadius.circular(22),
        //       child: Container(
        //         height: 200,
        //         width: MediaQuery.of(context).size.width * 0.75,
        //         decoration: BoxDecoration(
        //           color: AppColors.white,
        //           borderRadius: BorderRadius.circular(22),
        //         ),
        //         child: Image.asset(
        //           'assets/images/swipe_image.png',
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     );
        //   }).toList(),
        //   onCardSwiped: (dir, index, widget) {
        //     _cardsController.addItem(
        //       ClipRRect(
        //         borderRadius: BorderRadius.circular(22),
        //         child: Container(
        //           height: 400,
        //           width: MediaQuery.of(context).size.width * 0.75,
        //           decoration: BoxDecoration(
        //             color: AppColors.white,
        //             borderRadius: BorderRadius.circular(22),
        //           ),
        //           child: Center(
        //             child: Text(
        //               'New Post Incoming!',
        //               style: AppFonts.titleMedium().copyWith(
        //                 color: AppColors.black,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        //   enableSwipeUp: true,
        //   enableSwipeDown: false,
        // ),
      ],
    );
  }
}
