import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ReorderableStaggeredGridScreen extends StatefulWidget {
  @override
  _ReorderableStaggeredGridScreenState createState() =>
      _ReorderableStaggeredGridScreenState();
}

class _ReorderableStaggeredGridScreenState
    extends State<ReorderableStaggeredGridScreen> {
  // List of items to be displayed in the grid
  List<int> _items = [0,1,2,3,4,5];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        var row = _items.removeAt(oldIndex);
        _items.insert(newIndex, row);
      });
    }

    return Scaffold(
      body:
      // CustomScrollView(
      //   slivers: [
      //     // SliverToBoxAdapter(child: Container(height: 100, color: Colors.red)),
      //     SliverMasonryGrid.count(
      //         crossAxisCount: 2,
      //         childCount: _items.length,
      //         itemBuilder: (ctx, item) => Padding(
      //               padding: EdgeInsets.all(4),
      //               child: Container(
      //                 height: item == 0 ? (item % 2 + 2) * 120.0 : (item % 1 + 2) * 58.0,
      //                 child: Draggable<int>(
      //                   data: item,
      //                   onDragCompleted: () {},
      //                   // Optional completion logic
      //                   feedback: _buildGridItem(item, isDragging: true),
      //                   childWhenDragging: Container(),
      //                   // Empty container while dragging
      //                   child: DragTarget<int>(
      //                     onAccept: (int receivedItem) {
      //                       setState(() {
      //                         int oldIndex = _items.indexOf(receivedItem);
      //                         int newIndex = _items.indexOf(item);
      //                         // Remove the item from the old index and insert it at the new index
      //                         _items.removeAt(oldIndex);
      //                         _items.insert(newIndex, receivedItem);
      //                         print("Item moved from $oldIndex to $newIndex");
      //                       });
      //                     },
      //
      //
      //                     builder: (context, candidateData, rejectedData) {
      //                       return _buildGridItem(item);
      //                     },
      //                   ),
      //                 )
      //               ),
      //             )),
      //     // SliverToBoxAdapter(child: Container(height: 100, color: Colors.orange)),
      //   ],
      // ),
      StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: _items.map((item) {
          return LongPressDraggable<int>(
            data: item,
            onDragCompleted: () {},
            // Optional completion logic
            feedback: _buildGridItem(item, isDragging: true),
            childWhenDragging: Container(),
            // Empty container while dragging
            child: DragTarget<int>(
              onAccept: (int receivedItem) {
                setState(() {
                  int oldIndex = _items.indexOf(receivedItem);
                  int newIndex = _items.indexOf(item);
                  // Remove the item from the old index and insert it at the new index
                  _items.removeAt(oldIndex);
                  _items.insert(newIndex, receivedItem);
                  print("Item moved from $oldIndex to $newIndex");
                });
              },
              builder: (context, candidateData, rejectedData) {
                return InkWell(
                  onTap: (){
                    _pickImage(item);
                  },
                    child: _buildGridItem(item));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  Future<void> _pickImage(int index) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _items[index] = int.parse(pickedFile.path);
      });
    }}
  Widget _buildGridItem(int item, {bool isDragging = false}){
    return Container(
        // color: isDragging ? Colors.grey[300] : Colors.blue,

        key: ValueKey(item),
        // height: item == 0 ? (item % 2 + 2) * 120.0 : (item % 1 + 2) * 58.0,
        height: (item % 1 + 2) * 58.0,
        child: Stack(
          children: [
            item == 0||item == 1||item == 2||item == 3||item == 4||item == 5?   Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1.0, color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(Icons.add, size: 50),
              ),
            ):Stack(
                              children: [
                                // Display selected image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    _items[item].toString(),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Checkmark overlay when an image is selected
                                if (item == 0)
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
                            ),
            // if (item == 0)
            //   Positioned(
            //     top: 8,
            //     left: 8,
            //     child: SvgPicture.asset(
            //       'assets/icons/green_check_icon.svg',
            //       width: 32,
            //       height: 32,
            //     ),
            //   ),
          ],
        ));
  }

// Widget _buildGridItem(int item, {bool isDragging = false}) {
//   switch (item) {
//     case 0:
//       return StaggeredGridTile.count(
//         crossAxisCellCount: 2,
//         mainAxisCellCount: 2,
//         child: Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: AppColors.error),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Icon(Icons.check_circle, color: Colors.green, size: 24),
//             ),
//           ),
//         ),
//       );
//     case 1:
//       return StaggeredGridTile.count(
//         crossAxisCellCount: 1,
//         mainAxisCellCount: 1,
//         child: BackGroundTile(
//             backgroundColor: Colors.cyan, icondata: Icons.ac_unit),
//       );
//     case 2:
//       return StaggeredGridTile.count(
//         crossAxisCellCount: 1,
//         mainAxisCellCount: 1,
//         child: BackGroundTile(
//             backgroundColor: Colors.pink, icondata: Icons.landscape),
//       );
//     case 3:
//       return StaggeredGridTile.count(
//         crossAxisCellCount: 1,
//         mainAxisCellCount: 1,
//         child: BackGroundTile(
//             backgroundColor: Colors.green, icondata: Icons.portrait),
//       );
//     case 4:
//       return StaggeredGridTile.count(
//         crossAxisCellCount: 1,
//         mainAxisCellCount: 1,
//         child: BackGroundTile(
//             backgroundColor: Colors.orangeAccent, icondata: Icons.portrait),
//       );
//     default:
//       return Container();
//   }
// }
}

class BackGroundTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icondata;

  BackGroundTile({required this.backgroundColor, required this.icondata});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
              width: 1.0, color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(Icons.add, size: 50),
        ),
      ),
    );
  }
}

// DraggableGridViewBuilder(
// gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// crossAxisCount: 2,
// childAspectRatio: MediaQuery.of(context).size.width /
// (MediaQuery.of(context).size.height / 3),
// mainAxisSpacing: 10,
// crossAxisSpacing: 10
// ),
// children: List.generate(
// 6,
// (index) => DraggableGridItem(
// isDraggable: true,
// child: Container(
// decoration: BoxDecoration(
// color: index == 0 ? Colors.orange : Colors.grey[300],
// borderRadius: BorderRadius.circular(12),
// border: Border.all(color: Colors.black12),
// ),
// child: index == 0?StaggeredGridTile.count(
// crossAxisCellCount: 1,
// mainAxisCellCount: 2,
// child:
// BackGroundTile(backgroundColor: Colors.orange, icondata: Icons.ac_unit),
// ):StaggeredGridTile.count(
// crossAxisCellCount: 1,
// mainAxisCellCount: 1,
// child:
// BackGroundTile(backgroundColor: Colors.redAccent, icondata: Icons.ac_unit),
// ),
// ),
// // Use custom sizes to create a staggered effect
// // customSize: index == 0 ? const Size(2, 2) : const Size(1, 1),
// ),
//
// ),
// isOnlyLongPress: false,
// dragCompletion:
// (List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
// print('onDragAccept: $beforeIndex -> $afterIndex');
// },
// dragFeedback: (List<DraggableGridItem> list, int index) {
// return Container(
// child: list[index].child,
// width: 200,
// height: 150,
// );
// },
// dragPlaceHolder: (List<DraggableGridItem> list, int index) {
// return PlaceHolderWidget(
// child: Container(
// color: Colors.white,
// ),
// );
// },
// )
