import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/item_provider.dart';
import '../widgets/exercise_list_widget.dart';

/// Generic muscle-group exercise screen with "add to my plan" functionality.
///
/// Previously there were 6 near-identical files in lib/view/screens/Screen Add/:
///   • chest_ScreenAdd.dart
///   • lates_ScrreenAdd.dart
///   • shorterScreenAdd.dart
///   • handsScreenAdd.dart
///   • legScreenAdd.dart
///   • beilyScreenAdd.dart
///
/// All 6 are replaced by this single parameterized widget.
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
