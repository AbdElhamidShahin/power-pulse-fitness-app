import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/auth/user_mode_service.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/widgets/dark_field_label.dart';
import '../../../../../shared/widgets/dark_primary_button.dart';
import '../../../../../shared/widgets/dark_form_field.dart';
import '../../../../../shared/widgets/pp_logo.dart';
import '../../../profile/data/models/user_profile_entity.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';

// ─── Design tokens (matches entry/login/signup) ───────────────────────────────
const _kBg        = Color(0xFF0F0F0F);
const _kSurface   = Color(0xFF1A1A1A);
const _kSurface2  = Color(0xFF222222);
const _kBorder    = Color(0xFF2A2A2A);
const _kAccent    = Color(0xFFA8E063);
const _kAccentDim = Color(0x1AA8E063);
const _kGreen2    = Color(0xFF34D399);
const _kBlue      = Color(0xFF60A5FA);
const _kTextHigh  = Color(0xFFFFFFFF);
const _kTextMid   = Color(0xFF888888);
const _kTextLow   = Color(0xFF444444);
const _kDanger    = Color(0xFFFF4C6A);

// ─── Slide data ───────────────────────────────────────────────────────────────
class _Slide {
  const _Slide({
    required this.emoji,
    required this.accent,
    required this.tag,
    required this.title,
    required this.body,
    required this.features,
  });
  final String emoji;
  final Color  accent;
  final String tag;
  final String title;
  final String body;
  final List<String> features;
}

const _slides = [
  _Slide(
    emoji:    '⚡',
    accent:   _kAccent,
    tag:      AppStrings.slide1Tag,
    title:    AppStrings.slide1Title,
    body:     AppStrings.slide1Body,
    features: ['برامج مخصصة لمستواك', 'تتبع التمارين تلقائياً', 'تحليل الأداء بالرسوم'],
  ),
  _Slide(
    emoji:    '🥗',
    accent:   _kGreen2,
    tag:      AppStrings.slide2Tag,
    title:    AppStrings.slide2Title,
    body:     AppStrings.slide2Body,
    features: ['قاعدة بيانات ضخمة للأطعمة', 'تتبع السعرات والماكروز', 'تذكير شرب الماء'],
  ),
  _Slide(
    emoji:    '📈',
    accent:   _kBlue,
    tag:      AppStrings.slide3Tag,
    title:    AppStrings.slide3Title,
    body:     AppStrings.slide3Body,
    features: ['رسوم بيانية أسبوعية', 'مقارنة بالأهداف', 'سجل إنجازاتك'],
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
  int  _current   = 0;
  bool _showSetup = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:     Brightness.dark,
    ));
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: AppConstants.durationPage, curve: Curves.easeInOut);
    } else {
      setState(() => _showSetup = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: _showSetup
          ? const _SetupForm()
          : _Slides(
        pageCtrl:      _pageCtrl,
        current:       _current,
        onPageChanged: (i) => setState(() => _current = i),
        onNext:        _next,
        onSkip:        () => setState(() => _showSetup = true),
      ),
    );
  }
}

// ─── Slide Pager ─────────────────────────────────────────────────────────────
class _Slides extends StatelessWidget {
  const _Slides({
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
    final slide = _slides[current];
    final isLast = current == _slides.length - 1;

    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const PPLogo(size: 30),
                  SizedBox(width: 8.w),
                  Text('Power Pulse',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 15.sp,
                          fontWeight: FontWeight.w900, color: _kAccent,
                          letterSpacing: 0.2)),
                ]),
                GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color:        _kSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                      border:       Border.all(color: _kBorder),
                    ),
                    child: Text(AppStrings.onboardingSkip,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                            color: _kTextMid)),
                  ),
                ),
              ],
            ),
          ),

          // ── Slides ───────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller:    pageCtrl,
              onPageChanged: onPageChanged,
              itemCount:     _slides.length,
              itemBuilder:   (_, i) => _SlidePage(slide: _slides[i]),
            ),
          ),

          // ── Bottom ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH.w, 16.h,
              AppConstants.screenPaddingH.w, 28.h,
            ),
            child: Column(children: [
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == current;
                  return AnimatedContainer(
                    duration: AppConstants.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width:  active ? 24.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: active ? slide.accent : _kBorder,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),
              DarkPrimaryButton(
                label:  isLast ? AppStrings.onboardingSetupProfile : AppStrings.onboardingNext,
                onTap:  onNext,
                accent: slide.accent,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Single Slide Page ────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big emoji in a glowing container
          Container(
            width: 80.r, height: 80.r,
            decoration: BoxDecoration(
              color:        slide.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(
                  color: slide.accent.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color:       slide.accent.withOpacity(0.12),
                  blurRadius:  24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(slide.emoji,
                  style: TextStyle(fontSize: 34.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          // Tag pill
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM.w, vertical: 5.h),
            decoration: BoxDecoration(
              color:        slide.accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
              border:       Border.all(
                  color: slide.accent.withOpacity(0.25)),
            ),
            child: Text(slide.tag,
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11.sp,
                  fontWeight: FontWeight.w700, color: slide.accent,
                  letterSpacing: 0.4,
                )),
          ),

          SizedBox(height: 16.h),

          // Title
          Text(slide.title,
              style: TextStyle(
                fontFamily:    'Cairo',
                fontSize:      30.sp,
                fontWeight:    FontWeight.w900,
                color:         _kTextHigh,
                height:        1.15,
                letterSpacing: -0.5,
              )),

          SizedBox(height: 10.h),

          // Body
          Text(slide.body,
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13.sp,
                color: _kTextMid, height: 1.7,
              )),

          SizedBox(height: 24.h),

          // Feature chips
          Wrap(
            spacing: 8.w, runSpacing: 8.h,
            children: slide.features.map((f) => Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color:        _kSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                border:       Border.all(color: _kBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_rounded,
                    color: slide.accent, size: 12.sp),
                SizedBox(width: 4.w),
                Text(f, style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 11.sp,
                    color: _kTextMid)),
              ]),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Setup Form ───────────────────────────────────────────────────────────────
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
    _nameCtrl.dispose(); _ageCtrl.dispose();
    _heightCtrl.dispose(); _weightCtrl.dispose();
    super.dispose();
  }

  static const _minAge = 10; static const _maxAge = 100;
  static const _minH   = 100; static const _maxH   = 250;
  static const _minW   = 20;  static const _maxW   = 300;

  String? _ageError() {
    final v = int.tryParse(_ageCtrl.text.trim());
    if (v == null) return AppStrings.errEnterNumber;
    if (v < _minAge || v > _maxAge) return 'بين $_minAge و$_maxAge سنة';
    return null;
  }
  String? _heightError() {
    final v = double.tryParse(_heightCtrl.text.trim());
    if (v == null) return AppStrings.errEnterNumber;
    if (v < _minH || v > _maxH) return 'بين $_minH و$_maxH سم';
    return null;
  }
  String? _weightError() {
    final v = double.tryParse(_weightCtrl.text.trim());
    if (v == null) return AppStrings.errEnterNumber;
    if (v < _minW || v > _maxW) return 'بين $_minW و$_maxW كجم';
    return null;
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
          _ageError() == null && _heightError() == null && _weightError() == null;

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
      listener: (context, state) async {
        if (state is ProfileSaveSuccess) {
          final prefs = await SharedPreferences.getInstance();
          await UserModeService.setOnboardingDone(prefs);
          AppRouter.clearLocationCache();
          if (context.mounted) context.go(AppRouter.entry);
        }
      },
      child: SafeArea(
        child: CustomScrollView(slivers: [
          // ── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH.w, 20.h,
                AppConstants.screenPaddingH.w, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const PPLogo(size: 26),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color:        _kAccentDim,
                        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                        border:       Border.all(
                            color: _kAccent.withOpacity(0.3)),
                      ),
                      child: Text(AppStrings.onboardingSetupTag,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp,
                              color: _kAccent, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  SizedBox(height: 16.h),
                  Text(AppStrings.onboardingSetupTitle,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 30.sp,
                        fontWeight: FontWeight.w900, color: _kTextHigh,
                        height: 1.15, letterSpacing: -0.5,
                      )),
                  SizedBox(height: 6.h),
                  Text(AppStrings.onboardingSetupBody,
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 13.sp,
                          color: _kTextMid, height: 1.5)),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),

          // ── Form Fields ────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH.w),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Name
              _SectionLabel('الاسم الكامل'),
              SizedBox(height: 8.h),
              DarkFormField(
                controller: _nameCtrl,
                hint: AppStrings.fieldNameHint,
                icon: Icons.person_outline_rounded,
                textDirection: TextDirection.rtl,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 20.h),

              // Age + Height row
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(AppStrings.fieldAge),
                    SizedBox(height: 8.h),
                    DarkFormField(
                      controller:  _ageCtrl,
                      hint:        AppStrings.fieldAgeHint,
                      suffixLabel: AppStrings.fieldAgeSuffix,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      errorText: _ageCtrl.text.isEmpty ? null : _ageError(),
                    ),
                  ],
                )),
                SizedBox(width: 12.w),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(AppStrings.fieldHeight),
                    SizedBox(height: 8.h),
                    DarkFormField(
                      controller:  _heightCtrl,
                      hint:        AppStrings.fieldHeightHint,
                      suffixLabel: AppStrings.fieldHeightSuffix,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      errorText: _heightCtrl.text.isEmpty ? null : _heightError(),
                    ),
                  ],
                )),
              ]),
              SizedBox(height: 20.h),

              // Weight
              _SectionLabel(AppStrings.fieldWeight),
              SizedBox(height: 8.h),
              DarkFormField(
                controller:  _weightCtrl,
                hint:        AppStrings.fieldWeightHint,
                suffixLabel: AppStrings.fieldWeightSuffix,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                errorText: _weightCtrl.text.isEmpty ? null : _weightError(),
              ),
              SizedBox(height: 24.h),

              // Gender
              _SectionLabel(AppStrings.fieldGender),
              SizedBox(height: 10.h),
              _SegmentRow<Gender>(
                values:   Gender.values,
                selected: _gender,
                label:    (g) => g.labelAr,
                onSelect: (g) => setState(() => _gender = g),
              ),
              SizedBox(height: 24.h),

              const _Divider(),
              SizedBox(height: 20.h),

              // Goal
              _SectionLabel(AppStrings.fieldGoal),
              SizedBox(height: 10.h),
              ...FitnessGoal.values.map((g) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _OptionTile(
                  label:    g.labelAr,
                  icon:     _goalIcon(g),
                  accent:   _kAccent,
                  selected: _goal == g,
                  onTap:    () => setState(() => _goal = g),
                ),
              )),
              SizedBox(height: 8.h),

              const _Divider(),
              SizedBox(height: 20.h),

              // Activity
              _SectionLabel(AppStrings.fieldActivity),
              SizedBox(height: 10.h),
              ...ActivityLevel.values.map((a) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _OptionTile(
                  label:    a.labelAr,
                  icon:     _activityIcon(a),
                  accent:   _kGreen2,
                  selected: _activity == a,
                  onTap:    () => setState(() => _activity = a),
                ),
              )),
              SizedBox(height: 28.h),

              // Submit
              BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                builder: (ctx, st) => DarkPrimaryButton(
                  label:    AppStrings.onboardingStart,
                  onTap:    _isValid
                      ? () => ctx.read<ProfileSaveCubit>().save(_profile)
                      : null,
                  accent:   _kAccent,
                  loading:  st is ProfileSaveLoading,
                  disabled: !_isValid,
                ),
              ),
              SizedBox(height: AppConstants.space3XL.h),
            ])),
          ),
        ]),
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
    ActivityLevel.sedentary  => Icons.chair_rounded,
    ActivityLevel.light      => Icons.directions_walk_rounded,
    ActivityLevel.moderate   => Icons.directions_bike_rounded,
    ActivityLevel.active     => Icons.directions_run_rounded,
    ActivityLevel.veryActive => Icons.sports_gymnastics_rounded,
    _                        => Icons.fitness_center_rounded,
  };
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
        fontFamily: 'Cairo', fontSize: 12.sp,
        fontWeight: FontWeight.w700, color: _kTextMid,
        letterSpacing: 0.3,
      ));
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: _kBorder, thickness: 1, height: 1);
}

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
    return Row(
      children: values.asMap().entries.map((e) {
        final v        = e.value;
        final active   = v == selected;
        final isLast   = e.key == values.length - 1;
        return Expanded(child: GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: AppConstants.durationFast,
            margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: active
                  ? _kAccent.withOpacity(0.10)
                  : _kSurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                  color: active ? _kAccent : _kBorder,
                  width: active ? 1.5 : 1),
            ),
            child: Center(child: Text(label(v),
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13.sp,
                  color:      active ? _kAccent : _kTextMid,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ))),
          ),
        ));
      }).toList(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });
  final String     label;
  final IconData   icon;
  final Color      accent;
  final bool       selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: EdgeInsets.symmetric(
            horizontal: 16.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.07) : _kSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
              color: selected ? accent : _kBorder,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 34.r, height: 34.r,
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.12)
                  : _kSurface2,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon,
                color: selected ? accent : _kTextMid,
                size: AppConstants.iconS),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(label,
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13.sp,
                color:      selected ? accent : _kTextHigh,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ))),
          if (selected)
            Icon(Icons.check_circle_rounded,
                color: accent, size: 18.sp),
        ]),
      ),
    );
  }
}
