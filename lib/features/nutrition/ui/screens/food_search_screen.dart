import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_input.dart';
import '../../data/models/food_entity.dart';
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
  final _scroll = ScrollController();

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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200.h) {
      context.read<FoodSearchCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH.w,
                AppConstants.spaceL.h,
                AppConstants.screenPaddingH.w,
                AppConstants.spaceM.h,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: AppConstants.iconS.r,
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إضافة وجبة',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.mealType.labelAr,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH.w,
              ),
              child: PPSearchBar(
                hint: 'ابحث عن طعام...',
                controller: _controller,
                onChanged: (q) => context.read<FoodSearchCubit>().search(q),
                autofocus: true,
              ),
            ),
            SizedBox(height: AppConstants.spaceL.h),
            Expanded(
              child: BlocBuilder<FoodSearchCubit, FoodSearchState>(
                builder: (context, state) => switch (state) {
                  FoodSearchIdle() => const _IdleView(),
                  FoodSearchLoading() => const _LoadingView(),
                  FoodSearchError(:final message) =>
                    _ErrorView(message: message),
                  FoodSearchLoaded(:final results) when results.isEmpty =>
                    const _EmptyView(),
                  FoodSearchLoaded(:final results, :final hasMore) =>
                    _ResultsList(
                      results: results,
                      hasMore: hasMore,
                      scroll: _scroll,
                      mealType: widget.mealType,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.hasMore,
    required this.scroll,
    required this.mealType,
  });

  final List<FoodItem> results;
  final bool hasMore;
  final ScrollController scroll;
  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scroll,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.screenPaddingH.w,
      ),
      itemCount: results.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: AppConstants.spaceM.h),
      itemBuilder: (context, i) {
        if (i == results.length) {
          return Padding(
            padding: EdgeInsets.all(AppConstants.spaceXL.r),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        return FoodSearchCard(
          food: results[i],
          onTap: () => _showAddSheet(context, results[i]),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL.r),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AddMealCubit>(),
        child: _AddMealSheet(food: food, mealType: mealType),
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({required this.food, required this.mealType});
  final FoodItem food;
  final MealType mealType;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  double _quantity = 100;
  final _qtyController = TextEditingController(text: '100');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  double get _calories =>
      widget.food.calories * _quantity / widget.food.servingSize;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddMealCubit, AddMealState>(
      listener: (context, state) {
        if (state is AddMealSuccess) {
          context.read<NutritionCubit>().loadToday();
          Navigator.of(context)
            ..pop()
            ..pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.screenPaddingH.w,
          AppConstants.spaceXL.h,
          AppConstants.screenPaddingH.w,
          MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceXL.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.food.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.food.brand != null)
              Text(widget.food.brand!, style: AppTextStyles.bodySmall),
            SizedBox(height: AppConstants.spaceXXL.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.titleLarge,
                    onChanged: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null && parsed > 0) {
                        setState(() => _quantity = parsed);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      suffixText: 'g',
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spaceL.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_calories.toInt()}',
                      style: AppTextStyles.statNumber
                          .copyWith(color: AppColors.accent),
                    ),
                    Text('سعرة حرارية', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceXXL.h),
            BlocBuilder<AddMealCubit, AddMealState>(
              builder: (context, state) {
                final isLoading = state is AddMealLoading;
                return SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeightLarge.h,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AddMealCubit>().addMeal(
                              food: widget.food,
                              mealType: widget.mealType,
                              quantity: _quantity,
                            ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnAccent,
                            ),
                          )
                        : const Text('إضافة للوجبة'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 48.r,
            ),
            SizedBox(height: AppConstants.spaceM.h),
            Text(
              'ابحث عن طعام لإضافته',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_food_rounded,
              color: AppColors.textMuted,
              size: 48.r,
            ),
            SizedBox(height: AppConstants.spaceM.h),
            Text(
              'لا توجد نتائج',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(message, style: AppTextStyles.bodyMedium),
      );
}
