// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../utilitis/appFonts.dart';

class Userlikeyouswipeablecomponent extends StatefulWidget {
  @override
  _Userlikeyouswipeablecomponent createState() =>
      _Userlikeyouswipeablecomponent();
}

class _Userlikeyouswipeablecomponent
    extends State<Userlikeyouswipeablecomponent> {
  final List<String> images = [
    'https://picsum.photos/250?image=9',
    'https://picsum.photos/250?image=10',
    'https://picsum.photos/250?image=11',
    'https://picsum.photos/250?image=12',
    'https://picsum.photos/250?image=13',
    'https://picsum.photos/250?image=14',
  ];
  void _removeImage(String imageUrl) {
    setState(() {
      images.remove(imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tinder Swipe Grid Demo"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return UserlikeSwipeableCard(
            key:
                ValueKey(images[index]), // Ensures unique widget for each image
            imageUrl: images[index],
            onLiked: () => _removeImage(images[index]), // Remove by URL
            onDisliked: () => _removeImage(images[index]), // Remove by URL
          );
        },
      ),
    );
  }
}

class UserlikeSwipeableCard extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onLiked;
  final VoidCallback onDisliked;
  UserlikeSwipeableCard({
    required this.imageUrl,
    required this.onLiked,
    required this.onDisliked,
    Key? key,
  }) : super(key: key);
  @override
  _SwipeableCardState createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<UserlikeSwipeableCard> {
  late MatchEngine _matchEngine;
  late SwipeItem _swipeItem;
  bool _isSwiped = false; // Prevents multiple triggers
  @override
  void initState() {
    super.initState();
    _swipeItem = SwipeItem(
      content: widget.imageUrl,
      likeAction: () {
        if (!_isSwiped) {
          _isSwiped = true; // Mark as swiped
          widget.onLiked();
        }
      },
      nopeAction: () {
        if (!_isSwiped) {
          _isSwiped = true; // Mark as swiped
          widget.onDisliked();
        }
      },
    );
    _matchEngine = MatchEngine(swipeItems: [_swipeItem]);
  }

  @override
  Widget build(BuildContext context) {
    return SwipeCards(
      likeTag:
          const Icon(Icons.check_box_rounded, size: 60, color: Colors.green),
      nopeTag: const Icon(Icons.close, size: 48, color: Colors.red),
      matchEngine: _matchEngine,
      itemBuilder: (context, index) {
        return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Display selected image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/liked_you image.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Checkmark overlay when an image is selected

                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: Text(
                    'Aditi Rao',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18),
                  )),
                ),
              ],
            ));
      },
      onStackFinished: () {
        print("No more items");
      },
    );
  }
}
