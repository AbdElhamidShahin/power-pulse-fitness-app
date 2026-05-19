import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/models/fetch_exercises.dart';
import '../../../shared/widgets/exercise_card.dart';

/// Fetches exercises by [pageId] from JSON and renders them in a list.
///
/// Previously lib/model/json/GetExerciseList.dart (`class Exerciselistwidget`).
/// Updated import paths; no logic changes.
class ExerciseListWidget extends StatelessWidget {
  final String pageId;
  final String? text;
  final String? image;
  final String? text1;
  final int itemCount;
  final void Function(Exercise)? onAddPressed;

  const ExerciseListWidget({
    super.key,
    required this.pageId,
    required this.itemCount,
    this.onAddPressed,
    this.text,
    this.image,
    this.text1,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Exercise>>>(
      future: fetchExercisesFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading exercises: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          final exercises =
              (snapshot.data![pageId] ?? []).take(itemCount).toList();

          return Scaffold(
            body: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(38),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConstants.backgroundImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 80,
                          width: double.infinity,
                          decoration:
                              BoxDecoration(color: Colors.black.withOpacity(0.5)),
                          child: Center(
                            child: Text(
                              text1 ?? '',
                              style: AppTextStyles.exerciseListHeader,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              return ExerciseCard(
                                exercise: exercises[index],
                                onAddPressed: onAddPressed,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
