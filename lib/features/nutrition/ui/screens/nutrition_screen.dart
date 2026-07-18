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
import '../widgets/meal_card.dart';
import '../widgets/macro_bar_row.dart';
import '../widgets/water_card.dart';

// ════════════════════════════════════════════════════════════════
// NutritionScreen — تطابق بصري 100% مع التصميم
// Layout: Header → Calorie Card → Water Card → Meals List
// ════════════════════════════════════════════════════════════════
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
            NutritionInitial() || NutritionLoading() => const _LoadingView(),
            NutritionError(:final message)           => _ErrorView(message: message),
            NutritionLoaded(:final daily)            => _LoadedView(daily: daily),
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LoadedView — المحتوى الكامل
// ════════════════════════════════════════════════════════════════
class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.daily});
  final DailyNutrition daily;

  static const double _proteinGoal = 180;
  static const double _carbsGoal   = 250;
  static const double _fatGoal     = 65;
  static const double _waterGoal   = 2.5;
  static const double _waterCurrent = 1.8;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [

        // ── 1. Header ──────────────────────────────────────────
        SliverToBoxAdapter(child: _NutritionHeader()),

        // ── 2. Calorie Summary Card ────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: _CalorieSummaryCard(
              consumed:     daily.totalCalories,
              goal:         daily.calorieGoal,
              protein:      daily.totalProtein,
              proteinGoal:  _proteinGoal,
              carbs:        daily.totalCarbs,
              carbsGoal:    _carbsGoal,
              fat:          daily.totalFat,
              fatGoal:      _fatGoal,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceM)),

        // ── 3. Water Card ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: WaterCard(
              current: _waterCurrent,
              goal:    _waterGoal,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceM)),

        // ── 4. Meals Header ────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.push('/nutrition/search'),
                  child: const Text(
                    '+ Add',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const Text(
                  'MEALS',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceS)),

        // ── 5. Meal Cards ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // نقسم الـ entries على أنواع الوجبات
              ...MealType.values.map((type) {
                final entries = daily.entriesFor(type);
                final totalKcal = entries.fold<double>(
                    0, (s, e) => s + e.calories);
                final items = entries.map((e) => e.food.name).toList();
                final isDone = entries.isNotEmpty;

                return Padding(
                  padding:
                  const EdgeInsets.only(bottom: AppConstants.spaceM),
                  child: MealCard(
                    mealType:  type,
                    kcal:      totalKcal,
                    items:     items,
                    isDone:    isDone,
                    onTap: () => context.push(
                        '/nutrition/search', extra: type),
                  ),
                );
              }),
              const SizedBox(height: AppConstants.space4XL),
            ]),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Header — "TRACK YOUR DAY" + "Nutrition 🥗"
// ════════════════════════════════════════════════════════════════
class _NutritionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppConstants.screenPaddingH, AppConstants.spaceXXL,
          AppConstants.screenPaddingH, AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "TRACK YOUR DAY"
          const Text(
            'TRACK YOUR DAY',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          // "Nutrition 🥗"
          Row(
            children: const [
              Text(
                'Nutrition ',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text('🥗', style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Calorie Summary Card — حلقة + Goal/Remaining + ماكرو بارز
// ════════════════════════════════════════════════════════════════
class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({
    required this.consumed,
    required this.goal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fat,
    required this.fatGoal,
  });

  final double consumed, goal;
  final double protein, proteinGoal;
  final double carbs, carbsGoal;
  final double fat, fatGoal;

  double get _pct => goal > 0 ? (consumed / goal).clamp(0, 1) : 0;
  double get _remaining => (goal - consumed).clamp(0, goal);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ─── حلقة السعرات (يسار) ─────────────────────────
          NutritionCalorieRing(
            consumed: consumed,
            goal:     goal,
            size:     110,
          ),

          const SizedBox(width: AppConstants.spaceL),

          // ─── Goal / Remaining + Macros (يمين) ────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                // Goal line
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${goal.toInt()} kcal',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const TextSpan(
                        text: ' :Goal',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Remaining line
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${_remaining.toInt()} kcal',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent),
                      ),
                      const TextSpan(
                        text: ' :Remaining',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Protein
                MacroBarRow(
                  label:    'Protein',
                  current:  protein,
                  goal:     proteinGoal,
                  color:    AppColors.info,
                ),
                const SizedBox(height: 8),

                // Carbs
                MacroBarRow(
                  label:    'Carbs',
                  current:  carbs,
                  goal:     carbsGoal,
                  color:    AppColors.warning,
                ),
                const SizedBox(height: 8),

                // Fat
                MacroBarRow(
                  label:    'Fat',
                  current:  fat,
                  goal:     fatGoal,
                  color:    AppColors.danger,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Loading / Error
// ════════════════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 48),
            const SizedBox(height: AppConstants.spaceM),
            Text(message,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spaceXL),
            GestureDetector(
              onTap: () => context.read<NutritionCubit>().loadToday(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Text('حاول مجدداً',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
