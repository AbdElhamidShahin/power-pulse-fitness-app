import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: SafeArea(
          child: BlocConsumer<NutritionCubit, NutritionState>(
            listener: (context, state) {
              if (state is NutritionError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    margin: EdgeInsets.all(16.r),
                  ));
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    context.read<NutritionCubit>().loadToday();
                  }
                });
              }
            },
            builder: (context, state) => switch (state) {
              NutritionInitial() || NutritionLoading() => const _Loader(),
              NutritionError() => const _Loader(),
              NutritionLoaded(:final daily) => _Body(daily: daily),
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.daily});
  final DailyNutrition daily;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تتبع يومك',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8)),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text('التغذية',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary)),
                    SizedBox(width: 8.w),
                    Text('🥗', style: TextStyle(fontSize: 22.sp)),
                    const Spacer(),
                    // ─── زرار + لاختيار نوع الوجبة ───────
                    GestureDetector(
                      onTap: () => _showMealTypePicker(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.accent, size: 16.r),
                            SizedBox(width: 4.w),
                            Text('إضافة',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // ─── Date Navigator ───────────────────────
                _DateNavigator(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: _CalorieSummaryCard(daily: daily),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: const SliverToBoxAdapter(child: WaterCardConnected()),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
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
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showMealTypePicker(context),
                  child: Text('إضافة +',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...MealType.values.map(
                (type) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: MealCard(
                    mealType: type,
                    entries: daily.entriesFor(type),
                    onAddTap: () => _goSearch(context, type),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ]),
          ),
        ),
      ],
    );
  }

  void _goSearch(BuildContext context, MealType type) {
    context.push('/nutrition/search', extra: type);
  }

  void _showMealTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أضف لأي وجبة؟',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            SizedBox(height: 16.h),
            ...MealType.values.map((type) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _goSearch(context, type);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Text(_mealEmoji(type),
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(width: 12.w),
                        Text(type.labelAr,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14.r, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _mealEmoji(MealType type) => switch (type) {
        MealType.breakfast => '🌅',
        MealType.lunch => '☀️',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({required this.daily});
  final DailyNutrition daily;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
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
                            text: 'الهدف: ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: '\${daily.calorieGoal.toInt()} سعرة',
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
                            text: 'المتبقي: ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: '\${daily.caloriesLeft.toInt()} سعرة',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: daily.totalCalories > daily.calorieGoal
                                  ? AppColors.danger
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    MacroBarRow(
                      label: 'بروتين',
                      current: daily.totalProtein,
                      goal: daily.proteinGoal,
                      color: AppColors.info,
                    ),
                    SizedBox(height: 6.h),
                    MacroBarRow(
                      label: 'كارب',
                      current: daily.totalCarbs,
                      goal: daily.carbsGoal,
                      color: AppColors.warning,
                    ),
                    SizedBox(height: 6.h),
                    MacroBarRow(
                      label: 'دهون',
                      current: daily.totalFat,
                      goal: daily.fatGoal,
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              NutritionCalorieRing(
                consumed: daily.totalCalories,
                goal: daily.calorieGoal,
                size: 100.r,
              ),
            ],
          ),
        ),
        // ─── Calorie Over-Goal Feedback ─────────────────
        if (daily.totalCalories > daily.calorieGoal) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.dangerDim,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Text('⚠️', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تخطيت هدف السعرات بـ \${(daily.totalCalories - daily.calorieGoal).toInt()} سعرة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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

// ─── Date Navigator ──────────────────────────────────────────
class _DateNavigator extends StatelessWidget {
  const _DateNavigator();

  String _label(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'امبارح';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionCubit>();
    final date = cubit.selectedDate;
    final isToday = cubit.isToday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: cubit.goToPreviousDay,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          _label(date),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: isToday ? null : cubit.goToNextDay,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: isToday ? AppColors.bgDeep : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: isToday ? AppColors.borderMedium : AppColors.textMuted,
                size: 20),
          ),
        ),
      ],
    );
  }
}
