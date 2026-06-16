import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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

class BmiCalculatorScreen extends StatelessWidget {
  const BmiCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BmiCubit(const BmiRepositoryImpl()),
      child: const _BmiBody(),
    );
  }
}

class _BmiBody extends StatefulWidget {
  const _BmiBody();
  @override
  State<_BmiBody> createState() => _BmiBodyState();
}

class _BmiBodyState extends State<_BmiBody> {
  final _formKey = GlobalKey<FormState>();
  double _height = 0, _weight = 0;

  static const _ranges = [
    ('نقص وزن', AppColors.bmiUnderweight),
    ('صحي', AppColors.bmiNormal),
    ('زيادة', AppColors.bmiOverweight),
    ('سمنة', AppColors.bmiObese),
    ('مفرط', AppColors.bmiMorbidObese),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PpBackBar(title: 'مؤشر كتلة الجسم'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('مؤشر كتلة الجسم', style: AppTextStyles.headlineLgMobile),
                const SizedBox(height: 4),
                Text('Body Mass Index — BMI', style: AppTextStyles.labelMuted),
                const SizedBox(height: AppSpacing.sm),

                // ── Ranges bar ─────────────────────────────────────────
                PpCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('نطاقات المؤشر', style: AppTextStyles.labelMuted),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: _ranges
                            .map((r) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: r.$2.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusFull),
                                      border: Border.all(
                                          color: r.$2.withOpacity(0.35)),
                                    ),
                                    child: Text(r.$1,
                                        style: AppTextStyles.labelCaps.copyWith(
                                            color: r.$2, fontSize: 8.5),
                                        textAlign: TextAlign.center),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                PpCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
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
                        onChanged: (v) => _height = double.tryParse(v) ?? 0,
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
                        onChanged: (v) => _weight = double.tryParse(v) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                PpButton(
                  label: 'احسب BMI',
                  icon: Icons.calculate_rounded,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context
                          .read<BmiCubit>()
                          .calculate(heightCm: _height, weightKg: _weight);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Result ─────────────────────────────────────────────
                BlocBuilder<BmiCubit, BmiState>(
                  builder: (_, state) => switch (state) {
                    BmiInitial() => _BmiEmpty(),
                    BmiError(:final message) => _BmiErrorCard(message),
                    BmiLoaded(:final result) => _BmiResult(result: result),
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

class _BmiEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.monitor_weight_outlined,
              color: AppColors.outline, size: 36),
          const SizedBox(height: AppSpacing.xs),
          Text('أدخل بياناتك لحساب المؤشر', style: AppTextStyles.bodyMuted),
        ]),
      );
}

class _BmiErrorCard extends StatelessWidget {
  const _BmiErrorCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => PpCard(
        borderColor: AppColors.error.withOpacity(0.4),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Text(message,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
            textAlign: TextAlign.center),
      );
}

class _BmiResult extends StatelessWidget {
  const _BmiResult({required this.result});
  final BmiResult result;

  @override
  Widget build(BuildContext context) {
    final color = Color(result.color);
    return Column(
      children: [
        PpCard(
          borderColor: color.withOpacity(0.4),
          glowColor: color,
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: SfRadialGauge(
                  backgroundColor: Colors.transparent,
                  axes: [
                    RadialAxis(
                      minimum: 10,
                      maximum: 45,
                      axisLineStyle: const AxisLineStyle(
                          color: Color(0x12FFFFFF), thickness: 10),
                      axisLabelStyle: GaugeTextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                      ranges: [
                        GaugeRange(
                            startValue: 10,
                            endValue: 18.5,
                            color: AppColors.bmiUnderweight.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 18.5,
                            endValue: 25,
                            color: AppColors.bmiNormal.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 25,
                            endValue: 30,
                            color: AppColors.bmiOverweight.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 30,
                            endValue: 40,
                            color: AppColors.bmiObese.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 40,
                            endValue: 45,
                            color: AppColors.bmiMorbidObese.withOpacity(0.8)),
                      ],
                      pointers: [
                        NeedlePointer(
                            value: result.bmi.clamp(10, 45),
                            needleColor: color,
                            enableAnimation: true)
                      ],
                      annotations: [
                        GaugeAnnotation(
                          widget:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(result.bmi.toStringAsFixed(1),
                                style: AppTextStyles.headlineMd
                                    .copyWith(color: color, fontSize: 28)),
                            Text('BMI', style: AppTextStyles.labelMuted),
                          ]),
                          angle: 90,
                          positionFactor: 0.5,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(result.category,
                    style: AppTextStyles.headingSmall.copyWith(color: color),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
