import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (_, __) {},
        builder: (context, state) {
          final cubit = AppCubit.get(context);
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const PpBackBar(title: 'تفاصيل الطعام'),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('تفاصيل الطعام', style: AppTextStyles.headlineLgMobile),
                  const SizedBox(height: 4),
                  Text('Food Nutrition Details',
                      style: AppTextStyles.labelMuted),
                  const SizedBox(height: AppSpacing.md),

                  // ── Search input ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search_rounded,
                              color: AppColors.outline),
                          onPressed: () =>
                              cubit.fetchFoodDetails(_ctrl.text.trim()),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            textAlign: TextAlign.end,
                            style: AppTextStyles.bodyMd,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v) =>
                                cubit.fetchFoodDetails(v.trim()),
                            decoration: InputDecoration(
                              hintText: 'أدخل اسم الطعام بالإنجليزية',
                              hintStyle: AppTextStyles.bodyMuted,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PpButton(
                    label: 'احصل على تفاصيل الطعام',
                    icon: Icons.restaurant_rounded,
                    onPressed: () => cubit.fetchFoodDetails(_ctrl.text.trim()),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── States ───────────────────────────────────────────────
                  if (cubit.isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2.5),
                    ))
                  else if (cubit.errorMessage.isNotEmpty)
                    _ErrorCard(message: cubit.errorMessage)
                  else if (cubit.calories > 0)
                    _NutritionResults(cubit: cubit)
                  else
                    const _EmptyState(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => PpCard(
        borderColor: AppColors.error.withOpacity(0.4),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Expanded(
                child: Text(message,
                    style:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.error),
                    textAlign: TextAlign.end)),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 22),
          ],
        ),
      );
}

class _NutritionResults extends StatelessWidget {
  const _NutritionResults({required this.cubit});
  final AppCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Food name
        if (cubit.label.isNotEmpty)
          PpCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(cubit.label, style: AppTextStyles.headingSmall),
                const SizedBox(width: AppSpacing.xs),
                Text('اسم الطعام:', style: AppTextStyles.labelMuted),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),

        // Calories gauge
        PpCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('السعرات الحرارية', style: AppTextStyles.labelMuted),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 200,
                child: SfRadialGauge(
                  backgroundColor: Colors.transparent,
                  axes: [
                    RadialAxis(
                      minimum: 0,
                      maximum: 600,
                      axisLineStyle: const AxisLineStyle(
                          color: Color(0x12FFFFFF), thickness: 10),
                      axisLabelStyle: GaugeTextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                      ranges: [
                        GaugeRange(
                            startValue: 0,
                            endValue: 100,
                            color: AppColors.success.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 100,
                            endValue: 300,
                            color: AppColors.warning.withOpacity(0.8)),
                        GaugeRange(
                            startValue: 300,
                            endValue: 600,
                            color: AppColors.error.withOpacity(0.8)),
                      ],
                      pointers: [
                        NeedlePointer(
                            value: cubit.calories,
                            needleColor: AppColors.primary,
                            enableAnimation: true)
                      ],
                      annotations: [
                        GaugeAnnotation(
                          widget: Text(
                            '${cubit.calories.toStringAsFixed(0)}\nكال',
                            style: AppTextStyles.headlineMd
                                .copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Data quality disclaimer if macro kcal >> displayed calories
        Builder(builder: (context) {
          final macroKcal = cubit.protein * 4 + cubit.carbs * 4 + cubit.fat * 9;
          final mismatch = macroKcal > 0 &&
              (macroKcal - cubit.calories).abs() > cubit.calories * 0.5;
          if (!mismatch) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.warning.withOpacity(0.25)),
              ),
              child: Text(
                'ملاحظة: قد تكون بيانات الماكروز تقريبية أو لحصة مختلفة.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                textAlign: TextAlign.end,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }),

        // Macros
        Row(
          children: [
            Expanded(
                child: _MacroCard(
                    label: 'بروتين',
                    value: cubit.protein,
                    color: AppColors.success,
                    kcalMultiplier: 4)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                child: _MacroCard(
                    label: 'كارب',
                    value: cubit.carbs,
                    color: AppColors.warning,
                    kcalMultiplier: 4)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                child: _MacroCard(
                    label: 'دهون',
                    value: cubit.fat,
                    color: AppColors.error,
                    kcalMultiplier: 9)),
          ],
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
    required this.kcalMultiplier,
  });
  final String label;
  final double value;
  final Color color;
  final double kcalMultiplier; // 4 for carbs/protein, 9 for fat

  @override
  Widget build(BuildContext context) {
    final kcal = (value * kcalMultiplier).round();
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '${value.toStringAsFixed(0)}g',
          style: AppTextStyles.headlineMd.copyWith(color: color, fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          '$kcal kcal',
          style: AppTextStyles.labelMuted.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelMuted),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.restaurant_menu_outlined,
              color: AppColors.outline, size: 38),
          const SizedBox(height: AppSpacing.xs),
          Text('ابحث عن طعام لعرض تفاصيله', style: AppTextStyles.bodyMuted),
        ]),
      );
}
