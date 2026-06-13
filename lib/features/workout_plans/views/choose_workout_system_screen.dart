import 'package:flutter/material.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import 'five_day_split_screen.dart';
import 'push_pull_legs_screen.dart';
import 'your_exercise_screen.dart';

/// ChooseWorkoutSystemScreen — now uses onboarding data to recommend a system.
///
/// Reads fitnessLevel from UserProfileService and surfaces ONE recommended
/// system as primary. Others remain available but secondary.
/// A product with opinions earns trust.
class ChooseWorkoutSystemScreen extends StatelessWidget {
  const ChooseWorkoutSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final level = UserProfileService.instance.fitnessLevel;
    final goal  = UserProfileService.instance.fitnessGoal;

    // Recommendation logic — based on onboarding level
    final recommended = _recommendedSystem(level);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpBackBar(title: 'أنظمة التمرين'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left:   AppSpacing.marginMobile,
          right:  AppSpacing.marginMobile,
          top:    AppSpacing.sm,
          bottom: AppSpacing.bottomNavHeight + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Coaching context — uses their actual goal
            if (goal.isNotEmpty) ...[
              Text(
                'بناءً على هدفك: $goal',
                style: AppTextStyles.labelMuted,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],

            // Recommended system — primary CTA prominence
            _RecommendedBanner(
              system:    recommended,
              onStart:   () => _navigate(context, recommended.index),
            ),

            const SizedBox(height: AppSpacing.md),

            // Other options — secondary, lower visual weight
            Text(
              'أنظمة أخرى',
              style: AppTextStyles.labelMuted,
            ),
            const SizedBox(height: AppSpacing.xs),

            ..._allSystems
                .where((s) => s.index != recommended.index)
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _SecondarySystemCard(
                        system:  s,
                        onTap:   () => _navigate(context, s.index),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  _SystemData _recommendedSystem(String level) {
    // Beginner → PPL is simplest 3-day split
    // Intermediate → PPL with more volume
    // Advanced → 5 Day Split for isolation
    // No level → default PPL
    if (level == 'متقدم') return _allSystems[1]; // Five Day
    return _allSystems[0]; // PPL for beginners + intermediate
  }

  void _navigate(BuildContext context, int index) {
    final Widget page;
    switch (index) {
      case 0: page = const PushPullLegsScreen();  break;
      case 1: page = const FiveDaySplitScreen();  break;
      default: page = YourExersize();
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a,
                child: ScaleTransition(
                    scale: Tween(begin: 0.97, end: 1.0).animate(
                        CurvedAnimation(parent: a, curve: Curves.easeOut)),
                    child: child)),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECOMMENDED BANNER — primary visual weight
// ─────────────────────────────────────────────────────────────────────────────
class _RecommendedBanner extends StatelessWidget {
  const _RecommendedBanner({
    required this.system,
    required this.onStart,
  });

  final _SystemData system;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Recommended label
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'مُوصى به لك',
                  style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.primary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // System name + icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(system.title,
                      style: AppTextStyles.headlineMd),
                  const SizedBox(height: 3),
                  Text(system.subtitle,
                      style: AppTextStyles.labelMuted),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: system.color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(system.icon, color: system.color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          Text(
            system.description,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: AppSpacing.sm),

          PpButton(
            label: 'ابدأ ${system.title}',
            onPressed: onStart,
            height: 48,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECONDARY SYSTEM CARD — lower visual weight
// ─────────────────────────────────────────────────────────────────────────────
class _SecondarySystemCard extends StatelessWidget {
  const _SecondarySystemCard({
    required this.system,
    required this.onTap,
  });

  final _SystemData system;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Directionality(textDirection: TextDirection.rtl, child: Icon(Icons.chevron_right_rounded,
                color: AppColors.outline, size: 13)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(system.title,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(system.subtitle,
                    style: AppTextStyles.labelMuted),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: system.color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(system.icon, color: system.color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
class _SystemData {
  const _SystemData(
      this.index, this.title, this.subtitle, this.description,
      this.icon, this.color);
  final int index;
  final String title, subtitle, description;
  final IconData icon;
  final Color color;
}

const _allSystems = [
  _SystemData(
    0,
    'دفع - سحب - أرجل',
    'Push Pull Legs',
    'تقسيم فعّال إلى ثلاثة محاور. '
    'مناسب للمبتدئين والمتوسطين. 3 أيام / أسبوع.',
    Icons.sync_alt_rounded,
    AppColors.primary,
  ),
  _SystemData(
    1,
    'نظام 5 أيام',
    'Five Day Split',
    'يوم مخصص لكل مجموعة عضلية. '
    'للمتقدمين الراغبين في أعلى تركيز. 5 أيام / أسبوع.',
    Icons.calendar_today_rounded,
    AppColors.success,
  ),
  _SystemData(
    2,
    'النظام الخاص',
    'Custom System',
    'ابنِ روتينك الأسبوعي بنفسك. '
    'أضف أي تمرين لأي يوم بحرية كاملة.',
    Icons.tune_rounded,
    AppColors.warning,
  ),
];
