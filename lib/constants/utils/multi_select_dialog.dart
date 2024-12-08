import 'package:flutter/material.dart';
import 'package:giggles/constants/appColors.dart';
import 'package:giggles/constants/appFonts.dart';
class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  MultiSelectDialog({required this.items, required this.selectedItems});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Items',style: AppFonts.titleBold(fontSize: 24,color:  Theme.of(context).colorScheme.tertiary),),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.map((item) {
            return CheckboxListTile(
              title: Text(item,style:  AppFonts.titleMedium(color:  Theme.of(context).colorScheme.tertiary),),
              checkColor: AppColors.white,
              // fillColor: WidgetStatePropertyAll(AppColors.primary),
              activeColor: AppColors.primary,
              value: _tempSelectedItems.contains(item),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _tempSelectedItems.add(item);
                  } else {
                    _tempSelectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',style: AppFonts.titleBold(color:  AppColors.primary),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelectedItems),
          child: Text('OK',style: AppFonts.titleBold(color: AppColors.primary),),
        ),
      ],
    );
  }
}