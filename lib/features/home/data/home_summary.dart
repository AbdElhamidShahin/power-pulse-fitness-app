import '../../profile/data/models/user_profile_entity.dart';
import '../../nutrition/data/models/food_entity.dart';
import '../../progress/data/models/progress_entity.dart';

/// تلخيص بيانات الهوم — يُحسب في HomeCubit
final class HomeSummary {
  const HomeSummary({
    required this.profile,
    required this.dailyNutrition,
    required this.todayWorkouts,
    required this.weeklyWorkouts,
    this.currentStreak = 0,
  });

  final UserProfile profile;
  final DailyNutrition dailyNutrition;
  final List<WorkoutLog> todayWorkouts;
  final int weeklyWorkouts;
  final int currentStreak;

  // ─── Computed ───────────────────────────────────────────────
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  double get calorieProgress    => dailyNutrition.calorieProgress;
  double get caloriesConsumed   => dailyNutrition.totalCalories;
  double get caloriesGoal       => dailyNutrition.calorieGoal;
  double get caloriesRemaining  => dailyNutrition.caloriesLeft;
  bool   get hasWorkedOutToday  => todayWorkouts.isNotEmpty;
  int    get todayWorkoutMinutes =>
      todayWorkouts.fold(0, (s, w) => s + w.durationMinutes);
}
