import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_input.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

class BmiWidget extends StatelessWidget {
  BmiWidget({super.key});
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Inputs ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        PpNumberInput(
                          label: 'الطول',
                          hint: 'مثال: 175',
                          suffix: 'سم',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'أدخل الطول';
                            final n = double.tryParse(v);
                            if (n == null) return 'رقم غير صالح';
                            if (n < 50 || n > 250)
                              return 'طول غير منطقي (50–250 سم)';
                            return null;
                          },
                          onChanged: (v) =>
                              cubit.height1 = double.tryParse(v) ?? 0,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PpNumberInput(
                          label: 'الوزن',
                          hint: 'مثال: 75',
                          suffix: 'كجم',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'أدخل الوزن';
                            final n = double.tryParse(v);
                            if (n == null) return 'رقم غير صالح';
                            if (n < 10 || n > 500)
                              return 'وزن غير منطقي (10–500 كجم)';
                            return null;
                          },
                          onChanged: (v) =>
                              cubit.weight1 = double.tryParse(v) ?? 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── CTA ───────────────────────────────────────────────────
                  PpButton(
                    label: 'احسب BMI',
                    icon: Icons.calculate_rounded,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        cubit.calculatedBMI = cubit.weight1 /
                            (cubit.height1 * cubit.height1) *
                            10000;
                        cubit.emit(AppStateUpdatedState());
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Result ─────────────────────────────────────────────────
                  if (cubit.calculatedBMI > 0) ...[
                    _ResultCard(
                        bmi: cubit.calculatedBMI, label: cubit.getResultText()),
                    const SizedBox(height: AppSpacing.sm),
                    _BmiGauge(bmi: cubit.calculatedBMI),
                  ] else
                    _EmptyState(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Color _bmiColor(double bmi) {
  if (bmi < 18.5) return AppColors.bmiUnderweight;
  if (bmi <= 24.9) return AppColors.bmiNormal;
  if (bmi <= 29.9) return AppColors.bmiOverweight;
  if (bmi <= 40.0) return AppColors.bmiObese;
  return AppColors.bmiMorbidObese;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.bmi, required this.label});
  final double bmi;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = _bmiColor(bmi);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: c.withOpacity(0.35), width: 1.5),
        boxShadow: [BoxShadow(color: c.withOpacity(0.1), blurRadius: 24)],
      ),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('التصنيف', style: AppTextStyles.labelMuted),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: c.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: c.withOpacity(0.4))),
              child: Text(label,
                  style:
                      AppTextStyles.labelCaps.copyWith(color: c, fontSize: 13)),
            ),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('المؤشر', style: AppTextStyles.labelMuted),
            const SizedBox(height: 4),
            Text(bmi.toStringAsFixed(1),
                style: AppTextStyles.displayMetrics
                    .copyWith(fontSize: 44, color: c)),
          ]),
        ],
      ),
    );
  }
}

class _BmiGauge extends StatelessWidget {
  const _BmiGauge({required this.bmi});
  final double bmi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SfRadialGauge(
        backgroundColor: Colors.transparent,
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 55,
            axisLineStyle:
                const AxisLineStyle(color: Color(0x12FFFFFF), thickness: 10),
            majorTickStyle: const MajorTickStyle(
                color: AppColors.outlineVariant, thickness: 1),
            minorTickStyle: const MinorTickStyle(
                color: AppColors.outlineVariant, thickness: 0.5),
            axisLabelStyle:
                GaugeTextStyle(color: AppColors.textSecondary, fontSize: 11),
            ranges: [
              GaugeRange(
                  startValue: 0,
                  endValue: 18.5,
                  color: AppColors.bmiUnderweight.withOpacity(0.8),
                  rangeOffset: 0.05),
              GaugeRange(
                  startValue: 18.5,
                  endValue: 24.9,
                  color: AppColors.bmiNormal.withOpacity(0.8),
                  rangeOffset: 0.05),
              GaugeRange(
                  startValue: 25,
                  endValue: 29.9,
                  color: AppColors.bmiOverweight.withOpacity(0.8),
                  rangeOffset: 0.05),
              GaugeRange(
                  startValue: 30,
                  endValue: 40,
                  color: AppColors.bmiObese.withOpacity(0.8),
                  rangeOffset: 0.05),
              GaugeRange(
                  startValue: 40,
                  endValue: 55,
                  color: AppColors.bmiMorbidObese.withOpacity(0.8),
                  rangeOffset: 0.05),
            ],
            pointers: [
              NeedlePointer(
                value: bmi,
                enableAnimation: true,
                animationDuration: 900,
                animationType: AnimationType.easeOutBack,
                needleColor: AppColors.primary,
                knobStyle: KnobStyle(
                    color: AppColors.primaryContainer,
                    borderColor: AppColors.primary,
                    borderWidth: 0.05,
                    knobRadius: 0.08),
                tailStyle: const TailStyle(
                    color: AppColors.primary, width: 1.5, length: 0.2),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(bmi.toStringAsFixed(1),
                    style: AppTextStyles.displayMetrics
                        .copyWith(fontSize: 26, color: _bmiColor(bmi))),
                angle: 90,
                positionFactor: 0.8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.monitor_weight_outlined,
            color: AppColors.outline, size: 38),
        const SizedBox(height: AppSpacing.xs),
        Text('أدخل بياناتك لحساب المؤشر', style: AppTextStyles.bodyMuted),
      ]),
    );
  }
}
