import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_button.dart';
import '../../../profile/data/models/user_profile_entity.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';

class _PageData {
  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

const _pages = [
  _PageData(
    icon: Icons.fitness_center_rounded,
    title: 'مرحباً بك في\nPower Pulse',
    subtitle: 'تطبيقك المتكامل للياقة البدنية\nتمارين • تغذية • تتبع التقدم',
    color: AppColors.accent,
  ),
  _PageData(
    icon: Icons.restaurant_rounded,
    title: 'تتبع تغذيتك\nبدقة',
    subtitle: 'آلاف الأطعمة متاحة\nتتبع السعرات والماكروز يومياً',
    color: AppColors.info,
  ),
  _PageData(
    icon: Icons.bar_chart_rounded,
    title: 'شاهد تقدمك\nيوماً بيوم',
    subtitle: 'رسوم بيانية واضحة\nتوضح رحلتك نحو هدفك',
    color: AppColors.warning,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;
  bool _showSetup = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: AppConstants.durationPage,
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _showSetup = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _showSetup ? const _SetupForm() : _IntroPages(
          pageCtrl: _pageCtrl,
          current: _current,
          onPageChanged: (i) => setState(() => _current = i),
          onNext: _next,
          onSkip: () => setState(() => _showSetup = true),
        ),
      ),
    );
  }
}

// ─── Intro Pages ─────────────────────────────────────────────
class _IntroPages extends StatelessWidget {
  const _IntroPages({
    required this.pageCtrl,
    required this.current,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
  });

  final PageController pageCtrl;
  final int current;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skip
        Align(
          alignment: Alignment.topLeft,
          child: TextButton(
            onPressed: onSkip,
            child: Text('تخطي',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textMuted)),
          ),
        ),

        // Pages
        Expanded(
          child: PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPage(page: _pages[i]),
          ),
        ),

        // Dots + button
        Padding(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          child: Column(
            children: [
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: AppConstants.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: current == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: current == i
                          ? AppColors.accent
                          : AppColors.bgElevated,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceXXL),
              PPButton(
                label: current == _pages.length - 1
                    ? 'ابدأ الإعداد'
                    : 'التالي',
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});
  final _PageData page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.12),
              border: Border.all(
                  color: page.color.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(page.icon, color: page.color, size: 64),
          ),
          const SizedBox(height: AppConstants.space3XL),
          Text(
            page.title,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Setup Form ──────────────────────────────────────────────
class _SetupForm extends StatefulWidget {
  const _SetupForm();

  @override
  State<_SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<_SetupForm> {
  final _nameCtrl   = TextEditingController();
  final _ageCtrl    = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  Gender        _gender   = Gender.male;
  FitnessGoal   _goal     = FitnessGoal.maintain;
  ActivityLevel _activity = ActivityLevel.moderate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      int.tryParse(_ageCtrl.text) != null &&
      double.tryParse(_heightCtrl.text) != null &&
      double.tryParse(_weightCtrl.text) != null;

  UserProfile get _profile => UserProfile(
        name:          _nameCtrl.text.trim(),
        age:           int.tryParse(_ageCtrl.text) ?? 25,
        heightCm:      double.tryParse(_heightCtrl.text) ?? 175,
        weightKg:      double.tryParse(_weightCtrl.text) ?? 75,
        gender:        _gender,
        goal:          _goal,
        activityLevel: _activity,
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSaveCubit, ProfileSaveState>(
      listener: (context, state) {
        if (state is ProfileSaveSuccess) {
          context.go('/home');
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.spaceXL,
                AppConstants.screenPaddingH,
                AppConstants.spaceXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أخبرنا عن نفسك',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: AppConstants.spaceS),
                  Text('لنحسب أهدافك اليومية بدقة',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name
                _Label('الاسم'),
                const SizedBox(height: AppConstants.spaceS),
                TextField(
                  controller: _nameCtrl,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'اسمك'),
                ),
                const SizedBox(height: AppConstants.spaceL),

                // Age + Height
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('العمر'),
                      const SizedBox(height: AppConstants.spaceS),
                      TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            hintText: '25', suffixText: 'سنة'),
                      ),
                    ],
                  )),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('الطول'),
                      const SizedBox(height: AppConstants.spaceS),
                      TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            hintText: '175', suffixText: 'سم'),
                      ),
                    ],
                  )),
                ]),
                const SizedBox(height: AppConstants.spaceL),

                // Weight
                _Label('الوزن'),
                const SizedBox(height: AppConstants.spaceS),
                TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textDirection: TextDirection.ltr,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      hintText: '75.0', suffixText: 'كج'),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Gender
                _Label('الجنس'),
                const SizedBox(height: AppConstants.spaceM),
                _SegmentRow<Gender>(
                  values: Gender.values,
                  selected: _gender,
                  label: (g) => g.labelAr,
                  onSelect: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Goal
                _Label('هدفك'),
                const SizedBox(height: AppConstants.spaceM),
                ...FitnessGoal.values.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
                  child: _OptionTile(
                    label: g.labelAr,
                    selected: _goal == g,
                    onTap: () => setState(() => _goal = g),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceL),

                // Activity
                _Label('مستوى النشاط'),
                const SizedBox(height: AppConstants.spaceM),
                ...ActivityLevel.values.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
                  child: _OptionTile(
                    label: a.labelAr,
                    selected: _activity == a,
                    onTap: () => setState(() => _activity = a),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceXXL),

                BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                  builder: (context, state) => PPButton(
                    label: 'ابدأ رحلتك 🚀',
                    isLoading: state is ProfileSaveLoading,
                    isDisabled: !_isValid,
                    onPressed: _isValid
                        ? () => context.read<ProfileSaveCubit>().save(_profile)
                        : null,
                  ),
                ),
                const SizedBox(height: AppConstants.space3XL),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMedium);
}

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: values.map((v) {
          final active = v == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(v),
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  label(v),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active
                        ? AppColors.textOnAccent
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentDim : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: selected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  )),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accent, size: AppConstants.iconS),
          ],
        ),
      ),
    );
  }
}
