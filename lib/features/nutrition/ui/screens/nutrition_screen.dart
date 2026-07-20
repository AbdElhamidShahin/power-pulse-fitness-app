import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
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
            NutritionError(:final message)           => _ErrorView(message: message),
            NutritionLoaded(:final daily)            => _Body(daily: daily),
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
  static const double _carbsGoal   = 250;
  static const double _fatGoal     = 65;
  static const double _waterGoal   = 2.5;
  static const double _waterNow    = 1.8;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [

        // ─── Header ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'تتبع يومك',
                  style: TextStyle(fontFamily:'Cairo', fontSize:11,
                      color:AppColors.textMuted, letterSpacing:0.8),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('التغذية',
                        style: TextStyle(fontFamily:'Cairo', fontSize:26,
                            fontWeight:FontWeight.w900, color:AppColors.textPrimary)),
                    SizedBox(width: 8),
                    Text('🥗', style: TextStyle(fontSize:24)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ─── Calorie Card ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _CalorieCard(
              consumed:    daily.totalCalories,
              goal:        daily.calorieGoal,
              protein:     daily.totalProtein,  proteinGoal: _proteinGoal,
              carbs:       daily.totalCarbs,    carbsGoal:   _carbsGoal,
              fat:         daily.totalFat,      fatGoal:     _fatGoal,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // ─── Water Card ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: WaterCard(current: _waterNow, goal: _waterGoal),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // ─── Meals Header ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.push('/nutrition/search'),
                  child: const Text('إضافة +',
                      style: TextStyle(fontFamily:'Cairo', fontSize:13,
                          fontWeight:FontWeight.w700, color:AppColors.accent)),
                ),
                const Text('الوجبات',
                    style: TextStyle(fontFamily:'Cairo', fontSize:11,
                        fontWeight:FontWeight.w700, color:AppColors.textMuted)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ─── Meal Cards ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...MealType.values.map((type) {
                final entries = daily.entriesFor(type);
                final totalKcal = entries.fold<double>(0, (s, e) => s + e.calories);
                final items = entries.map((e) => e.food.name.isNotEmpty
                    ? e.food.name : e.food.name).toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MealCard(
                    mealType: type,
                    kcal: totalKcal,
                    items: items,
                    isDone: entries.isNotEmpty,
                    onTap: () => context.push('/nutrition/search', extra: type),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Calorie Card
// ════════════════════════════════════════════════════════════════
class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.consumed, required this.goal,
    required this.protein,  required this.proteinGoal,
    required this.carbs,    required this.carbsGoal,
    required this.fat,      required this.fatGoal,
  });
  final double consumed, goal, protein, proteinGoal, carbs, carbsGoal, fat, fatGoal;

  double get _pct      => goal > 0 ? (consumed / goal).clamp(0, 1) : 0;
  double get _remaining => (goal - consumed).clamp(0, goal);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── حلقة يسار ───────────────────────────────────
          NutritionCalorieRing(consumed: consumed, goal: goal, size: 110),
          const SizedBox(width: 18),

          // ─── معلومات + ماكرو يمين ────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // الهدف
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(style: const TextStyle(fontFamily:'Cairo', fontSize:12), children: [
                    TextSpan(text: '${goal.toInt()} سعرة',
                        style: const TextStyle(fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
                    const TextSpan(text: ' :الهدف', style: TextStyle(color:AppColors.textMuted)),
                  ]),
                ),
                const SizedBox(height: 2),
                // المتبقي
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(style: const TextStyle(fontFamily:'Cairo', fontSize:12), children: [
                    TextSpan(text: '${_remaining.toInt()} سعرة',
                        style: const TextStyle(fontWeight:FontWeight.w700, color:AppColors.accent)),
                    const TextSpan(text: ' :المتبقي', style: TextStyle(color:AppColors.textMuted)),
                  ]),
                ),
                const SizedBox(height: 14),
                MacroBarRow(label:'بروتين', current:protein, goal:proteinGoal, color:AppColors.info),
                const SizedBox(height: 8),
                MacroBarRow(label:'كارب',   current:carbs,   goal:carbsGoal,   color:AppColors.warning),
                const SizedBox(height: 8),
                MacroBarRow(label:'دهون',   current:fat,     goal:fatGoal,     color:AppColors.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
      const SizedBox(height: 12),
      Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => context.read<NutritionCubit>().loadToday(),
        child: const Text('حاول مجدداً',
            style: TextStyle(fontFamily:'Cairo', fontWeight:FontWeight.w700,
                color:AppColors.accent)),
      ),
    ]),
  );
}
