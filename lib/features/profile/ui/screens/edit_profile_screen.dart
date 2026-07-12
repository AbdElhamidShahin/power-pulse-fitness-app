import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_button.dart';
import '../../data/models/user_profile_entity.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});
  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  late Gender        _gender;
  late FitnessGoal   _goal;
  late ActivityLevel _activity;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl   = TextEditingController(text: p.name);
    _ageCtrl    = TextEditingController(text: p.age.toString());
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: p.weightKg.toStringAsFixed(1));
    _gender   = p.gender;
    _goal     = p.goal;
    _activity = p.activityLevel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  UserProfile get _built => widget.profile.copyWith(
        name:          _nameCtrl.text.trim(),
        age:           int.tryParse(_ageCtrl.text) ?? widget.profile.age,
        heightCm:      double.tryParse(_heightCtrl.text) ?? widget.profile.heightCm,
        weightKg:      double.tryParse(_weightCtrl.text) ?? widget.profile.weightKg,
        gender:        _gender,
        goal:          _goal,
        activityLevel: _activity,
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSaveCubit, ProfileSaveState>(
      listener: (context, state) {
        if (state is ProfileSaveSuccess) {
          context.read<ProfileCubit>().onProfileSaved(_built);
          Navigator.of(context).pop();
        } else if (state is ProfileSaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.screenPaddingH,
                    AppConstants.spaceL,
                    AppConstants.screenPaddingH,
                    AppConstants.spaceXXL,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary, size: AppConstants.iconS),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Text('تعديل الملف الشخصي',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPaddingH),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ─── Basic Info ──────────────────────────
                    _SectionTitle('المعلومات الأساسية'),
                    const SizedBox(height: AppConstants.spaceM),
                    _Field(label: 'الاسم', controller: _nameCtrl,
                        hint: 'اسمك', type: TextInputType.name),
                    const SizedBox(height: AppConstants.spaceM),

                    Row(children: [
                      Expanded(child: _Field(
                          label: 'العمر', controller: _ageCtrl,
                          hint: '25', type: TextInputType.number, suffix: 'سنة')),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(child: _Field(
                          label: 'الطول', controller: _heightCtrl,
                          hint: '175', type: TextInputType.number, suffix: 'سم')),
                    ]),
                    const SizedBox(height: AppConstants.spaceM),

                    _Field(label: 'الوزن', controller: _weightCtrl,
                        hint: '75.0', type: const TextInputType.numberWithOptions(decimal: true),
                        suffix: 'كج'),
                    const SizedBox(height: AppConstants.spaceXXL),

                    // ─── Gender ──────────────────────────────
                    _SectionTitle('الجنس'),
                    const SizedBox(height: AppConstants.spaceM),
                    _SegmentedPicker<Gender>(
                      values: Gender.values,
                      selected: _gender,
                      label: (g) => g.labelAr,
                      onSelect: (g) => setState(() => _gender = g),
                    ),
                    const SizedBox(height: AppConstants.spaceXXL),

                    // ─── Goal ────────────────────────────────
                    _SectionTitle('هدفك'),
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

                    // ─── Activity ────────────────────────────
                    _SectionTitle('مستوى النشاط'),
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

                    // ─── Save ────────────────────────────────
                    BlocBuilder<ProfileSaveCubit, ProfileSaveState>(
                      builder: (context, state) => PPButton(
                        label: 'حفظ التغييرات',
                        isLoading: state is ProfileSaveLoading,
                        onPressed: () =>
                            context.read<ProfileSaveCubit>().save(_built),
                      ),
                    ),
                    const SizedBox(height: AppConstants.space3XL),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Small Reusable Widgets ──────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: Theme.of(context).textTheme.headlineSmall);
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.type,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType type;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppConstants.spaceS),
        TextField(
          controller: controller,
          keyboardType: type,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
}

class _SegmentedPicker<T> extends StatelessWidget {
  const _SegmentedPicker({
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
          final isSelected = v == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(v),
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  label(v),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
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
