import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../exercises/views/muscle_group_screen.dart';
import '../../repo/data/home_data.dart';

// ─── internal data model ───────────────────────────────────────────────────
class _DayData {
  const _DayData(this.image, this.muscle, this.pageId, this.title);
  final String image, muscle;
  final String? pageId, title;
}

// ─── main widget ───────────────────────────────────────────────────────────
class ThisWeekList extends StatelessWidget {
  const ThisWeekList({super.key, required this.data});
  final HomeData data;

  static const _plan = [
    _DayData(AppConstants.imgChest, 'الصدر', AppConstants.pageIdChest,
        'تمارين الصدر'),
    _DayData(AppConstants.imgLates, 'الظهر', AppConstants.pageIdLates,
        'تمارين الظهر'),
    _DayData(AppConstants.imgShoulder, 'الكتف', AppConstants.pageIdShoulder,
        'تمارين الكتف'),
    _DayData(AppConstants.imgRest, 'راحة', null, null),
    _DayData(AppConstants.imgHands, 'الذراع', AppConstants.pageIdHands,
        'تمارين الذراع'),
    _DayData(AppConstants.imgLegs, 'الأرجل', AppConstants.pageIdLegs,
        'تمارين الأرجل'),
    _DayData(AppConstants.imgBelly, 'البطن', AppConstants.pageIdBelly,
        'تمارين البطن'),
  ];
  static const _dayNames = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  @override
  Widget build(BuildContext context) {
    final startOffset = data.startWeekday - 1;
    final todayIdx = (DateTime.now().weekday - 1 - startOffset + 7) % 7;
    final completedDays = <int>{};
    for (final r in data.thisWeekHistory) {
      completedDays.add((r.date.weekday - 1 - startOffset + 7) % 7);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              right: AppSpacing.marginMobile, bottom: AppSpacing.xs),
          child: Text('هذا الأسبوع', style: AppTextStyles.labelMuted),
        ),
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            itemCount: _plan.length,
            itemBuilder: (context, i) {
              final d = _plan[i];
              final isToday = i == todayIdx;
              final isDone = completedDays.contains(i);
              final dayName = _dayNames[(i + startOffset) % 7];
              return _WeekCard(
                data: d,
                dayName: dayName,
                isToday: isToday,
                isDone: isDone,
                onTap: d.pageId != null
                    ? () => Navigator.push(
                        context,
                        NavigationUtils.fadeScaleRoute(MuscleGroupScreen(
                          pageId: d.pageId!,
                          title: d.title!,
                          itemCount: 6,
                        )))
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── week card sub-widget ─────────────────────────────────────────────────
class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.data,
    required this.dayName,
    required this.isToday,
    required this.isDone,
    this.onTap,
  });
  final _DayData data;
  final String dayName;
  final bool isToday, isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(data.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.surfaceHigh)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(isDone ? 0.55 : 0.15),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),
          ),
          if (isDone)
            Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.black, size: 15),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Column(children: [
              Text(data.muscle,
                  style: AppTextStyles.labelCaps.copyWith(
                      color: Colors.white, fontSize: 9, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(dayName,
                  style: AppTextStyles.labelMuted.copyWith(
                      color: isToday
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.45),
                      fontSize: 10),
                  textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }
}
