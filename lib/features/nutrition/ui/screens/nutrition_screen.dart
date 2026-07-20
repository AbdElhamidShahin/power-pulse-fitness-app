import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/food_entity.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/macro_bar_row.dart';
import '../widgets/meal_card.dart';
import '../widgets/water_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NutritionCubit>().loadToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: BlocBuilder<NutritionCubit, NutritionState>(
          builder: (context, state) => switch (state) {
            NutritionInitial() || NutritionLoading() => const _Loader(),
            NutritionError(:final message) => _ErrorView(message: message),
            NutritionLoaded(:final daily) => _Body(daily: daily),
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.daily});
  final DailyNutrition daily;

  static const double _proteinGoal = 180;
  static const double _carbsGoal = 250;
  static const double _fatGoal = 65;
  static const double _waterGoal = 2.5;
  static const double _waterNow = 1.8;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تتبع يومك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'التغذية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('🥗', style: TextStyle(fontSize: 24.sp)),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: _CalorieCard(
              consumed: daily.totalCalories,
              goal: daily.calorieGoal,
              protein: daily.totalProtein,
              proteinGoal: _proteinGoal,
              carbs: daily.totalCarbs,
              carbsGoal: _carbsGoal,
              fat: daily.totalFat,
              fatGoal: _fatGoal,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: const SliverToBoxAdapter(
            child: WaterCard(current: _waterNow, goal: _waterGoal),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الوجبات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/nutrition/search'),
                  child: Text(
                    'إضافة +',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...MealType.values.map((type) {
                final entries = daily.entriesFor(type);
                final totalKcal =
                entries.fold<double>(0, (s, e) => s + e.calories);
                final items = entries
                    .map((e) =>
                e.food.name.isNotEmpty ? e.food.name : e.food.name)
                    .toList();
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: MealCard(
                    mealType: type,
                    kcal: totalKcal,
                    items: items,
                    isDone: entries.isNotEmpty,
                    onTap: () => context.push('/nutrition/search', extra: type),
                  ),
                );
              }),
              SizedBox(height: 80.h),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.consumed,
    required this.goal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fat,
    required this.fatGoal,
  });

  final double consumed;
  final double goal;
  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbsGoal;
  final double fat;
  final double fatGoal;

  double get _remaining => (goal - consumed).clamp(0, goal);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                    children: [
                      const TextSpan(
                        text: 'الهدف : ',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      TextSpan(
                        text: '${goal.toInt()} سعرة',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                    children: [
                      const TextSpan(
                        text: 'المتبقي : ',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      TextSpan(
                        text: '${_remaining.toInt()} سعرة',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                MacroBarRow(
                  label: 'بروتين',
                  current: protein,
                  goal: proteinGoal,
                  color: AppColors.info,
                ),
                SizedBox(height: 8.h),
                MacroBarRow(
                  label: 'كارب',
                  current: carbs,
                  goal: carbsGoal,
                  color: AppColors.warning,
                ),
                SizedBox(height: 8.h),
                MacroBarRow(
                  label: 'دهون',
                  current: fat,
                  goal: fatGoal,
                  color: AppColors.danger,
                ),
              ],
            ),
          ),
          SizedBox(width: 22.w),
          NutritionCalorieRing(
            consumed: consumed,
            goal: goal,
            size: 110.r,
          ),
        ],
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accent),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: AppColors.danger,
          size: 48.r,
        ),
        SizedBox(height: 12.h),
        Text(
          message,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => context.read<NutritionCubit>().loadToday(),
          child: Text(
            'حاول مجدداً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    ),
  );
}