import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../exercises/views/gim_view.dart';

/// ONBOARDING — 4 screens. Each screen is a commitment checkpoint.
///
/// Screen 1: Goal — what does success look like?
/// Screen 2: Level — what is your current state?
/// Screen 3: Start day — when do you begin? (creates first investment)
/// Screen 4: Activation — your plan is ready.
///
/// On completion: saves to UserProfileService and navigates to main app.
/// Data saved: goal, level, start weekday — used by home + recommendations.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _page = 0;
  String? _goal;
  String? _level;
  int _startWeekday = DateTime.now().weekday; // default: today

  static const int _totalPages = 4;

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await UserProfileService.instance.saveOnboarding(
      goal:        _goal        ?? 'الصحة العامة',
      level:       _level       ?? 'مبتدئ',
      startWeekday: _startWeekday,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GimView(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _GoalScreen(
                selected: _goal,
                onSelect: (v) => setState(() => _goal = v),
                onNext: _next,
              ),
              _LevelScreen(
                selected: _level,
                onSelect: (v) => setState(() => _level = v),
                onNext: _next,
              ),
              _StartDayScreen(
                selected: _startWeekday,
                onSelect: (v) => setState(() => _startWeekday = v),
                onNext: _next,
              ),
              _ActivationScreen(
                goal:  _goal,
                level: _level,
                onStart: _finish,
              ),
            ],
          ),

          // Progress indicator — minimal, top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 18,
            left: AppSpacing.marginMobile,
            child: Row(
              children: List.generate(_totalPages, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: i == _page ? 22 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: i <= _page
                      ? AppColors.primary
                      : AppColors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 1 — GOAL
// Framed as outcome, not category. "What does success look like?"
// ─────────────────────────────────────────────────────────────────────────────
class _GoalScreen extends StatelessWidget {
  const _GoalScreen({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  static const _goals = [
    ('بناء العضلات',  'أريد أن أشعر بالقوة'),
    ('حرق الدهون',    'أريد أن أشعر بخفة أكبر'),
    ('رفع اللياقة',   'أريد أن أشعر بالحيوية'),
    ('الصحة العامة',  'أريد أن أشعر بالاتزان'),
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 3),
          Text(
            'ما الذي تريد\nتحقيقه؟',
            style: AppTextStyles.headlineHero
                .copyWith(color: Colors.white, height: 1.15),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 10),
          Text(
            'سيصمم التطبيق تجربتك بناءً على هدفك',
            style: AppTextStyles.bodyMd
                .copyWith(color: Colors.white.withOpacity(0.55)),
          ),
          const Spacer(flex: 2),
          ..._goals.map((g) => _SelectTile(
                title: g.$1,
                subtitle: g.$2,
                isSelected: selected == g.$1,
                onTap: () => onSelect(g.$1),
              )),
          const Spacer(flex: 2),
          _OnboardingCTA(
            label: 'التالي',
            enabled: selected != null,
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 2 — LEVEL
// Shows what changes based on selection — makes it feel consequential
// ─────────────────────────────────────────────────────────────────────────────
class _LevelScreen extends StatelessWidget {
  const _LevelScreen({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  static const _levels = [
    ('مبتدئ',   'أقل من 3 أشهر',   '3 أيام / أسبوع · 30-40 دقيقة'),
    ('متوسط',   '3 أشهر – سنة',    '4 أيام / أسبوع · 40-50 دقيقة'),
    ('متقدم',   'أكثر من سنة',      '5 أيام / أسبوع · 50-60 دقيقة'),
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 3),
          Text(
            'ما مستواك\nالحالي؟',
            style: AppTextStyles.headlineHero
                .copyWith(color: Colors.white, height: 1.15),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 10),
          Text(
            'نحدد عدد الأيام والمدة بناءً على تجربتك',
            style: AppTextStyles.bodyMd
                .copyWith(color: Colors.white.withOpacity(0.55)),
          ),
          const Spacer(flex: 2),
          ..._levels.map((l) => _SelectTile(
                title: l.$1,
                subtitle: l.$2,
                badge: l.$3,
                isSelected: selected == l.$1,
                onTap: () => onSelect(l.$1),
              )),
          const Spacer(flex: 2),
          _OnboardingCTA(
            label: 'التالي',
            enabled: selected != null,
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 3 — START DAY
// "When do you start?" — first investment in the plan.
// The user chooses their own start day → they own the commitment.
// ─────────────────────────────────────────────────────────────────────────────
class _StartDayScreen extends StatelessWidget {
  const _StartDayScreen({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final int selected; // weekday 1=Mon..7=Sun
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  static const _days = [
    (1, 'الاثنين'),
    (2, 'الثلاثاء'),
    (3, 'الأربعاء'),
    (4, 'الخميس'),
    (5, 'الجمعة'),
    (6, 'السبت'),
    (7, 'الأحد'),
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 3),
          Text(
            'متى تبدأ\nخطتك؟',
            style: AppTextStyles.headlineHero
                .copyWith(color: Colors.white, height: 1.15),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 10),
          Text(
            'سنبني برنامجك الأسبوعي بدءاً من هذا اليوم',
            style: AppTextStyles.bodyMd
                .copyWith(color: Colors.white.withOpacity(0.55)),
          ),
          const Spacer(flex: 2),

          // Day grid — 2 columns
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: _days.map((d) => _DayTile(
                  label: d.$2,
                  isSelected: selected == d.$1,
                  onTap: () => onSelect(d.$1),
                )).toList(),
          ),

          const Spacer(flex: 2),
          _OnboardingCTA(
            label: 'خطتي جاهزة',
            enabled: true,
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 4 — ACTIVATION
// The payoff. Minimal. Earned. "Your plan is ready."
// ─────────────────────────────────────────────────────────────────────────────
class _ActivationScreen extends StatelessWidget {
  const _ActivationScreen({
    required this.goal,
    required this.level,
    required this.onStart,
  });

  final String? goal, level;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      gradientStrength: 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(flex: 4),

          // Brand mark
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'خطتك\nجاهزة.',
            style: AppTextStyles.headlineHero.copyWith(
              color: Colors.white,
              fontSize: 46,
              height: 1.1,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 14),

          // Personalized confirmation — uses their actual selections
          if (goal != null)
            Text(
              'الهدف: $goal${level != null ? " · $level" : ""}',
              style: AppTextStyles.bodyMd.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.end,
            ),

          const Spacer(flex: 3),

          _OnboardingCTA(
            label: 'ابدأ التدريب',
            enabled: true,
            isPrimary: true,
            onTap: onStart,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed background page with gradient overlay
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.imageUrl,
    required this.child,
    this.gradientStrength = 0.88,
  });

  final String imageUrl;
  final Widget child;
  final double gradientStrength;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceHigh,
                  AppColors.background,
                ],
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
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(gradientStrength),
                ],
                stops: const [0.2, 0.72],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Selection tile — goal and level choices
class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String title, subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11)
                  : null,
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.75),
                    ),
                    textAlign: TextAlign.end,
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      badge!,
                      style: AppTextStyles.labelMuted.copyWith(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.9)
                            : Colors.white.withOpacity(0.38),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ] else
                    Text(
                      subtitle,
                      style: AppTextStyles.labelMuted.copyWith(
                        color: Colors.white.withOpacity(0.38),
                      ),
                      textAlign: TextAlign.end,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Day tile for start-day grid
class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// CTA button shared across all onboarding screens
class _OnboardingCTA extends StatelessWidget {
  const _OnboardingCTA({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final bool enabled, isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: !enabled
              ? Colors.white.withOpacity(0.12)
              : isPrimary
                  ? AppColors.primary
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled && isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.buttonLabel.copyWith(
              fontSize: 17,
              color: !enabled
                  ? Colors.white.withOpacity(0.3)
                  : isPrimary
                      ? Colors.white
                      : AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
