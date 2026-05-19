import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/navigation_utils.dart';
import '../models/exercise.dart';
import '../../features/exercises/views/exercise_detail_page.dart';

/// Exercise card shown in list views.
///
/// Previously lib/view/wedget/costom_bosh.dart (`class CustomBosh`).
/// Renamed to ExerciseCard. Import paths updated; no logic changes.
class ExerciseCard extends StatelessWidget {
  final Exercise? exercise;
  final void Function(Exercise)? onAddPressed;

  const ExerciseCard({
    super.key,
    this.onAddPressed,
    this.exercise,
  });

  void _navigateToDetailPage(BuildContext context) {
    Navigator.push(
      context,
      NavigationUtils.slideRightRoute(ExerciseDetailPage(exercise: exercise)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () => _navigateToDetailPage(context),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayLight,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Exercise image with hero animation
              Stack(
                children: [
                  Hero(
                    tag: 'exerciseImage_${exercise!.title}',
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage(exercise!.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      color: Colors.black12,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          exercise!.title,
                          style: AppTextStyles.exerciseTitle,
                        ),
                        Text(
                          exercise!.details,
                          style: AppTextStyles.exerciseDetails,
                        ),
                        if (onAddPressed != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                              ),
                              onPressed: () => onAddPressed!(exercise!),
                              child: const Icon(Icons.add,
                                  color: AppColors.textWhite),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
