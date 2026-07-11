import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_card.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../data/models/food_entity.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/meal_section.dart';

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
      body: SafeArea(
        child: BlocBuilder<NutritionCubit, NutritionState>(
          builder: (context, state) => switch (state) {
            NutritionInitial() || NutritionLoading() => const _LoadingView(),
            NutritionError(:final message) => _ErrorView(message: message),
            NutritionLoaded(:final daily) => _LoadedView(daily: daily),
          },
        ),
      ),
    );
  }
}

// ─── Loaded ─────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.daily});
  final DailyNutrition daily;

  // protein / carbs / fat goals — يمكن تخصيصها من ملف الشخصي لاحقاً
  static const double _proteinGoal = 150;
  static const double _carbsGoal = 250;
  static const double _fatGoal = 65;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── Header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConstants.screenPaddingH,
              UiConstants.spaceL,
              UiConstants.screenPaddingH,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.nutritionTitle,
                          style: Theme.of(context).textTheme.headlineLarge),
                      Text('اليوم', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Calorie Summary ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(UiConstants.screenPaddingH),
            child: PPCard(
              child: Column(
                children: [
                  // Ring + macros
                  Row(
                    children: [
                      CalorieRing(
                        consumed: daily.totalCalories,
                        goal: daily.calorieGoal,
                        size: 140,
                      ),
                      const SizedBox(width: UiConstants.spaceXL),
                      Expanded(
                        child: Column(
                          children: [
                            MacroBar(
                              label: AppStrings.protein,
                              value: daily.totalProtein,
                              unit: 'g',
                              color: AppColors.info,
                              progress: daily.totalProtein / _proteinGoal,
                            ),
                            const SizedBox(height: UiConstants.spaceM),
                            MacroBar(
                              label: AppStrings.carbs,
                              value: daily.totalCarbs,
                              unit: 'g',
                              color: AppColors.warning,
                              progress: daily.totalCarbs / _carbsGoal,
                            ),
                            const SizedBox(height: UiConstants.spaceM),
                            MacroBar(
                              label: AppStrings.fats,
                              value: daily.totalFat,
                              unit: 'g',
                              color: AppColors.danger,
                              progress: daily.totalFat / _fatGoal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Meal Sections ──────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.screenPaddingH,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...MealType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: UiConstants.spaceM),
                  child: MealSection(
                    mealType: type,
                    entries: daily.entriesFor(type),
                    onAddTap: () => context.push(
                      '/nutrition/search',
                      extra: type,
                    ),
                    onDeleteEntry: (id) =>
                        context.read<NutritionCubit>().deleteEntry(id),
                  ),
                ),
              ),
              const SizedBox(height: UiConstants.space3XL),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Loading ─────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: UiConstants.spaceM),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: UiConstants.spaceL),
          GestureDetector(
            onTap: () => context.read<NutritionCubit>().loadToday(),
            child: const Text(AppStrings.tryAgain,
                style: AppTextStyles.accentLabel),
          ),
        ],
      ),
    );
  }
}
