import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeInitial() || HomeLoading() => const _LoadingView(),
            HomeError(:final message)      => _ErrorView(message: message),
            HomeLoaded(:final summary)     => RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Greeting ─────────────────────────────
                    _GreetingHeader(
                      greeting: summary.greeting,
                      name: summary.profile.name,
                    ),
                    const SizedBox(height: 16),

                    // ─── Streak Card (داكنة) ───────────────────
                    _StreakCard(streak: summary.currentStreak),
                    const SizedBox(height: 12),

                    // ─── Calories + Active Time ────────────────
                    Row(
                      children: [
                        // Calories — فاتحة يسار
                        Expanded(
                          child: _CaloriesCard(
                            calories: summary.caloriesConsumed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Active Time — داكنة يمين
                        Expanded(
                          child: _ActiveTimeCard(
                            minutes: summary.todayWorkoutMinutes,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Daily Goals ───────────────────────────
                    _DailyGoalsCard(
                      calories: summary.caloriesConsumed,
                      caloriesGoal: summary.caloriesGoal,
                      protein: summary.dailyNutrition.totalProtein,
                      minutes: summary.todayWorkoutMinutes.toDouble(),
                    ),
                    const SizedBox(height: 20),

                    // ─── Quick Access ──────────────────────────
                    _SectionLabel(label: 'الوصول السريع'),
                    const SizedBox(height: 12),
                    _QuickAccessGrid(),
                    const SizedBox(height: 20),

                    // ─── Today's Workout ───────────────────────
                    _SectionLabel(label: 'تمرين اليوم'),
                    const SizedBox(height: 12),
                    _TodayWorkoutCard(),
                  ],
                ),
              ),
            ),
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Greeting Header
// ══════════════════════════════════════════════════════════════
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.greeting, required this.name});
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar داكن
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.bgDark,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
        ),

        // Greeting text — RTL
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Color(0xFF8A8A8A),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$name 💪',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Streak Card
// ══════════════════════════════════════════════════════════════
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final progress = (streak / 30).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ─── يسار: Ring ─────────────────────────────────
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _RingPainter(
                    progress: progress,
                    color: AppColors.accent,
                    trackColor: const Color(0xFF333333),
                    strokeWidth: 5,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // ─── يمين: 🔥 + Text ─────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      const Text(
                        'CURRENT STREAK',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$streak يوم',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textOnDark,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Calories Card (فاتحة)
// ══════════════════════════════════════════════════════════════
class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.calories});
  final double calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'السعرات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Color(0xFF8A8A8A),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${calories.toInt()}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const Text(
            'سعرة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Active Time Card (داكنة)
// ══════════════════════════════════════════════════════════════
class _ActiveTimeCard extends StatelessWidget {
  const _ActiveTimeCard({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'وقت النشاط',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Color(0xFF888888),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$minutes',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              height: 1.0,
            ),
          ),
          const Text(
            'دقيقة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Daily Goals Card — Triple Ring
// ══════════════════════════════════════════════════════════════
class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({
    required this.calories,
    required this.caloriesGoal,
    required this.protein,
    required this.minutes,
  });

  final double calories;
  final double caloriesGoal;
  final double protein;
  final double minutes;

  @override
  Widget build(BuildContext context) {
    // نضيف minimum progress عشان الـ ring يظهر دايماً
    final moveProgress     = caloriesGoal > 0
        ? (calories / caloriesGoal).clamp(0.05, 1.0)
        : 0.05;
    final exerciseProgress = (minutes / 60).clamp(0.05, 1.0);
    final standProgress    = (protein / 150).clamp(0.05, 1.0);

    final moveGoal     = caloriesGoal > 0 ? caloriesGoal.toInt() : 600;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY GOALS',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8A8A),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // ─── Triple Ring ──────────────────────────────
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الخارجي - أخضر (حركة)
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _RingPainter(
                        progress: moveProgress,
                        color: AppColors.accent,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 7,
                      ),
                    ),
                    // الوسط - أحمر (تمرين)
                    CustomPaint(
                      size: const Size(62, 62),
                      painter: _RingPainter(
                        progress: exerciseProgress,
                        color: AppColors.danger,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 6,
                      ),
                    ),
                    // الداخلي - أزرق (وقوف)
                    CustomPaint(
                      size: const Size(46, 46),
                      painter: _RingPainter(
                        progress: standProgress,
                        color: AppColors.info,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // ─── Stats ────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    _GoalRow(
                      dot: AppColors.accent,
                      label: 'MOVE',
                      value: calories.toInt(),
                      goal: moveGoal,
                    ),
                    const SizedBox(height: 10),
                    _GoalRow(
                      dot: AppColors.danger,
                      label: 'EXERCISE',
                      value: minutes.toInt(),
                      goal: 60,
                    ),
                    const SizedBox(height: 10),
                    _GoalRow(
                      dot: AppColors.info,
                      label: 'STAND',
                      value: protein.toInt(),
                      goal: 150,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.dot,
    required this.label,
    required this.value,
    required this.goal,
  });

  final Color dot;
  final String label;
  final int value;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // القيمة
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Cairo'),
            children: [
              TextSpan(
                text: '$value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: dot,
                ),
              ),
              TextSpan(
                text: '/$goal',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDDDDDD),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Label + dot
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Quick Access Grid
// ══════════════════════════════════════════════════════════════
class _QuickAccessGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _QAItem('🥗', 'التغذية', 'تتبع وجباتك',   const Color(0xFFE8F5E9), '/nutrition'),
      _QAItem('📈', 'تقدمي',   'عرض الإحصائيات', const Color(0xFFE3F2FD), '/progress'),
      _QAItem('👤', 'حسابي',   'البيانات الشخصية',const Color(0xFFFFF3E0), '/profile'),
      _QAItem('🏋️', 'التمارين','استعرض المكتبة', const Color(0xFFFCE4EC), '/exercises'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: items.map((item) => GestureDetector(
        onTap: () => context.go(item.route),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.sublabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _QAItem {
  const _QAItem(this.emoji, this.label, this.sublabel, this.color, this.route);
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final String route;
}

// ══════════════════════════════════════════════════════════════
// Today's Workout Card
// ══════════════════════════════════════════════════════════════
class _TodayWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '⚡ قوة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          const Text(
            'قوة الجزء العلوي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Stats
          Row(
            children: const [
              _WorkoutStat(emoji: '🕐', label: '45 دقيقة'),
              SizedBox(width: 14),
              _WorkoutStat(emoji: '🔥', label: '~380 سعرة'),
              SizedBox(width: 14),
              _WorkoutStat(emoji: '💪', label: '6 تمارين'),
            ],
          ),
          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 8,
            children: ['بنش برس', 'عقلة', '+4'].map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Start Button
          GestureDetector(
            onTap: () => context.go('/workout-logger'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'ابدأ التمرين ←',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Section Label
// ══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8A8A8A),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Ring Painter
// ══════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 6,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, math.pi * 2, false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ══════════════════════════════════════════════════════════════
// Loading / Error
// ══════════════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.danger, size: 48),
        const SizedBox(height: 16),
        Text(message, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.read<HomeCubit>().load(),
          child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
        ),
      ],
    ),
  );
}
