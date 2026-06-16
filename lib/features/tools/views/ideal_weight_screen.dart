import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../core/ui/components/pp_input.dart';
import '../data/repo/tools_repositories.dart';
import '../logic/cubit/tools_cubits.dart';
import '../logic/cubit/tools_states.dart';

class Idelweight extends StatelessWidget {
  const Idelweight({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IdealWeightCubit(const IdealWeightRepositoryImpl()),
      child: const _IdealWeightBody(),
    );
  }
}

class _IdealWeightBody extends StatefulWidget {
  const _IdealWeightBody();
  @override
  State<_IdealWeightBody> createState() => _State();
}

class _State extends State<_IdealWeightBody> {
  final _formKey = GlobalKey<FormState>();
  double _height = 0;
  String _gender = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PpBackBar(title: 'الوزن المثالي'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('الوزن المثالي', style: AppTextStyles.headlineLgMobile),
                const SizedBox(height: 4),
                Text('Ideal Body Weight', style: AppTextStyles.labelMuted),
                const SizedBox(height: AppSpacing.md),
                PpCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                  child: Column(children: [
                    PpNumberInput(
                      label: 'الطول',
                      hint: 'مثال: 175',
                      suffix: 'سم',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'مطلوب';
                        final n = double.tryParse(v);
                        if (n == null) return 'رقم غير صالح';
                        if (n < 50 || n > 250)
                          return 'طول غير منطقي (50–250 سم)';
                        return null;
                      },
                      onChanged: (v) => _height = double.tryParse(v) ?? 0,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text('النوع',
                            style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700))),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [
                      _GenderBtn(
                          label: 'أنثى ♀',
                          value: 'FEMALE',
                          selected: _gender == 'FEMALE',
                          onTap: () => setState(() => _gender = 'FEMALE')),
                      const SizedBox(width: AppSpacing.xs),
                      _GenderBtn(
                          label: 'ذكر ♂',
                          value: 'MALE',
                          selected: _gender == 'MALE',
                          onTap: () => setState(() => _gender = 'MALE')),
                    ]),
                  ]),
                ),
                const SizedBox(height: AppSpacing.sm),
                PpButton(
                  label: 'احسب الوزن المثالي',
                  icon: Icons.calculate_rounded,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_gender.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('اختر النوع'),
                                backgroundColor: AppColors.error));
                        return;
                      }
                      context
                          .read<IdealWeightCubit>()
                          .calculate(heightCm: _height, gender: _gender);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<IdealWeightCubit, IdealWeightState>(
                  builder: (_, state) => switch (state) {
                    IdealWeightInitial() => _EmptyResult(),
                    IdealWeightError(:final message) => PpCard(
                        borderColor: AppColors.error.withOpacity(0.4),
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Text(message,
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.error),
                            textAlign: TextAlign.center),
                      ),
                    IdealWeightLoaded(:final kg) => _ResultCard(result: kg),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  const _GenderBtn(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});
  final String label, value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                  color:
                      selected ? AppColors.primary : AppColors.outlineVariant,
                  width: selected ? 1.5 : 1),
            ),
            child: Text(label,
                style: AppTextStyles.bodyMd.copyWith(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final double result;

  @override
  Widget build(BuildContext context) => PpCard(
        borderColor: AppColors.success.withOpacity(0.4),
        glowColor: AppColors.success,
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('النتيجة', style: AppTextStyles.labelMuted),
            const SizedBox(height: 4),
            Text('الوزن المثالي',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(result.toStringAsFixed(1),
                style: AppTextStyles.displayMetrics
                    .copyWith(fontSize: 44, color: AppColors.success)),
            Text('كجم', style: AppTextStyles.labelMuted),
          ]),
        ]),
      );
}

class _EmptyResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.scale_outlined, color: AppColors.outline, size: 36),
          const SizedBox(height: AppSpacing.xs),
          Text('أدخل بياناتك لحساب وزنك المثالي',
              style: AppTextStyles.bodyMuted),
        ]),
      );
}
