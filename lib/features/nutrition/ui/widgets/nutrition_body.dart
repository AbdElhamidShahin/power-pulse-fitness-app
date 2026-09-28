import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/food_entity.dart';
import 'calorie_summary_card.dart';
import 'meal_card.dart';
import 'meal_type_picker_sheet.dart';
import 'nutrition_date_navigator.dart';
import 'water_card.dart';

class NutritionBody extends StatelessWidget {
  const NutritionBody({super.key, required this.daily});

  final DailyNutrition daily;

  void _goSearch(BuildContext context, MealType type) {
    context.push('/nutrition/search', extra: type);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MealTypePickerSheet(
        onTypeSelected: (type) => _goSearch(context, type),
      ),
    );
  }

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
                Text(
                  'تتبع يومك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      'التغذية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('🥗', style: TextStyle(fontSize: 22.sp)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showPicker(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.accent, size: 16.r),
                            SizedBox(width: 4.w),
                            Text(
                              'إضافة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const NutritionDateNavigator(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: CalorieSummaryCard(daily: daily),
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
                  onTap: () => _showPicker(context),
                  child: Text(
                    'إضافة +',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
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
}