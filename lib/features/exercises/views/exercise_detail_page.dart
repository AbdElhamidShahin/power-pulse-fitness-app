import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../shared/models/exercise.dart';

class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({super.key, this.exercise});
  final Exercise? exercise;

  @override
  Widget build(BuildContext context) {
    final ex = exercise;
    if (ex == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.sm + 8),
        child: PpButton(label: 'إنهاء', onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Hero image ─────────────────────────────────────────────────
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.42,
              child: Hero(
                tag: 'exerciseImage_${ex.title}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusXl)),
                      child: Image.asset(ex.image, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.fitness_center, color: AppColors.outline, size: 64),
                        ),
                      ),
                    ),
                    // gradient bottom fade
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusXl)),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, AppColors.background],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(ex.title, style: AppTextStyles.headlineLgMobile, textAlign: TextAlign.end),
                  const SizedBox(height: AppSpacing.sm),

                  // Details card
                  PpCard(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('وصف التمرين', style: AppTextStyles.labelPrimary),
                            const SizedBox(width: 6),
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(ex.details, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.7), textAlign: TextAlign.end, textDirection: TextDirection.rtl),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Instructions
                  PpCard(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('خطوات التنفيذ', style: AppTextStyles.labelPrimary),
                            const SizedBox(width: 6),
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(Icons.list_alt_rounded, color: AppColors.success, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...ex.instructions.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                                    child: Text(
                                      e.value,
                                      style: AppTextStyles.bodyMd.copyWith(
                                          color: AppColors.textSecondary, height: 1.65),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 26, height: 26,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: AppTextStyles.labelCaps.copyWith(
                                            color: AppColors.primary, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
