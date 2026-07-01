import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../exercises/views/muscle_group_screen.dart';
import '../../repo/data/home_data.dart';

// ─── internal data model ───────────────────────────────────────────────────
class _WorkoutData {
  const _WorkoutData(this.image, this.muscle, this.pageId,
      this.screenTitle, this.duration, this.calories);
  final String image, muscle;
  final String? pageId, screenTitle;
  final int duration, calories;
}

// ─── main widget ───────────────────────────────────────────────────────────
class TodayHeroCard extends StatelessWidget {
  const TodayHeroCard({super.key, required this.data});
  final HomeData data;

  static const _workouts = [
    _WorkoutData(AppConstants.imgChest,    'عضلات الصدر',   AppConstants.pageIdChest,    'تمارين الصدر',  45, 320),
    _WorkoutData(AppConstants.imgLates,    'عضلات الظهر',   AppConstants.pageIdLates,    'تمارين الظهر',  50, 290),
    _WorkoutData(AppConstants.imgShoulder, 'عضلات الكتفين', AppConstants.pageIdShoulder, 'تمارين الكتف',  40, 260),
    _WorkoutData(AppConstants.imgRest,     'يوم الراحة',    null,                        null,            0,  0),
    _WorkoutData(AppConstants.imgHands,    'عضلات الذراع',  AppConstants.pageIdHands,    'تمارين الذراع', 35, 210),
    _WorkoutData(AppConstants.imgLegs,     'الأرجل',        AppConstants.pageIdLegs,     'تمارين الأرجل', 55, 400),
    _WorkoutData(AppConstants.imgBelly,    'عضلات البطن',   AppConstants.pageIdBelly,    'تمارين البطن',  30, 180),
  ];

  @override
  Widget build(BuildContext context) {
    final startOffset = data.startWeekday - 1;
    final todayIdx    = (DateTime.now().weekday - 1 - startOffset + 7) % 7;
    final today       = _workouts[todayIdx];
    final isRest      = today.pageId == null;

    return GestureDetector(
      onTap: (!isRest && !data.trainedToday)
          ? () => Navigator.push(
          context,
          NavigationUtils.fadeScaleRoute(MuscleGroupScreen(
            pageId: today.pageId!,
            title: today.screenTitle!,
            itemCount: 6,
          )))
          : null,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surfaceHigh,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            today.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2438), Color(0xFF0B0F1A)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.78),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
          if (data.trainedToday && !isRest)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.38),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 48),
                    const SizedBox(height: 8),
                    Text('أحسنت — تمرين اليوم مكتمل',
                        style: AppTextStyles.headingSmall
                            .copyWith(color: AppColors.success)),
                  ]),
                ),
              ),
            ),
          if (!data.trainedToday || isRest)
            Positioned(
              bottom: 24, left: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRest ? 'اليوم' : 'تمرين اليوم',
                    style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    today.muscle,
                    style: AppTextStyles.headlineHero.copyWith(
                      color: Colors.white,
                      shadows: [Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      )],
                    ),
                    textAlign: TextAlign.end,
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _MetaChip(
                            icon: Icons.local_fire_department_rounded,
                            label: '${today.calories} سعرة'),
                        const SizedBox(width: 8),
                        _MetaChip(
                            icon: Icons.timer_outlined,
                            label: '${today.duration} دقيقة'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StartCTA(
                        onTap: () => Navigator.push(
                          context,
                          NavigationUtils.fadeScaleRoute(MuscleGroupScreen(
                            pageId: today.pageId!,
                            title: today.screenTitle!,
                            itemCount: 6,
                          )),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('استرح — جسدك يتعافى الآن',
                            style: AppTextStyles.labelCaps.copyWith(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

// ─── helper sub-widgets ────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white.withOpacity(0.85), size: 13),
      const SizedBox(width: 4),
      Text(label,
          style: AppTextStyles.labelCaps.copyWith(
              color: Colors.white.withOpacity(0.85), fontSize: 11)),
    ]),
  );
}

class _StartCTA extends StatelessWidget {
  const _StartCTA({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text('ابدأ التمرين',
            style: AppTextStyles.labelCaps
                .copyWith(color: Colors.white, fontSize: 13)),
      ]),
    ),
  );
}