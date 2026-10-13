import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/app_localizations.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:power_pulse/core/constants/app_constants.dart';
import '../../../../core/startup.dart';
import 'package:power_pulse/core/theme/app_colors.dart';
import 'package:power_pulse/core/theme/app_text_styles.dart';
import 'package:power_pulse/shared/widgets/pp_button.dart';
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

const _pageCount = 3;

List<_PageData> _buildPages(BuildContext context) => [
  _PageData(
    icon: Icons.fitness_center_rounded,
    title: context.l10n.onboardingTitle1,
    subtitle: context.l10n.onboardingSubtitle1,
    color: AppColors.accent,
  ),
  _PageData(
    icon: Icons.restaurant_rounded,
    title: context.l10n.onboardingTitle2,
    subtitle: context.l10n.onboardingSubtitle2,
    color: AppColors.info,
  ),
  _PageData(
    icon: Icons.bar_chart_rounded,
    title: context.l10n.onboardingTitle3,
    subtitle: context.l10n.onboardingSubtitle3,
    color: AppColors.warning,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.introOnly = false});

  /// When true, this route shows only the three first-run introduction pages.
  /// Profile setup lives on the separate /onboarding route.
  final bool introOnly;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;
  bool _showSetup = false;

  @override
  void initState() {
    super.initState();
    _showSetup = !widget.introOnly;
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_completed', true);
    AppStartup.markIntroCompleted();
    if (!mounted) return;
    final nextRoute = AppStartup.needsEntry
        ? '/entry'
        : (AppStartup.needsProfileSetup ? '/onboarding' : '/home');
    context.go(nextRoute);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pageCount - 1) {
      _pageCtrl.nextPage(
        duration: AppConstants.durationPage,
        curve: Curves.easeInOut,
      );
    } else if (widget.introOnly) {
      _completeIntro();
    } else {
      setState(() => _showSetup = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: SafeArea(
        child: _showSetup
            ? const _SetupForm()
            : _IntroPages(
          pageCtrl: _pageCtrl,
          current: _current,
          onPageChanged: (i) => setState(() => _current = i),
          onNext: _next,
          onSkip: widget.introOnly
              ? _completeIntro
              : () => setState(() => _showSetup = true),
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
            child: Text(context.l10n.skip,
                style: Theme.of(context).textTheme.labelMedium!
                    .copyWith(color: context.colors.textMuted)),
          ),
        ),

        // Pages
        Expanded(
          child: PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: _pageCount,
            itemBuilder: (_, i) =>
                _OnboardingPage(page: _buildPages(context)[i]),
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
                  _pageCount,
                      (i) => AnimatedContainer(
                    duration: AppConstants.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: current == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: current == i
                          ? AppColors.accent
                          : context.colors.bgElevated,
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceXXL),
              PPButton(
                label: current == _pageCount - 1
                    ? context.l10n.startSetup
                    : context.l10n.next,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceXXL,
        vertical: AppConstants.spaceL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle — sized relative to screen height for all devices
          LayoutBuilder(builder: (context, constraints) {
            final circleSize = MediaQuery.of(context).size.height * 0.22;
            return Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.color.withValues(alpha: 0.12),
                border: Border.all(
                    color: page.color.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(page.icon, color: page.color,
                  size: circleSize * 0.44),
            );
          }),
          const SizedBox(height: AppConstants.spaceXXL),
          Text(
            page.title,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge!
                .copyWith(color: context.colors.textSecondary),
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
          (int.tryParse(_ageCtrl.text) ?? 0) >= 13 &&
          (int.tryParse(_ageCtrl.text) ?? 0) <= 110 &&
          (double.tryParse(_heightCtrl.text) ?? 0) >= 80 &&
          (double.tryParse(_heightCtrl.text) ?? 0) <= 250 &&
          (double.tryParse(_weightCtrl.text) ?? 0) >= 20 &&
          (double.tryParse(_weightCtrl.text) ?? 0) <= 400;

  /// 0.0–1.0 progress based on how many of the 4 required fields are valid.
  double get _setupProgress {
    int filled = 0;
    if (_nameCtrl.text.trim().isNotEmpty) filled++;
    final age = int.tryParse(_ageCtrl.text) ?? 0;
    if (age >= 13 && age <= 110) filled++;
    final height = double.tryParse(_heightCtrl.text) ?? 0;
    if (height >= 80 && height <= 250) filled++;
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    if (weight >= 20 && weight <= 400) filled++;
    return filled / 4.0;
  }

  UserProfile get _profile => UserProfile(
    name:          _nameCtrl.text.trim(),
    age:           int.tryParse(_ageCtrl.text) ?? 0,
    heightCm:      double.tryParse(_heightCtrl.text) ?? 0,
    weightKg:      double.tryParse(_weightCtrl.text) ?? 0,
    gender:        _gender,
    goal:          _goal,
    activityLevel: _activity,
    email: Supabase.instance.client.auth.currentUser?.email ?? '',
  );

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<ProfileSaveCubit, ProfileSaveState>(
      listener: (context, state) {
        if (state is ProfileSaveSuccess) {
          context.go('/home');
        } else if (state is ProfileSaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: CustomScrollView(
        slivers: [
          // ─── Header ───────────────────────────────────────
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
                  // Setup progress indicator
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _setupProgress,
                            backgroundColor:
                                context.colors.borderSubtle,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accent),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_setupProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceL),
                  Text(
                    context.l10n.tellUsAboutYourself,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                  Text(
                    context.l10n.calculateGoalsAccurately,
                    style: Theme.of(context).textTheme.bodyMedium!
                        .copyWith(color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          ),

          // ─── Fields ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Name
                _FieldLabel(context.l10n.nameLabel),
                const SizedBox(height: AppConstants.spaceS),
                TextField(
                  controller: _nameCtrl,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  onChanged: (_) => setState(() {}),
                  style: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: context.l10n.yourNameHint,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),

                // Age + Height — side by side
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(context.l10n.ageLabel),
                        const SizedBox(height: AppConstants.spaceS),
                        TextField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          onChanged: (_) => setState(() {}),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '25',
                            suffixText: context.l10n.years,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(context.l10n.height),
                        const SizedBox(height: AppConstants.spaceS),
                        TextField(
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          onChanged: (_) => setState(() {}),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '175',
                            suffixText: context.l10n.translate('cmUnit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: AppConstants.spaceL),

                // Weight
                _FieldLabel(context.l10n.weight),
                const SizedBox(height: AppConstants.spaceS),
                TextField(
                  controller: _weightCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  onChanged: (_) => setState(() {}),
                  style: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '75.0',
                    suffixText: context.l10n.translate('kgUnit'),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Gender
                _FieldLabel(context.l10n.gender),
                const SizedBox(height: AppConstants.spaceM),
                _SegmentRow<Gender>(
                  values: Gender.values,
                  selected: _gender,
                  label: (g) => context.l10n.translate(g.name),
                  onSelect: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: AppConstants.spaceXXL),

                // Goal
                _FieldLabel(context.l10n.goal),
                const SizedBox(height: AppConstants.spaceM),
                ...FitnessGoal.values.map((g) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.spaceS),
                  child: _OptionTile(
                    label: context.l10n.translate(g.name),
                    selected: _goal == g,
                    onTap: () => setState(() => _goal = g),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceL),

                // Activity
                _FieldLabel(context.l10n.activityLevel),
                const SizedBox(height: AppConstants.spaceM),
                ...ActivityLevel.values.map((a) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.spaceS),
                  child: _OptionTile(
                    label: context.l10n.translate(a.name),
                    selected: _activity == a,
                    onTap: () => setState(() => _activity = a),
                  ),
                )),
                const SizedBox(height: AppConstants.spaceXXL),

                // Submit button
                BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                  builder: (context, state) => PPButton(
                    label: '${context.l10n.translate('startJourney')} 🚀',
                    isLoading: state is ProfileSaveLoading,
                    isDisabled: !_isValid,
                    onPressed: _isValid
                        ? () =>
                        context.read<ProfileSaveCubit>().save(_profile)
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

// ─── _FieldLabel ─────────────────────────────────────────────
/// Label فوق كل حقل — يأخذ اللون من context.colors تلقائياً
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium!
        .copyWith(color: context.colors.textSecondary),
  );
}

// ─── _SegmentRow ─────────────────────────────────────────────
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
        color: context.colors.bgElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: context.colors.borderSubtle),
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
                        : context.colors.textMuted,
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

// ─── _OptionTile ─────────────────────────────────────────────
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
          color: selected ? AppColors.accentDim : context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : context.colors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: selected
                      ? AppColors.accent
                      : context.colors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: AppConstants.iconS,
              ),
          ],
        ),
      ),
    );
  }
}
