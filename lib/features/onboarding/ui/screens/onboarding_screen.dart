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
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color  accentColor;
}

const _pages = [
  _PageData(
    emoji:       '💪',
    title:       'مرحباً بك في\nPower Pulse',
    subtitle:    'تطبيقك المتكامل للياقة البدنية\nتمارين • تغذية • تتبع التقدم',
    accentColor: AppColors.accent,
  ),
  _PageData(
    emoji:       '🥗',
    title:       'تتبع تغذيتك\nبدقة',
    subtitle:    'آلاف الأطعمة متاحة\nتتبع السعرات والماكروز يومياً',
    accentColor: Color(0xFF34D399),
  ),
  _PageData(
    emoji:       '📈',
    title:       'شاهد تقدمك\nيوماً بيوم',
    subtitle:    'رسوم بيانية واضحة\nتوضح رحلتك نحو هدفك',
    accentColor: Color(0xFF60A5FA),
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int  _current  = 0;
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
        curve:    Curves.easeInOut,
      );
    } else {
      setState(() => _showSetup = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: _showSetup
            ? const _SetupForm()
            : _IntroPages(
                pageCtrl:      _pageCtrl,
                current:       _current,
                onPageChanged: (i) => setState(() => _current = i),
                onNext:        _next,
                onSkip:        () => setState(() => _showSetup = true),
              ),
      ),
    );
  }
}


class _IntroPages extends StatelessWidget {
  const _IntroPages({
    required this.pageCtrl,
    required this.current,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
  });

  final PageController    pageCtrl;
  final int               current;
  final ValueChanged<int> onPageChanged;
  final VoidCallback      onNext;
  final VoidCallback      onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical:   AppConstants.spaceM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical:   AppConstants.spaceXXS + 2,
                ),
                decoration: BoxDecoration(
                  color:        AppColors.accentDim,
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  'Power Pulse',
                  style: AppTextStyles.labelSmall.copyWith(
                    color:         AppColors.accent,
                    fontWeight:    FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              // Skip
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical:   AppConstants.spaceXS,
                  ),
                ),
                child: Text('تخطي', style: AppTextStyles.labelMedium),
              ),
            ],
          ),
        ),

        Expanded(
          child: PageView.builder(
            controller:    pageCtrl,
            onPageChanged: onPageChanged,
            itemCount:     _pages.length,
            itemBuilder:   (_, i) => _OnboardingPage(page: _pages[i]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.screenPaddingH,
            AppConstants.spaceXL,
            AppConstants.screenPaddingH,
            AppConstants.spaceXXL,
          ),
          child: Column(
            children: [
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: AppConstants.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width:  current == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: current == i
                          ? AppColors.accent
                          : AppColors.borderMedium,
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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withOpacity(0.10),
              border: Border.all(
                color: page.accentColor.withOpacity(0.25),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.space3XL),

          Text(
            page.title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spaceL),

          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


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
        email:         '',
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSaveCubit, ProfileSaveState>(
      listener: (context, state) {
        if (state is ProfileSaveSuccess) context.go('/home');
      },
      child: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.spaceXXL,
                AppConstants.screenPaddingH,
                AppConstants.spaceXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical:   AppConstants.spaceXXS + 2,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.accentDim,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: Text(
                      'إعداد الملف الشخصي',
                      style: AppTextStyles.labelSmall.copyWith(
                        color:      AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceM),
                  Text('أخبرنا عن\nnفسك 🙋',
                      style: AppTextStyles.displayMedium.copyWith(height: 1.25)),
                  const SizedBox(height: AppConstants.spaceS),
                  Text('لنحسب أهدافك اليومية بدقة',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),

          // ── Fields ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name
                _SectionLabel('الاسم'),
                const SizedBox(height: AppConstants.spaceS),
                _SetupField(
                  controller:    _nameCtrl,
                  hint:          'اسمك',
                  textDirection: TextDirection.rtl,
                  onChanged:     (_) => setState(() {}),
                ),
                const SizedBox(height: AppConstants.spaceXL),

                // Age + Height row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('العمر'),
                          const SizedBox(height: AppConstants.spaceS),
                          _SetupField(
                            controller:  _ageCtrl,
                            hint:        '25',
                            suffix:      'سنة',
                            keyboardType: TextInputType.number,
                            onChanged:   (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('الطول'),
                          const SizedBox(height: AppConstants.spaceS),
                          _SetupField(
                            controller:  _heightCtrl,
                            hint:        '175',
                            suffix:      'سم',
                            keyboardType: TextInputType.number,
                            onChanged:   (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXL),

                // Weight
                _SectionLabel('الوزن'),
                const SizedBox(height: AppConstants.spaceS),
                _SetupField(
                  controller:  _weightCtrl,
                  hint:        '75.0',
                  suffix:      'كجم',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Gender
                _SectionLabel('الجنس'),
                const SizedBox(height: AppConstants.spaceM),
                _SegmentRow<Gender>(
                  values:   Gender.values,
                  selected: _gender,
                  label:    (g) => g.labelAr,
                  onSelect: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Divider
                const Divider(color: AppColors.borderSubtle),
                const SizedBox(height: AppConstants.spaceXL),

                // Goal
                _SectionLabel('هدفك'),
                const SizedBox(height: AppConstants.spaceM),
                ...FitnessGoal.values.map((g) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceS),
                      child: _OptionTile(
                        label:    g.labelAr,
                        icon:     _goalIcon(g),
                        selected: _goal == g,
                        onTap:    () => setState(() => _goal = g),
                      ),
                    )),
                const SizedBox(height: AppConstants.spaceXL),

                // Divider
                const Divider(color: AppColors.borderSubtle),
                const SizedBox(height: AppConstants.spaceXL),

                // Activity
                _SectionLabel('مستوى النشاط'),
                const SizedBox(height: AppConstants.spaceM),
                ...ActivityLevel.values.map((a) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceS),
                      child: _OptionTile(
                        label:    a.labelAr,
                        icon:     _activityIcon(a),
                        selected: _activity == a,
                        onTap:    () => setState(() => _activity = a),
                      ),
                    )),
                const SizedBox(height: AppConstants.spaceXXL),

                // Submit
                BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                  builder: (context, state) => PPButton(
                    label:      'ابدأ رحلتك 🚀',
                    isLoading:  state is ProfileSaveLoading,
                    isDisabled: !_isValid,
                    onPressed: _isValid
                        ? () => context
                            .read<ProfileSaveCubit>()
                            .save(_profile)
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

  IconData _goalIcon(FitnessGoal g) => switch (g) {
        FitnessGoal.lose     => Icons.trending_down_rounded,
        FitnessGoal.gain     => Icons.trending_up_rounded,
        FitnessGoal.maintain => Icons.balance_rounded,
        _                    => Icons.flag_rounded,
      };

  IconData _activityIcon(ActivityLevel a) => switch (a) {
        ActivityLevel.sedentary   => Icons.chair_rounded,
        ActivityLevel.light       => Icons.directions_walk_rounded,
        ActivityLevel.moderate    => Icons.directions_bike_rounded,
        ActivityLevel.active      => Icons.directions_run_rounded,
        ActivityLevel.veryActive  => Icons.sports_gymnastics_rounded,
        _                         => Icons.fitness_center_rounded,
      };
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      );
}

// ─── Setup Text Field ─────────────────────────────────────────────────────────

class _SetupField extends StatelessWidget {
  const _SetupField({
    required this.controller,
    required this.hint,
    this.suffix,
    this.keyboardType,
    this.textDirection = TextDirection.ltr,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String                hint;
  final String?               suffix;
  final TextInputType?        keyboardType;
  final TextDirection         textDirection;
  final ValueChanged<String>  onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:    controller,
      keyboardType:  keyboardType,
      textDirection: textDirection,
      onChanged:     onChanged,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText:    hint,
        hintStyle:   AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        suffixText:  suffix,
        suffixStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        filled:      true,
        fillColor:   AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical:   AppConstants.spaceM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Segment Row ─────────────────────────────────────────────────────────────

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  final List<T>            values;
  final T                  selected;
  final String Function(T) label;
  final ValueChanged<T>    onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:        AppColors.bgElevated,
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
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusS),
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

// ─── Option Tile ─────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String       label;
  final IconData     icon;
  final bool         selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical:   AppConstants.spaceM + 2,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(
                icon,
                size:  AppConstants.iconS,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: selected
                      ? AppColors.accent
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size:  AppConstants.iconS),
          ],
        ),
      ),
    );
  }
}
