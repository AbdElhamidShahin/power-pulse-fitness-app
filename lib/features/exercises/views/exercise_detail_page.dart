import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/exercise.dart';

/// Detailed view of a single exercise with hero animation.
///
/// Previously lib/view/views/ExerciseDetailPage.dart — same logic, updated imports.
class ExerciseDetailPage extends StatelessWidget {
  final Exercise? exercise;

  const ExerciseDetailPage({super.key, this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hero image
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Hero(
                  tag: 'exerciseImage_${exercise!.title}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(exercise!.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                exercise!.title,
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),

              // Details card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  exercise!.details,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'التعليمات',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: exercise!.instructions.map((instruction) {
                  return Text(
                    instruction,
                    style: AppTextStyles.exerciseDetails.copyWith(
                      color: Colors.grey[300],
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            'انهاء',
            style: AppTextStyles.headingSmall
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
