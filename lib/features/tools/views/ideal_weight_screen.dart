import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../core/ui/components/pp_input.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

class Idelweight extends StatelessWidget {
  Idelweight({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (_, __) {},
        builder: (context, state) {
          final cubit = AppCubit.get(context);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: const PpBackBar(title: 'الوزن المثالي'),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الوزن المثالي', style: AppTextStyles.headlineLgMobile),
                      const SizedBox(height: 4),
                      Text('Ideal Body Weight', style: AppTextStyles.labelMuted),
                      const SizedBox(height: AppSpacing.md),

                      // ── Form card ──────────────────────────────────────
                      PpCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                        child: Column(
                          children: [
                            PpNumberInput(
                              label: 'الطول', hint: 'مثال: 175', suffix: 'سم',
                              validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                              onChanged: (v) => cubit.height = double.tryParse(v) ?? 0,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Gender selector
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('النوع', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                _GenderBtn(label: 'أنثى ♀', value: 'FEMALE', selected: cubit.gender == 'FEMALE', onTap: () => cubit.updateGender('FEMALE')),
                                const SizedBox(width: AppSpacing.xs),
                                _GenderBtn(label: 'ذكر ♂', value: 'MALE', selected: cubit.gender == 'MALE', onTap: () => cubit.updateGender('MALE')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      PpButton(
                        label: 'احسب الوزن المثالي',
                        icon: Icons.calculate_rounded,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) cubit.Idelweight();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Result ─────────────────────────────────────────
                      if (cubit.result > 0)
                        _ResultCard(result: cubit.result)
                      else
                        _EmptyResult(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  const _GenderBtn({required this.label, required this.value, required this.selected, required this.onTap});
  final String label, value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: selected ? AppColors.primary : AppColors.outlineVariant, width: selected ? 1.5 : 1),
          ),
          child: Text(label,
            style: AppTextStyles.bodyMd.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final double result;

  @override
  Widget build(BuildContext context) {
    return PpCard(
      borderColor: AppColors.success.withOpacity(0.4),
      glowColor: AppColors.success,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('النتيجة', style: AppTextStyles.labelMuted),
            const SizedBox(height: 4),
            Text('الوزن المثالي', style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(result.toStringAsFixed(1), style: AppTextStyles.displayMetrics.copyWith(fontSize: 44, color: AppColors.success)),
            Text('كجم', style: AppTextStyles.labelMuted),
          ]),
        ],
      ),
    );
  }
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
      Text('أدخل بياناتك لحساب وزنك المثالي', style: AppTextStyles.bodyMuted),
    ]),
  );
}
