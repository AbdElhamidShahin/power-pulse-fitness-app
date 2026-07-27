import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_input.dart';
import '../../data/models/food_entity.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';
import '../widgets/food_search_card.dart';

// ════════════════════════════════════════════════════════════════
// FoodSearchScreen
// ════════════════════════════════════════════════════════════════
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required this.mealType});
  final MealType mealType;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _controller = TextEditingController();
  final _scroll     = ScrollController();

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
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH, AppConstants.spaceL,
                AppConstants.screenPaddingH, AppConstants.spaceM,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textPrimary,
                        size: AppConstants.iconS,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('إضافة وجبة',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(widget.mealType.labelAr,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.accent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search Bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH),
              child: PPSearchBar(
                hint: 'ابحث عن طعام...',
                controller: _controller,
                onChanged: (q) => context.read<FoodSearchCubit>().search(q),
                autofocus: true,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // ─── النتائج ────────────────────────────────────
            Expanded(
              child: BlocBuilder<FoodSearchCubit, FoodSearchState>(
                builder: (context, state) => switch (state) {
                  FoodSearchIdle()    => const _IdleView(),
                  FoodSearchLoading() => const _SearchLoadingView(),
                  FoodSearchError(:final message) =>
                      _SearchErrorView(message: message, controller: _controller),
                  FoodSearchLoaded(:final results) when results.isEmpty =>
                  const _EmptyView(),
                  FoodSearchLoaded(:final results, :final hasMore) =>
                      _ResultsList(
                        results:  results,
                        hasMore:  hasMore,
                        scroll:   _scroll,
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

// ════════════════════════════════════════════════════════════════
// Results List
// ════════════════════════════════════════════════════════════════
class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.hasMore,
    required this.scroll,
    required this.mealType,
  });

  final List<FoodItem>    results;
  final bool              hasMore;
  final ScrollController  scroll;
  final MealType          mealType;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scroll,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH),
      itemCount: results.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) =>
      const SizedBox(height: AppConstants.spaceM),
      itemBuilder: (context, i) {
        if (i == results.length) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.spaceXL),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }
        return FoodSearchCard(
          food:  results[i],
          onTap: () => _showAddSheet(context, results[i]),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AddMealCubit>(),
        child: _AddMealSheet(
          food:           food,
          mealType:       mealType,
          nutritionCubit: context.read<NutritionCubit>(),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Add Meal Bottom Sheet
// ════════════════════════════════════════════════════════════════
class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({
    required this.food,
    required this.mealType,
    required this.nutritionCubit,
  });
  final FoodItem       food;
  final MealType       mealType;
  final NutritionCubit nutritionCubit;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  double _quantity = 100.0;
  final _qtyCtrl   = TextEditingController(text: '100');

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  // ─── Calculated macros ────────────────────────────────────
  double get _calories =>
      widget.food.calories * _quantity / widget.food.servingSize;
  double get _protein  =>
      widget.food.protein  * _quantity / widget.food.servingSize;
  double get _carbs    =>
      widget.food.carbs    * _quantity / widget.food.servingSize;
  double get _fat      =>
      widget.food.fat      * _quantity / widget.food.servingSize;

  void _adjustQty(double delta) {
    // ✅ Fix: explicit toDouble() بعد clamp
    final next = (_quantity + delta).clamp(1.0, 9999.0).toDouble();
    setState(() {
      _quantity = next;
      _qtyCtrl.text = next.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddMealCubit, AddMealState>(
      listener: (context, state) {
        if (state is AddMealSuccess) {
          widget.nutritionCubit.loadToday();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                'تمت إضافة ${widget.food.displayName} للـ${widget.mealType.labelAr}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ));
          Navigator.of(context)
            ..pop()
            ..pop();
          context.read<AddMealCubit>().reset();
        }
        if (state is AddMealError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ));
          context.read<AddMealCubit>().reset();
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.screenPaddingH,
          AppConstants.spaceXL,
          AppConstants.screenPaddingH,
          MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ─── Handle ───────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // ─── اسم الطعام ───────────────────────────────
            Text(
              widget.food.displayName,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.food.brand != null) ...[
              const SizedBox(height: 2),
              Text(widget.food.brand!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodySmall),
            ],
            const SizedBox(height: AppConstants.spaceL),

            // ─── معاينة المكرو ────────────────────────────
            _MacroPreview(
              calories: _calories,
              protein:  _protein,
              carbs:    _carbs,
              fat:      _fat,
            ),
            const SizedBox(height: AppConstants.spaceL),

            // ─── حقل الكمية + أزرار +/- ───────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge,
                    onChanged: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null && parsed > 0) {
                        setState(() => _quantity = parsed);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'الكمية',
                      labelStyle:
                      const TextStyle(fontFamily: 'Cairo'),
                      suffixText: widget.food.servingUnit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceL),
                Column(
                  children: [
                    _QtyBtn(
                      icon:  Icons.add_rounded,
                      onTap: () => _adjustQty(25),
                    ),
                    const SizedBox(height: 6),
                    _QtyBtn(
                      icon:  Icons.remove_rounded,
                      onTap: () => _adjustQty(-25),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceXXL),

            // ─── زر الإضافة ───────────────────────────────
            BlocBuilder<AddMealCubit, AddMealState>(
              builder: (context, state) {
                final loading = state is AddMealLoading;
                return SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () => context.read<AddMealCubit>().addMeal(
                      food:     widget.food,
                      mealType: widget.mealType,
                      quantity: _quantity,
                    ),
                    child: loading
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnAccent,
                      ),
                    )
                        : const Text('إضافة للوجبة',
                        style: TextStyle(fontFamily: 'Cairo')),
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

// ─── Macro Preview ────────────────────────────────────────────
class _MacroPreview extends StatelessWidget {
  const _MacroPreview({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final double calories, protein, carbs, fat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MItem(label: 'سعرة',   value: calories, color: AppColors.accent),
          _MItem(label: 'بروتين', value: protein,  color: AppColors.info),
          _MItem(label: 'كارب',   value: carbs,    color: AppColors.warning),
          _MItem(label: 'دهون',   value: fat,      color: AppColors.danger),
        ],
      ),
    );
  }
}

class _MItem extends StatelessWidget {
  const _MItem({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toInt()}',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16,
              fontWeight: FontWeight.w800, color: color,
            )),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 10,
              color: AppColors.textMuted,
            )),
      ],
    );
  }
}

// ─── Qty Button ───────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});
  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─── Empty States ─────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  const _IdleView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.search_rounded,
          color: AppColors.textMuted, size: 48),
      const SizedBox(height: AppConstants.spaceM),
      Text('ابحث عن طعام لإضافته',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textMuted)),
    ]),
  );
}

class _SearchLoadingView extends StatelessWidget {
  const _SearchLoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.no_food_rounded,
          color: AppColors.textMuted, size: 48),
      const SizedBox(height: AppConstants.spaceM),
      Text('لا توجد نتائج',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textMuted)),
    ]),
  );
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({
    required this.message,
    required this.controller,
  });
  final String             message;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded,
            color: AppColors.textMuted, size: 48),
        const SizedBox(height: AppConstants.spaceM),
        Text(message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: AppConstants.spaceL),
        GestureDetector(
          onTap: () =>
              context.read<FoodSearchCubit>().search(controller.text),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Text('حاول مجدداً',
                style: TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
          ),
        ),
      ]),
    ),
  );
}