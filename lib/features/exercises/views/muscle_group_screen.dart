import 'package:flutter/material.dart';
import '../widgets/exercise_list_widget.dart';

/// Generic muscle-group exercise screen.
///
/// Previously there were 6 identical files each hardcoding a different pageId:
///   • chest_Screen.dart    → pageId: 'chest'
///   • lates_Screen.dart    → pageId: 'lates'
///   • sholder_Screen.dart  → pageId: 'shorter'
///   • hands_screen.dart    → pageId: 'hands'
///   • Legs_Screen.dart     → pageId: 'legs'
///   • beilyScreen.dart     → pageId: 'beily'
///
/// All 6 are now replaced by this single parameterized widget.
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
