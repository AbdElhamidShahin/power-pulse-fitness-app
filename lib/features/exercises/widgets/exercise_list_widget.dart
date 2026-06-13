import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/models/fetch_exercises.dart';
import '../../../shared/widgets/exercise_card.dart';
import '../../../core/ui/components/pp_empty_state.dart';

class ExerciseListWidget extends StatelessWidget {
  const ExerciseListWidget({
    super.key,
    required this.pageId,
    required this.itemCount,
    this.text1,
    this.text,
    this.image,
    this.onAddPressed,
  });

  final String pageId;
  final int itemCount;
  final String? text1, text, image;
  final void Function(Exercise)? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Exercise>>>(
      future: fetchExercisesFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('خطأ في تحميل التمارين', style: AppTextStyles.bodyMuted)),
          );
        }
        final exercises = (snapshot.data?[pageId] ?? []).take(itemCount).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsible hero header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(text1 ?? '', style: AppTextStyles.appBarTitleSmall),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(right: 20, bottom: 14),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(AppConstants.backgroundImage, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceHigh)),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.3), AppColors.background],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Exercise count badge ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm, AppSpacing.marginMobile, AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text('${exercises.length} تمارين', style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Exercise list ────────────────────────────────────────────
              exercises.isEmpty
                  ? SliverFillRemaining(
                      child: Center(child: Text('لا توجد تمارين', style: AppTextStyles.bodyMuted)),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ExerciseCard(exercise: exercises[i], onAddPressed: onAddPressed),
                        childCount: exercises.length,
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.md)),
            ],
          ),
        );
      },
    );
  }
}
