import 'package:flutter/material.dart';
import 'package:task/features/exercises/views/widget/exercise_list_widget.dart';

class MuscleGroupScreen extends StatelessWidget {
  final String pageId;
  final String title;
  final int itemCount;

  const MuscleGroupScreen({
    super.key,
    required this.pageId,
    required this.title,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExerciseListWidget(
        pageId: pageId,
        itemCount: itemCount,
        text1: title,
      ),
    );
  }
}
