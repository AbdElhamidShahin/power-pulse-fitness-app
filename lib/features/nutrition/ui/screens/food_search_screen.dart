import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../shared/widgets/pp_input.dart';
import '../../data/models/food_entity.dart';
import '../../data/services/arabic_food_database.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';
import '../widgets/food_search_card.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required this.mealType});
  final MealType mealType;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _controller = TextEditingController();
  final _scroll     = ScrollController();

  static final _popularFoods = ArabicFoodDatabase.all
      .where((f) => [
    'ar_001', 'ar_002', 'ar_003', 'ar_009', 'ar_010',
    'ar_011', 'mt_001', 'dy_001', 'gr_001', 'cn_001',
  ].contains(f.id))
      .toList();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<FoodSearchCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _Header(mealType: widget.mealType),
            // ─── Search Bar ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH.w,
                vertical: AppConstants.spaceS.h,
              ),
              // FIX 1: PPInput → PPSearchBar
              child: PPSearchBar(
                controller: _controller,
                hint: 'ابحث عن طعام... (مثلاً: كشري، تونة، فول)',
                onChanged: (q) {
                  setState(() {});
                  if (q.trim().length >= 2) {
                    context.read<FoodSearchCubit>().search(q.trim());
                  } else if (q.isEmpty) {
                    context.read<FoodSearchCubit>().clear();
                  }
                },
              ),
            ),

            // ─── Body ────────────────────────────────────────
            Expanded(
              child: BlocBuilder<FoodSearchCubit, FoodSearchState>(
                builder: (context, state) {
                  if (state is FoodSearchIdle) {
                    return _SuggestionsView(
                      foods: _popularFoods,
                      mealType: widget.mealType,
                    );
                  }
                  if (state is FoodSearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }
                  if (state is FoodSearchError) {
                    return _ErrorView(message: state.message);
                  }
                  if (state is FoodSearchLoaded) {
                    if (state.results.isEmpty) {
                      return _EmptyView(query: state.query);
                    }
                    return _ResultsList(
                      results: state.results,
                      hasMore: state.hasMore,
                      mealType: widget.mealType,
                      scroll: _scroll,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.mealType});
  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH.w,
        AppConstants.spaceL.h,
        AppConstants.screenPaddingH.w,
        AppConstants.spaceS.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة وجبة',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: context.colors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(mealType.icon, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      mealType.labelAr,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: context.colors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Icon(
                Icons.close_rounded,
                color: context.colors.textSecondary,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestions View ─────────────────────────────────────────────────────────
class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView({required this.foods, required this.mealType});
  final List<FoodItem> foods;
  final MealType mealType;

  static const _categories = [
    ('🥘', 'أكلات مصرية'),
    ('🥫', 'معلبات'),
    ('🍗', 'بروتين'),
    ('🥗', 'خضروات'),
    ('🍚', 'حبوب'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH.w),
      children: [
        SizedBox(height: AppConstants.spaceM.h),
        Text(
          'تصفح حسب الفئة',
          style: AppTextStyles.labelSmall.copyWith(
            color: context.colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: AppConstants.spaceS.h),
        SizedBox(
          height: 44.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return _CategoryChip(emoji: cat.$1, label: cat.$2);
            },
          ),
        ),
        SizedBox(height: AppConstants.spaceL.h),
        Text(
          'الأكثر شيوعاً',
          style: AppTextStyles.labelSmall.copyWith(
            color: context.colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: AppConstants.spaceS.h),
        ...foods.map((f) => Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spaceS.h),
          child: FoodSearchCard(
            item: f,
            onAdd: () => _showAddDialog(context, f, mealType),
          ),
        )),
        SizedBox(height: 80.h),
      ],
    );
  }
}

// ─── Results List ─────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.hasMore,
    required this.mealType,
    required this.scroll,
  });
  final List<FoodItem> results;
  final bool hasMore;
  final MealType mealType;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH.w,
            vertical: AppConstants.spaceXS.h,
          ),
          child: Text(
            '${results.length} نتيجة',
            style: AppTextStyles.labelSmall
                .copyWith(color: context.colors.textMuted),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scroll,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH.w,
              vertical: AppConstants.spaceS.h,
            ),
            itemCount: results.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                SizedBox(height: AppConstants.spaceS.h),
            itemBuilder: (context, i) {
              if (i >= results.length) {
                return Padding(
                  padding: EdgeInsets.all(AppConstants.spaceL.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final item = results[i];
              return FoodSearchCard(
                item: item,
                onAdd: () => _showAddDialog(context, item, mealType),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill.r),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.space3XL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔍', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: AppConstants.spaceL.h),
            Text(
              'مش لاقي "$query"',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge
                  .copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppConstants.spaceS.h),
            Text(
              'جرّب كلمة تانية أو ابحث بالإنجليزي',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.space3XL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48.r, color: context.colors.textMuted),
            SizedBox(height: AppConstants.spaceL.h),
            Text(
              'خطأ في الاتصال',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppConstants.spaceS.h),
            Text(
              'بيعرض الأطعمة المحلية فقط',
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Food Dialog ──────────────────────────────────────────────────────────
void _showAddDialog(
    BuildContext context,
    FoodItem item,
    MealType mealType,
    ) {
  double quantity = item.servingSize;
  final controller = TextEditingController(
    text: item.servingSize.toInt().toString(),
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.bgSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXXL.r),
      ),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final cal  = item.calories * quantity / item.servingSize;
          final prot = item.protein  * quantity / item.servingSize;
          final carb = item.carbs    * quantity / item.servingSize;
          final fat  = item.fat      * quantity / item.servingSize;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20.w, 20.h, 20.w,
              MediaQuery.of(ctx).viewInsets.bottom + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40.w, height: 4.h,
                    decoration: BoxDecoration(
                      color: context.colors.borderSubtle,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Food Name
                Text(
                  item.displayName,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: context.colors.textPrimary),
                ),
                if (item.brand != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    item.brand!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: context.colors.textMuted),
                  ),
                ],
                SizedBox(height: 16.h),

                // Macros Row
                Row(
                  children: [
                    _MacroBadge(
                        label: 'سعرات',
                        value: cal.round().toString(),
                        color: AppColors.warning),
                    SizedBox(width: 8.w),
                    _MacroBadge(
                        label: 'بروتين',
                        value: '${prot.toStringAsFixed(1)}جم',
                        color: AppColors.info),
                    SizedBox(width: 8.w),
                    _MacroBadge(
                        label: 'كارب',
                        value: '${carb.toStringAsFixed(1)}جم',
                        color: AppColors.accent),
                    SizedBox(width: 8.w),
                    _MacroBadge(
                        label: 'دهون',
                        value: '${fat.toStringAsFixed(1)}جم',
                        color: AppColors.danger),
                  ],
                ),
                SizedBox(height: 16.h),

                // Quantity Input
                Row(
                  children: [
                    Text(
                      'الكمية (${item.servingUnit}):',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: context.colors.textSecondary),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 80.w,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 8.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusS.r),
                            borderSide: BorderSide(
                                color: context.colors.borderSubtle),
                          ),
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            setModalState(() => quantity = parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textOnAccent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(AppConstants.radiusM.r),
                      ),
                    ),
                    onPressed: () {
                      // FIX 2: addMeal(entry) → addMeal(food:, mealType:, quantity:)
                      context.read<AddMealCubit>().addMeal(
                        food:     item,
                        mealType: mealType,
                        quantity: quantity,
                      );
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'إضافة ${mealType.icon} ${mealType.labelAr}',
                      style: AppTextStyles.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusS.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9.sp,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
