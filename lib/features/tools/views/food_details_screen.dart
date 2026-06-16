import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../core/network/food_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../data/repo/tools_repositories.dart';
import '../data/service/food_data_service.dart';
import '../logic/cubit/tools_cubits.dart';
import '../logic/cubit/tools_states.dart';

class FoodDetailsScreen extends StatelessWidget {
  const FoodDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCubit(
        FoodRepositoryImpl(
          FoodDataService(GetIt.instance<FoodService>()),
        ),
      ),
      child: const _FoodBody(),
    );
  }
}

class _FoodBody extends StatefulWidget {
  const _FoodBody();
  @override
  State<_FoodBody> createState() => _FoodBodyState();
}

class _FoodBodyState extends State<_FoodBody> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Food Nutrition Details', style: AppTextStyles.labelMuted),
            const SizedBox(height: AppSpacing.md),

            // ── Search field ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  BlocBuilder<FoodCubit, FoodState>(
                    builder: (context, state) => IconButton(
                      icon: state is FoodLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2))
                          : const Icon(Icons.search_rounded,
                              color: AppColors.outline),
                      onPressed: () =>
                          context.read<FoodCubit>().search(_ctrl.text),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.bodyMd,
                      textDirection: TextDirection.ltr,
                      onSubmitted: (v) => context.read<FoodCubit>().search(v),
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
              onPressed: () => context.read<FoodCubit>().search(_ctrl.text),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── State output ───────────────────────────────────────────
            BlocBuilder<FoodCubit, FoodState>(
              builder: (_, state) => switch (state) {
                FoodInitial() => _FoodEmpty(),
                FoodLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2.5),
                    ),
                  ),
                FoodError(:final message) => _FoodErrorCard(message),
                FoodLoaded(:final nutrition) => _FoodResults(nutrition),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── States UI ─────────────────────────────────────────────────────────────────

class _FoodEmpty extends StatelessWidget {
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

class _FoodErrorCard extends StatelessWidget {
  const _FoodErrorCard(this.message);
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

class _FoodResults extends StatelessWidget {
  const _FoodResults(this.n);
  final nutrition = null;
  final dynamic n;

  @override
  Widget build(BuildContext context) {
    final nutr = n as FoodNutrition;
    final macroKcal = nutr.protein * 4 + nutr.carbs * 4 + nutr.fat * 9;
    final mismatch = macroKcal > 0 &&
        (macroKcal - nutr.calories).abs() > nutr.calories * 0.5;

    return Column(
      children: [
        if (nutr.label.isNotEmpty)
          PpCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(nutr.label, style: AppTextStyles.headingSmall),
              const SizedBox(width: AppSpacing.xs),
              Text('اسم الطعام:', style: AppTextStyles.labelMuted),
            ]),
          ),
        const SizedBox(height: AppSpacing.sm),
        PpCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
                          value: nutr.calories.clamp(0, 600),
                          needleColor: AppColors.primary,
                          enableAnimation: true)
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Text('${nutr.calories.toStringAsFixed(0)}\nكال',
                            style: AppTextStyles.headlineMd
                                .copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center),
                        angle: 90,
                        positionFactor: 0.5,
                      )
                    ],
                  )
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (mismatch)
          Padding(
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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.warning),
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.rtl),
            ),
          ),
        Row(children: [
          Expanded(
              child: _MacroCard(
                  label: 'بروتين',
                  value: nutr.protein,
                  color: AppColors.success,
                  kcalMult: 4)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: _MacroCard(
                  label: 'كارب',
                  value: nutr.carbs,
                  color: AppColors.warning,
                  kcalMult: 4)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: _MacroCard(
                  label: 'دهون',
                  value: nutr.fat,
                  color: AppColors.error,
                  kcalMult: 9)),
        ]),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.kcalMult});
  final String label;
  final double value, kcalMult;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final kcal = (value * kcalMult).round();
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${value.toStringAsFixed(0)}g',
            style:
                AppTextStyles.headlineMd.copyWith(color: color, fontSize: 20)),
        const SizedBox(height: 2),
        Text('$kcal kcal',
            style: AppTextStyles.labelMuted.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelMuted),
      ]),
    );
  }
}
