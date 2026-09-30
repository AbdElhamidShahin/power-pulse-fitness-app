import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../nutrition/data/models/food_entity.dart';
import '../../../nutrition/logic/usecases/nutrition_usecases.dart';
import '../../../profile/data/models/user_profile_entity.dart';
import '../../../profile/logic/usecases/profile_usecases.dart';
import '../../../progress/data/models/progress_entity.dart';
import '../../../progress/logic/usecases/progress_usecases.dart';
import '../../data/home_summary.dart';
import 'home_state.dart';

final class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetProfileUseCase getProfile,
    required GetDailyNutritionUseCase getDailyNutrition,
    required GetProgressSummaryUseCase getProgressSummary,
  })  : _getProfile = getProfile,
        _getDailyNutrition = getDailyNutrition,
        _getProgressSummary = getProgressSummary,
        super(const HomeInitial());

  final GetProfileUseCase _getProfile;
  final GetDailyNutritionUseCase _getDailyNutrition;
  final GetProgressSummaryUseCase _getProgressSummary;

  Future<void> load() async {
    emit(const HomeLoading());

    final profileResult = await _getProfile();
    if (profileResult.isFailure) {
      emit(HomeError(profileResult.failureOrNull!.userMessage));
      return;
    }
    final UserProfile profile = profileResult.dataOrNull!;

    final nutritionResult = await _getDailyNutrition(DateTime.now());
    final progressResult  = await _getProgressSummary(ProgressPeriod.week);

    final nutrition = nutritionResult.dataOrNull;
    final progress  = progressResult.dataOrNull;

    final today = DateTime.now();

    // ─── Today's workouts ──────────────────────────────────────
    final todayLogs = progress?.workoutLogs
            .where((l) =>
                l.date.year  == today.year  &&
                l.date.month == today.month &&
                l.date.day   == today.day)
            .toList() ??
        [];

    // مش محتاجين نحسبه هنا تاني
    final streak = progress?.currentStreak ?? 0;

    final dailyNutrition = nutrition ??
        DailyNutrition(
          date: today,
          entries: const [],
          calorieGoal: profile.dailyCalorieGoal,
        );

    emit(HomeLoaded(HomeSummary(
      profile: profile,
      dailyNutrition: dailyNutrition,
      todayWorkouts: todayLogs,
      weeklyWorkouts: progress?.totalWorkouts ?? 0,
      currentStreak: streak,
    )));
  }

  Future<void> refresh() => load();
}
