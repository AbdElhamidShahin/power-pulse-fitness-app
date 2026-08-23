import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/auth/user_mode_service.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_text_styles.dart';
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
    tag:         'اللياقة البدنية',
    title:       'حوّل جسمك\nبالعلم والالتزام',
    body:        'برامج تمارين مخصصة، تتبع دقيق للتغذية،\nوتحليل مستمر لتقدمك',
  ),
  _SlideData(
    icon:        Icons.restaurant_rounded,
    accentColor: _kGreen2,
    tag:         'التغذية الذكية',
    title:       'اعرف ما تأكل\nوابنِ جسمك',
    body:        'قاعدة بيانات ضخمة من الأطعمة\nتتبع السعرات والماكروز بدقة عالية',
  ),
  _SlideData(
    icon:        Icons.insights_rounded,
    accentColor: _kBlue,
    tag:         'تتبع التقدم',
    title:       'شاهد نتائجك\nتتحقق يوماً بيوم',
    body:        'رسوم بيانية واضحة ومقارنات أسبوعية\nتُريك كيف تتحسّن كل يوم',
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
                      'تخطي',
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
                _DarkButton(
                  label:   current == _slides.length - 1 ? 'إعداد ملفي الشخصي' : 'التالي',
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
    if (v == null) return 'أدخل رقماً صحيحاً';
    if (v < _minAge || v > _maxAge) return 'بين $_minAge و$_maxAge سنة';
    return null;
  }
  String? _heightError() {
    final v = double.tryParse(_heightCtrl.text.trim());
    if (v == null) return 'أدخل رقماً صحيحاً';
    if (v < _minH || v > _maxH) return 'بين $_minH و$_maxH سم';
    return null;
  }
  String? _weightError() {
    final v = double.tryParse(_weightCtrl.text.trim());
    if (v == null) return 'أدخل رقماً صحيحاً';
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
                        child: Text('إعداد الملف الشخصي',
                          style: AppTextStyles.labelSmall.copyWith(color: _kAccent)),
                      ),
                    ]),
                    const SizedBox(height: AppConstants.spaceL),
                    const Text('أخبرنا\nعن نفسك',
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w900,
                        color: _kTextHigh, height: 1.15, letterSpacing: -0.5,
                      )),
                    const SizedBox(height: AppConstants.spaceS),
                    Text('لنحسب أهدافك اليومية بدقة',
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
                _Label('الاسم'),
                const SizedBox(height: AppConstants.spaceS),
                _Field(controller: _nameCtrl, hint: 'اسمك الكريم',
                    textDirection: TextDirection.rtl,
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: AppConstants.spaceXXL),

                // Age + Height
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label('العمر'),
                    const SizedBox(height: AppConstants.spaceS),
                    _Field(controller: _ageCtrl, hint: '25', suffix: 'سنة',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        errorText: _ageCtrl.text.isEmpty ? null : _ageError()),
                  ])),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label('الطول'),
                    const SizedBox(height: AppConstants.spaceS),
                    _Field(controller: _heightCtrl, hint: '175', suffix: 'سم',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        errorText: _heightCtrl.text.isEmpty ? null : _heightError()),
                  ])),
                ]),
                const SizedBox(height: AppConstants.spaceXXL),

                // Weight
                _Label('الوزن'),
                const SizedBox(height: AppConstants.spaceS),
                _Field(controller: _weightCtrl, hint: '70.0', suffix: 'كجم',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    errorText: _weightCtrl.text.isEmpty ? null : _weightError()),
                const SizedBox(height: AppConstants.spaceXXL),

                // Gender
                _Label('الجنس'),
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
                _Label('هدفك من التمرين'),
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
                _Label('مستوى نشاطك'),
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
                  builder: (ctx, st) => _DarkButton(
                    label:    'ابدأ رحلتك ⚡',
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
        fontWeight: FontWeight.w600, color: _kTextMid, letterSpacing: 0.3));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(color: _kBorder, thickness: 1);
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller, required this.hint,
    this.suffix, this.keyboardType,
    this.textDirection = TextDirection.ltr,
    required this.onChanged, this.errorText,
  });
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final TextDirection textDirection;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      textDirection: textDirection, onChanged: onChanged,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
          color: _kTextHigh, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: _kTextLow),
        suffixText: suffix,
        suffixStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: _kTextMid),
        errorText: errorText,
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _kDanger),
        filled: true, fillColor: _kSurface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceL, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kDanger, width: 1.5),
        ),
      ),
    );
  }
}

class _DarkSegment<T> extends StatelessWidget {
  const _DarkSegment({
    required this.values, required this.selected,
    required this.label, required this.onSelect,
  });
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _kSurface, borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: values.map((v) {
        final active = v == selected;
        return Expanded(child: GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: AppConstants.durationFast,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? _kAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Text(label(v), textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? const Color(0xFF0F0F0F) : _kTextMid)),
          ),
        ));
      }).toList()),
    );
  }
}

class _DarkOptionTile extends StatelessWidget {
  const _DarkOptionTile({
    required this.label, required this.icon,
    required this.accent, required this.selected, required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceL, vertical: AppConstants.spaceM),
        decoration: BoxDecoration(
          color:        selected ? accent.withOpacity(0.1) : _kSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: selected ? accent : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.15) : _kSurface2,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, size: 18, color: selected ? accent : _kTextMid),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(child: Text(label,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? accent : _kTextHigh))),
          if (selected)
            Icon(Icons.check_circle_rounded, color: accent, size: 18),
        ]),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({
    required this.label, required this.onTap, required this.accent,
    this.loading = false, this.disabled = false,
  });
  final String label;
  final VoidCallback? onTap;
  final Color accent;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final active = !disabled && !loading && onTap != null;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        height: AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color:        active ? accent : _kSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: active ? Colors.transparent : _kBorder),
        ),
        child: Center(child: loading
            ? SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: active ? const Color(0xFF0F0F0F) : _kTextMid),
              )
            : Text(label,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: active ? const Color(0xFF0F0F0F) : _kTextLow))),
      ),
    );
  }
}
