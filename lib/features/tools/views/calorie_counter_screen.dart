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

class Culcolatecounting extends StatefulWidget {
  const Culcolatecounting({super.key});
  @override
  State<Culcolatecounting> createState() => _State();
}

class _State extends State<Culcolatecounting> {
  final _formKey = GlobalKey<FormState>();

  static const _activityItems = [
    ('قليل النشاط', 'culc1'),
    ('نشاط خفيف', 'culc2'),
    ('نشاط معتدل', 'culc3'),
    ('نشاط كبير', 'culc4'),
    ('نشاط شديد', 'culc5'),
  ];

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
              appBar: const PpBackBar(title: 'السعرات الحرارية'),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('حساب السعرات الحرارية', style: AppTextStyles.headlineLgMobile),
                      const SizedBox(height: 4),
                      Text('Daily Calorie Calculator', style: AppTextStyles.labelMuted),
                      const SizedBox(height: AppSpacing.md),

                      // ── Form card ──────────────────────────────────────
                      PpCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                        child: Column(
                          children: [
                            PpNumberInput(label: 'الطول', hint: 'مثال: 175', suffix: 'سم',
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'أدخل الطول';
                                final n = double.tryParse(v);
                                if (n == null) return 'رقم غير صالح';
                                if (n < 50 || n > 250) return 'طول غير منطقي (50–250 سم)';
                                return null;
                              },
                              onChanged: (v) => cubit.height0 = double.tryParse(v) ?? 0),
                            const SizedBox(height: AppSpacing.sm),
                            PpNumberInput(label: 'العمر', hint: 'مثال: 25', suffix: 'سنة',
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'أدخل العمر';
                                final n = double.tryParse(v);
                                if (n == null) return 'رقم غير صالح';
                                if (n < 5 || n > 120) return 'عمر غير منطقي (5–120)';
                                return null;
                              },
                              onChanged: (v) => cubit.age = double.tryParse(v) ?? 0),
                            const SizedBox(height: AppSpacing.sm),
                            PpNumberInput(label: 'الوزن', hint: 'مثال: 75', suffix: 'كجم',
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'أدخل الوزن';
                                final n = double.tryParse(v);
                                if (n == null) return 'رقم غير صالح';
                                if (n < 10 || n > 500) return 'وزن غير منطقي (10–500 كجم)';
                                return null;
                              },
                              onChanged: (v) => cubit.weight = double.tryParse(v) ?? 0),
                            const SizedBox(height: AppSpacing.md),

                            // Gender
                            Align(alignment: Alignment.centerRight, child: Text('النوع', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700))),
                            const SizedBox(height: AppSpacing.xs),
                            Row(children: [
                              _SelectBtn(label: 'أنثى ♀', selected: cubit.gender0 == 'FEMALE', onTap: () => setState(() => cubit.gender0 = 'FEMALE')),
                              const SizedBox(width: AppSpacing.xs),
                              _SelectBtn(label: 'ذكر ♂', selected: cubit.gender0 == 'MALE', onTap: () => setState(() => cubit.gender0 = 'MALE')),
                            ]),
                            const SizedBox(height: AppSpacing.md),

                            // Activity level
                            Align(alignment: Alignment.centerRight, child: Text('مستوى النشاط', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700))),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(AppSpacing.radius),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: cubit.activityLevel.isEmpty ? null : cubit.activityLevel,
                                  isExpanded: true,
                                  hint: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('اختر مستوى النشاط', style: AppTextStyles.bodyMuted, textAlign: TextAlign.end)),
                                  dropdownColor: AppColors.surfaceHigh,
                                  icon: const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.expand_more_rounded, color: AppColors.outline)),
                                  items: _activityItems.map((a) => DropdownMenuItem(value: a.$2,
                                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(a.$1, style: AppTextStyles.bodyMd, textAlign: TextAlign.end)))).toList(),
                                  onChanged: (v) => setState(() => cubit.activityLevel = v ?? ''),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      PpButton(
                        label: 'احسب السعرات',
                        icon: Icons.local_fire_department_rounded,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) cubit.calculateFinalResult();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Results ────────────────────────────────────────
                      if (cubit.finalResult > 0) ...[
                        _MainResultCard(value: cubit.finalResult),
                        if (cubit.showCalorieTexts) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _CalorieTargets(cubit: cubit),
                        ],
                      ] else
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

class _SelectBtn extends StatelessWidget {
  const _SelectBtn({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outlineVariant, width: selected ? 1.5 : 1),
        ),
        child: Text(label, style: AppTextStyles.bodyMd.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ),
    ),
  );
}

class _MainResultCard extends StatelessWidget {
  const _MainResultCard({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => PpCard(
    borderColor: AppColors.warning.withOpacity(0.4),
    glowColor: AppColors.warning,
    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('احتياجك اليومي', style: AppTextStyles.labelMuted),
        const SizedBox(height: 4),
        Text('للحفاظ على الوزن', style: AppTextStyles.bodyMd.copyWith(color: AppColors.warning)),
      ]),
      const Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(value.toStringAsFixed(0), style: AppTextStyles.displayMetrics.copyWith(fontSize: 44, color: AppColors.warning)),
        Text('سعرة / يوم', style: AppTextStyles.labelMuted),
      ]),
    ]),
  );
}

class _CalorieTargets extends StatelessWidget {
  const _CalorieTargets({required this.cubit});
  final AppCubit cubit;

  @override
  Widget build(BuildContext context) {
    final targets = [
      ('انقاص 0.5 كجم/أسبوع', cubit.finalResult - cubit.B, AppColors.success),
      ('انقاص 1.0 كجم/أسبوع', cubit.finalResult - cubit.A, AppColors.success),
      ('زيادة 0.5 كجم/أسبوع', cubit.finalResult + cubit.B, AppColors.primary),
      ('زيادة 1.0 كجم/أسبوع', cubit.finalResult + cubit.A, AppColors.primary),
    ];
    return Column(
      children: targets.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: t.$3.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text('${t.$2.toStringAsFixed(0)} سعرة', style: AppTextStyles.headingSmall.copyWith(color: t.$3)),
            const Spacer(),
            Text(t.$1, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          ]),
        ),
      )).toList(),
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
      const Icon(Icons.local_fire_department_outlined, color: AppColors.outline, size: 36),
      const SizedBox(height: AppSpacing.xs),
      Text('أدخل بياناتك لحساب سعراتك', style: AppTextStyles.bodyMuted),
    ]),
  );
}
