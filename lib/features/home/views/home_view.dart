import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../exercises/views/muscle_group_screen.dart';

/// HOME SCREEN
///
/// Now reads REAL data from UserProfileService:
///   - Real streak (from stored last workout date)
///   - Streak-at-risk state (trained yesterday but not today)
///   - Today's workout based on actual start weekday preference
///   - Weekly completion state from real workout history
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Reload streak data when screen is shown (in case user just completed)
  @override
  void initState() {
    super.initState();
    // No async needed — UserProfileService is already initialized in main()
  }

  @override
  Widget build(BuildContext context) {
    final svc         = UserProfileService.instance;
    final streak      = svc.currentStreak;
    final atRisk      = svc.daysSinceLastWorkout == 1 && !svc.trainedToday;
    final trainedToday = svc.trainedToday;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HomeHeader(trainedToday: trainedToday),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: _TodayHero(trainedToday: trainedToday),
          ),

          const SizedBox(height: AppSpacing.lg),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: _StreakLine(
              streak: streak,
              atRisk: atRisk,
              trainedToday: trainedToday,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _ThisWeek(),

          SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER — time-aware greeting, no emoji
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.trainedToday});
  final bool trainedToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.sm,
          AppSpacing.marginMobile, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_dateLabel(), style: AppTextStyles.labelMuted),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_greeting(), style: AppTextStyles.labelMuted),
              const SizedBox(height: 2),
              Text(
                trainedToday ? 'تمرين اليوم مكتمل' : 'لنبدأ التدريب',
                style: AppTextStyles.headlineMd.copyWith(
                  color: trainedToday
                      ? AppColors.success
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'مساء النشاط';
    return 'مساء الخير';
  }

  String _dateLabel() {
    const days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final now = DateTime.now();
    return '${days[now.weekday % 7]} · ${now.day}/${now.month}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TODAY'S HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.trainedToday});
  final bool trainedToday;

  static const _workouts = [
    _WorkoutData(AppConstants.imgChest,    'عضلات الصدر',   AppConstants.pageIdChest,    'تمارين الصدر',   45, 320),
    _WorkoutData(AppConstants.imgLates,    'عضلات الظهر',   AppConstants.pageIdLates,    'تمارين الظهر',   50, 290),
    _WorkoutData(AppConstants.imgShoulder, 'عضلات الكتفين', AppConstants.pageIdShoulder, 'تمارين الكتف',   40, 260),
    _WorkoutData(AppConstants.imgRest,     'يوم الراحة',    null,                        null,              0,  0),
    _WorkoutData(AppConstants.imgHands,    'عضلات الذراع',  AppConstants.pageIdHands,    'تمارين الذراع',  35, 210),
    _WorkoutData(AppConstants.imgLegs,     'الأرجل',        AppConstants.pageIdLegs,     'تمارين الأرجل',  55, 400),
    _WorkoutData(AppConstants.imgBelly,    'عضلات البطن',   AppConstants.pageIdBelly,    'تمارين البطن',   30, 180),
  ];

  @override
  Widget build(BuildContext context) {
    // Use saved start weekday preference to offset the weekly plan
    final startOffset = UserProfileService.instance.startWeekday - 1;
    final todayIdx    = (DateTime.now().weekday - 1 - startOffset + 7) % 7;
    final today       = _workouts[todayIdx];
    final isRest      = today.pageId == null;

    return GestureDetector(
      onTap: (!isRest && !trainedToday)
          ? () => Navigator.push(context, NavigationUtils.fadeScaleRoute(
                MuscleGroupScreen(
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
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

            // Cinematic gradient overlay
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

            // Trained today overlay
            if (trainedToday && !isRest)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.38),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.success, size: 48),
                      const SizedBox(height: 8),
                      Text('أحسنت — تمرين اليوم مكتمل',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.success)),
                    ]),
                  ),
                ),
              ),

            // Content
            if (!trainedToday || isRest)
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
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      today.muscle,
                      style: AppTextStyles.headlineHero.copyWith(
                        color: Colors.white,
                        shadows: [Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12, offset: const Offset(0, 2),
                        )],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (!isRest) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _MetaChip(icon: Icons.local_fire_department_rounded,
                              label: '${today.calories} سعرة'),
                          const SizedBox(width: 8),
                          _MetaChip(icon: Icons.timer_outlined,
                              label: '${today.duration} دقيقة'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _StartCTA(
                          onTap: () => Navigator.push(context,
                            NavigationUtils.fadeScaleRoute(MuscleGroupScreen(
                              pageId: today.pageId!,
                              title: today.screenTitle!,
                              itemCount: 6,
                            ))),
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
          ],
        ),
      ),
    );
  }
}

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
      Text(label, style: AppTextStyles.labelCaps.copyWith(
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
        boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text('ابدأ التمرين', style: AppTextStyles.labelCaps.copyWith(
            color: Colors.white, fontSize: 13)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STREAK LINE — real data, no container, no border
// Just the number + message as visual weight
// ─────────────────────────────────────────────────────────────────────────────
class _StreakLine extends StatelessWidget {
  const _StreakLine({
    required this.streak,
    required this.atRisk,
    required this.trainedToday,
  });

  final int streak;
  final bool atRisk, trainedToday;

  @override
  Widget build(BuildContext context) {
    final color = atRisk
        ? AppColors.warning
        : trainedToday
            ? AppColors.success
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPaddingLg,
          vertical: AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (atRisk)
                  Text(
                    'سلسلتك على المحك',
                    style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.warning, fontSize: 10,
                        letterSpacing: 1.5),
                  )
                else
                  Text(
                    trainedToday ? 'تدربت اليوم' : 'السلسلة الحالية',
                    style: AppTextStyles.labelMuted,
                  ),
                const SizedBox(height: 4),
                Text(
                  UserProfileService.streakMessage(streak, atRisk: atRisk),
                  style: AppTextStyles.headingSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: AppTextStyles.displayHero.copyWith(color: color),
              ),
              Text(
                UserProfileService.streakDayLabel(streak),
                style: AppTextStyles.labelMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THIS WEEK — compact scroll, real completion state
// ─────────────────────────────────────────────────────────────────────────────
class _ThisWeek extends StatelessWidget {
  static const _plan = [
    _DayData(AppConstants.imgChest,    'الصدر',  AppConstants.pageIdChest,    'تمارين الصدر'),
    _DayData(AppConstants.imgLates,    'الظهر',  AppConstants.pageIdLates,    'تمارين الظهر'),
    _DayData(AppConstants.imgShoulder, 'الكتف',  AppConstants.pageIdShoulder, 'تمارين الكتف'),
    _DayData(AppConstants.imgRest,     'راحة',   null, null),
    _DayData(AppConstants.imgHands,    'الذراع', AppConstants.pageIdHands,    'تمارين الذراع'),
    _DayData(AppConstants.imgLegs,     'الأرجل', AppConstants.pageIdLegs,     'تمارين الأرجل'),
    _DayData(AppConstants.imgBelly,    'البطن',  AppConstants.pageIdBelly,    'تمارين البطن'),
  ];
  static const _dayNames = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  @override
  Widget build(BuildContext context) {
    final svc         = UserProfileService.instance;
    final startOffset = svc.startWeekday - 1;
    final todayIdx    = (DateTime.now().weekday - 1 - startOffset + 7) % 7;

    // Build a set of weekday indices that had a workout this week
    final completedDays = <int>{};
    for (final r in svc.thisWeekHistory) {
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
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            itemCount: _plan.length,
            itemBuilder: (context, i) {
              final d = _plan[i];
              final isToday = i == todayIdx;
              final isDone  = completedDays.contains(i);
              final dayName = _dayNames[
                (i + startOffset) % 7
              ];
              return _WeekCard(
                data: d,
                dayName: dayName,
                isToday: isToday,
                isDone: isDone,
                onTap: d.pageId != null
                    ? () => Navigator.push(context,
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
          Image.asset(data.image, fit: BoxFit.cover,
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
          // Done checkmark
          if (isDone)
            Center(
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.black, size: 15),
              ),
            ),
          // Labels
          Positioned(
            bottom: 8, left: 0, right: 0,
            child: Column(children: [
              Text(data.muscle,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: Colors.white, fontSize: 9, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
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

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _WorkoutData {
  const _WorkoutData(this.image, this.muscle, this.pageId,
      this.screenTitle, this.duration, this.calories);
  final String image, muscle;
  final String? pageId, screenTitle;
  final int duration, calories;
}

class _DayData {
  const _DayData(this.image, this.muscle, this.pageId, this.title);
  final String image, muscle;
  final String? pageId, title;
}
