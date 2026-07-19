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
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  // ✅ RTL: كل العناصر تبدأ من اليمين
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    // ─── Greeting ──────────────────────────
                    _GreetingHeader(
                      greeting: summary.greeting,
                      name: summary.profile.name,
                    ),
                    const SizedBox(height: 16),

                    // ─── Streak Card ───────────────────────
                    _StreakCard(streak: summary.currentStreak),
                    const SizedBox(height: 12),

                    // ─── Stats Row: وقت النشاط + السعرات ──
                    Row(
                      children: [
                        // ✅ وقت النشاط — داكن (يمين في RTL)
                        Expanded(
                          child: _ActiveTimeCard(
                              minutes: summary.todayWorkoutMinutes),
                        ),
                        const SizedBox(width: 12),
                        // ✅ السعرات — فاتح (يسار في RTL)
                        Expanded(
                          child: _CaloriesCard(
                              calories: summary.caloriesConsumed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Daily Goals ───────────────────────
                    _DailyGoalsCard(
                      calories: summary.caloriesConsumed,
                      caloriesGoal: summary.caloriesGoal,
                      protein: summary.dailyNutrition.totalProtein,
                      minutes: summary.todayWorkoutMinutes.toDouble(),
                    ),
                    const SizedBox(height: 20),

                    // ─── Quick Access ──────────────────────
                    _SectionLabel(label: 'الوصول السريع'),
                    const SizedBox(height: 12),
                    _QuickAccessGrid(),
                    const SizedBox(height: 20),

                    // ─── Today's Workout ───────────────────
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
// Greeting Header — ✅ RTL: أفاتار يسار | نص يمين
// ══════════════════════════════════════════════════════════════
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.greeting, required this.name});
  final String greeting, name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ أفاتار يسار (في RTL يظهر على اليسار)
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              color: AppColors.bgDark, shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 18,
                fontWeight: FontWeight.w900, color: AppColors.textOnDark,
              ),
            ),
          ),
        ),

        // ✅ النص يمين
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                color: AppColors.textMuted, letterSpacing: 0.3,
              ),
            ),
            Text(
              '💪 $name',
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 26,
                fontWeight: FontWeight.w900, color: AppColors.textPrimary,
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
// Streak Card — بطاقة السلسلة الداكنة
// ✅ RTL: CURRENT STREAK يمين | حلقة يسار
// ══════════════════════════════════════════════════════════════
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final pct = (streak / 30).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ حلقة التقدم — يسار في RTL
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _RingPainter(
                    progress: pct,
                    color: AppColors.accent,
                    trackColor: const Color(0xFF333333),
                    strokeWidth: 5,
                  ),
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w700, color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // ✅ النص — يمين في RTL
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: const [
                  Text('🔥', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'CURRENT STREAK',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF888888), letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$streak يوم',
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 32,
                  fontWeight: FontWeight.w900, color: Colors.white, height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Active Time Card — داكنة
// ✅ RTL: نص يمين
// ══════════════════════════════════════════════════════════════
class _ActiveTimeCard extends StatelessWidget {
  const _ActiveTimeCard({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$minutes',
            style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.w900,
              color: AppColors.accent, height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'دقيقة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Calories Card — فاتحة
// ✅ RTL: نص يمين
// ══════════════════════════════════════════════════════════════
class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.calories});
  final double calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            calories.toInt().toString(),
            style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'سعرة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Daily Goals Card — DAILY GOALS + حلقات + MOVE/EXERCISE/STAND
// ✅ RTL: عنوان يمين | حلقات يسار | قيم يمين
// ══════════════════════════════════════════════════════════════
class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({
    required this.calories,
    required this.caloriesGoal,
    required this.protein,
    required this.minutes,
  });
  final double calories, caloriesGoal, protein, minutes;

  @override
  Widget build(BuildContext context) {
    final movePct  = (calories / caloriesGoal.clamp(1, 9999)).clamp(0.0, 1.0);
    final exPct    = (minutes / 60).clamp(0.0, 1.0);
    final standPct = (protein / 150).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ عنوان يمين
          const Text(
            'DAILY GOALS',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textMuted, letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // ✅ الحلقات يسار
              SizedBox(
                width: 90, height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(size: const Size(90, 90),
                        painter: _RingPainter(progress: movePct,
                            color: AppColors.accent,
                            trackColor: const Color(0xFFE8E8E8), strokeWidth: 8)),
                    CustomPaint(size: const Size(68, 68),
                        painter: _RingPainter(progress: exPct,
                            color: AppColors.danger,
                            trackColor: const Color(0xFFE8E8E8), strokeWidth: 7)),
                    CustomPaint(size: const Size(48, 48),
                        painter: _RingPainter(progress: standPct,
                            color: AppColors.info,
                            trackColor: const Color(0xFFE8E8E8), strokeWidth: 6)),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // ✅ القيم يمين
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GoalRow(dot: AppColors.accent,  label: 'MOVE',     value: calories.toInt(), goal: caloriesGoal.toInt()),
                    const SizedBox(height: 12),
                    _GoalRow(dot: AppColors.danger,  label: 'EXERCISE', value: minutes.toInt(),   goal: 60),
                    const SizedBox(height: 12),
                    _GoalRow(dot: AppColors.info,    label: 'STAND',    value: protein.toInt(),   goal: 150),
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
    required this.dot, required this.label,
    required this.value, required this.goal,
  });
  final Color dot;
  final String label;
  final int value, goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ القيم يسار (في RTL هذا هو الطرف الأيسر)
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Cairo'),
            children: [
              TextSpan(text: '$value',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: dot)),
              TextSpan(text: '/$goal',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
            ],
          ),
        ),
        // ✅ التسمية + النقطة — يمين
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppColors.textMuted,
                  letterSpacing: 0.3,
                )),
            const SizedBox(width: 6),
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Quick Access Grid — 2×2
// ✅ RTL: تقدمي/التغذية يمين | التمارين/حسابي يسار
// ✅ النص داخل كل بطاقة يبدأ من اليمين
// ══════════════════════════════════════════════════════════════
class _QuickAccessGrid extends StatelessWidget {
  static const _items = [
    // ✅ ترتيب RTL: تقدمي (يمين) | التغذية (يسار)
    _QAItem('📈', 'تقدمي',    'عرض الإحصائيات',  Color(0xFFE3F2FD), '/progress'),
    _QAItem('🥗', 'التغذية',  'تتبع وجباتك',     Color(0xFFE8F5E9), '/nutrition'),
    // ✅ الصف الثاني: التمارين (يمين) | حسابي (يسار)
    _QAItem('🏋️', 'التمارين', 'استعرض المكتبة',  Color(0xFFFCE4EC), '/exercises'),
    _QAItem('👤', 'حسابي',    'البيانات الشخصية', Color(0xFFFFF3E0), '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: _items.map((item) => GestureDetector(
        onTap: () => context.go(item.route),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            // ✅ النص يبدأ من اليمين داخل البطاقة
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(item.label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  )),
              Text(item.sublabel,
                  textAlign: TextAlign.right,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted,
                  )),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _QAItem {
  const _QAItem(this.emoji, this.label, this.sublabel, this.color, this.route);
  final String emoji, label, sublabel, route;
  final Color color;
}

// ══════════════════════════════════════════════════════════════
// Today's Workout Card
// ✅ RTL: كل المحتوى يمين، badge يمين، زر كامل العرض
// ══════════════════════════════════════════════════════════════
class _TodayWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Badge يمين
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('قوة ⚡',
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  )),
            ),
          ),
          const SizedBox(height: 10),

          // ✅ العنوان يمين
          const Text('قوة الجزء العلوي',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 20,
                fontWeight: FontWeight.w900, color: AppColors.textPrimary,
              )),
          const SizedBox(height: 8),

          // ✅ الإحصائيات من اليمين
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              _WorkoutStat(emoji: '🕐', label: '45 دقيقة'),
              SizedBox(width: 14),
              _WorkoutStat(emoji: '🔥', label: '~380 سعرة'),
              SizedBox(width: 14),
              _WorkoutStat(emoji: '💪', label: '6 تمارين'),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ Tags من اليمين
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            children: ['بنش برس', 'عقلة', '+4'].map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  )),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // ✅ زر كامل العرض
          GestureDetector(
            onTap: () => context.go('/workout-logger'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text('ابدأ التمرين ←',
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.textOnDark,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({required this.emoji, required this.label});
  final String emoji, label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted,
            )),
        const SizedBox(width: 3),
        Text(emoji, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Section Label — يمين دائماً
// ══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 11,
          fontWeight: FontWeight.w700, color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Ring Painter
// ══════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress, required this.color,
    required this.trackColor, this.strokeWidth = 6,
  });
  final double progress, strokeWidth;
  final Color color, trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;
    final p = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, p..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r),
          -math.pi / 2, math.pi * 2 * progress, false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
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
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
        const SizedBox(height: 12),
        Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.read<HomeCubit>().load(),
          child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
        ),
      ]),
    ),
  );
}
