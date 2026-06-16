import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/features/exercises/views/widget/exercise_list_widget.dart';
import '../../../shared/providers/item_provider.dart';

class MuscleGroupAddScreen extends StatelessWidget {
  final String pageId;
  final String title;
  final int? itemCount;

  const MuscleGroupAddScreen({
    super.key,
    required this.pageId,
    required this.title,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExerciseListWidget(
        pageId: pageId,
        itemCount: itemCount ?? 30,
        text1: title,
        onAddPressed: (item) {
          Provider.of<ItemProvider>(context, listen: false)
              .addItem(pageId, item);
        },
      ),
    );
  }
}
