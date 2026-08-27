import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/auth/user_mode_service.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/dark_field_label.dart';
import '../../../../../shared/widgets/dark_primary_button.dart';
import '../../../../../shared/widgets/dark_form_field.dart';
import '../../../../../shared/widgets/pp_logo.dart';
import '../../../profile/data/models/user_profile_entity.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';

// ─── Brand Colors (dark-only screens) ────────────────────────────────────────
const _kBg         = Color(0xFF0F0F0F);
const _kSurface    = Color(0xFF1A1A1A);
const _kSurface2   = Color(0xFF242424);
const _kBorder     = Color(0xFF2E2E2E);
const _kAccent     = Color(0xFFA8E063);
const _kAccentDim  = Color(0x26A8E063);
const _kTextHigh   = Color(0xFFFFFFFF);
const _kTextMid    = Color(0xFFAAAAAA);
const _kTextLow    = Color(0xFF666666);
const _kDanger     = Color(0xFFFF4C6A);
const _kGreen2     = Color(0xFF34D399);
const _kBlue       = Color(0xFF60A5FA);

// ─── Slide data ───────────────────────────────────────────────────────────────
class _SlideData {
  const _SlideData({
    required this.icon,
    required this.accentColor,
    required this.tag,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color    accentColor;
  final String   tag;
  final String   title;
  final String   body;
}

const _slides = [
  _SlideData(
    icon:        Icons.bolt_rounded,
    accentColor: _kAccent,
    tag:         AppStrings.slide1Tag,
    title:       AppStrings.slide1Title,
    body:        AppStrings.slide1Body,
  ),
  _SlideData(
    icon:        Icons.restaurant_rounded,
    accentColor: _kGreen2,
    tag:         AppStrings.slide2Tag,
    title:       AppStrings.slide2Title,
    body:        AppStrings.slide2Body,
  ),
  _SlideData(
    icon:        Icons.insights_rounded,
    accentColor: _kBlue,
    tag:         AppStrings.slide3Tag,
    title:       AppStrings.slide3Title,
    body:        AppStrings.slide3Body,
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
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.light,
      statusBarBrightness:       Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _slides.length - 1) {
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
      backgroundColor: _kBg,
      body: _showSetup
          ? const _SetupForm()
          : _IntroSlides(
              pageCtrl:      _pageCtrl,
              current:       _current,
              onPageChanged: (i) => setState(() => _current = i),
              onNext:        _next,
              onSkip:        () => setState(() => _showSetup = true),
            ),
    );
  }
}


// ─── Intro Slides ─────────────────────────────────────────────────────────────
class _IntroSlides extends StatelessWidget {
  const _IntroSlides({
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

    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
              vertical:   AppConstants.spaceL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  PPLogo(size: 32),
                  const SizedBox(width: AppConstants.spaceS),
                  Text(
                    'Power Pulse',
                    style: AppTextStyles.titleMedium.copyWith(
                      color:         _kAccent,
                      fontWeight:    FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ]),
                GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical:   6,
                    ),
                    decoration: BoxDecoration(
                      color:        _kSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                      border:       Border.all(color: _kBorder),
                    ),
                    child: Text(
                      AppStrings.onboardingSkip,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _kTextMid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Slide pages ──────────────────────────────────────
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
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: AppConstants.durationFast,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width:  current == i ? 28 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: current == i ? slide.accentColor : _kBorder,
                        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
                DarkPrimaryButton(
                  label:   current == _slides.length - 1 ? AppStrings.onboardingSetupProfile : AppStrings.onboardingNext,
                  onTap:   onNext,
                  accent:  slide.accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Slide ─────────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in styled hexagonal container
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        slide.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border:       Border.all(
                color: slide.accentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              slide.icon,
              color: slide.accentColor,
              size:  36,
            ),
          ),

          const SizedBox(height: AppConstants.spaceXXL),

          // Tag
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceM,
              vertical:   5,
            ),
            decoration: BoxDecoration(
              color:        slide.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
            child: Text(
              slide.tag,
              style: AppTextStyles.labelSmall.copyWith(
                color:         slide.accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceL),

          Text(
            slide.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize:   32,
              fontWeight: FontWeight.w900,
              color:      _kTextHigh,
              height:     1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: AppConstants.spaceL),

          Text(
            slide.body,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   14,
              fontWeight: FontWeight.w400,
              color:      _kTextMid,
              height:     1.7,
            ),
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

  static const _minAge = 10;   static const _maxAge = 100;
  static const _minH   = 100;  static const _maxH   = 250;
  static const _minW   = 20;   static const _maxW   = 300;

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
          // Mark onboarding done so the router never shows it again
          final prefs = await SharedPreferences.getInstance();
          await UserModeService.setOnboardingDone(prefs);
          // Clear router cache so next navigation re-evaluates
          AppRouter.clearLocationCache();
          if (context.mounted) context.go(AppRouter.entry);
        }
      },
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPaddingH, AppConstants.spaceXXL,
                  AppConstants.screenPaddingH, AppConstants.spaceXXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      PPLogo(size: 28),
                      const SizedBox(width: AppConstants.spaceS),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:        _kAccentDim,
                          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                        ),
                        child: Text(AppStrings.onboardingSetupTag,
                          style: AppTextStyles.labelSmall.copyWith(color: _kAccent)),
                      ),
                    ]),
                    const SizedBox(height: AppConstants.spaceL),
                    const Text(AppStrings.onboardingSetupTitle,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w900,
                        color: _kTextHigh, height: 1.15, letterSpacing: -0.5,
                      )),
                    const SizedBox(height: AppConstants.spaceS),
                    Text(AppStrings.onboardingSetupBody,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                          color: _kTextMid, height: 1.5)),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // Name
                DarkFieldLabel(AppStrings.fieldName),
                const SizedBox(height: AppConstants.spaceS),
                DarkFormField(controller: _nameCtrl, hint: AppStrings.fieldNameHint,
                    textDirection: TextDirection.rtl,
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: AppConstants.spaceXXL),

                // Age + Height
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    DarkFieldLabel(AppStrings.fieldAge),
                    const SizedBox(height: AppConstants.spaceS),
                    DarkFormField(controller: _ageCtrl, hint: AppStrings.fieldAgeHint, suffix: AppStrings.fieldAgeSuffix,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        errorText: _ageCtrl.text.isEmpty ? null : _ageError()),
                  ])),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    DarkFieldLabel(AppStrings.fieldHeight),
                    const SizedBox(height: AppConstants.spaceS),
                    DarkFormField(controller: _heightCtrl, hint: AppStrings.fieldHeightHint, suffix: AppStrings.fieldHeightSuffix,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        errorText: _heightCtrl.text.isEmpty ? null : _heightError()),
                  ])),
                ]),
                const SizedBox(height: AppConstants.spaceXXL),

                // Weight
                DarkFieldLabel(AppStrings.fieldWeight),
                const SizedBox(height: AppConstants.spaceS),
                DarkFormField(controller: _weightCtrl, hint: AppStrings.fieldWeightHint, suffix: AppStrings.fieldWeightSuffix,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    errorText: _weightCtrl.text.isEmpty ? null : _weightError()),
                const SizedBox(height: AppConstants.spaceXXL),

                // Gender
                DarkFieldLabel(AppStrings.fieldGender),
                const SizedBox(height: AppConstants.spaceM),
                _DarkSegment<Gender>(
                  values: Gender.values, selected: _gender,
                  label: (g) => g.labelAr,
                  onSelect: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                _Divider(),
                const SizedBox(height: AppConstants.spaceXL),

                // Goal
                DarkFieldLabel(AppStrings.fieldGoal),
                const SizedBox(height: AppConstants.spaceM),
                ...FitnessGoal.values.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
                  child: _DarkOptionTile(
                    label: g.labelAr, icon: _goalIcon(g),
                    accent: _kAccent,
                    selected: _goal == g,
                    onTap: () => setState(() => _goal = g),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceXL),

                _Divider(),
                const SizedBox(height: AppConstants.spaceXL),

                // Activity
                DarkFieldLabel(AppStrings.fieldActivity),
                const SizedBox(height: AppConstants.spaceM),
                ...ActivityLevel.values.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
                  child: _DarkOptionTile(
                    label: a.labelAr, icon: _activityIcon(a),
                    accent: _kGreen2,
                    selected: _activity == a,
                    onTap: () => setState(() => _activity = a),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceXXL),

                // Submit
                BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                  builder: (ctx, st) => DarkPrimaryButton(
                    label:    AppStrings.onboardingStart,
                    onTap:    _isValid ? () => ctx.read<ProfileSaveCubit>().save(_profile) : null,
                    accent:   _kAccent,
                    loading:  st is ProfileSaveLoading,
                    disabled: !_isValid,
                  ),
                ),
                const SizedBox(height: AppConstants.space3XL),
              ])),
            ),
          ],
        ),
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

// ─── Shared dark-screen widgets ───────────────────────────────────────────────
