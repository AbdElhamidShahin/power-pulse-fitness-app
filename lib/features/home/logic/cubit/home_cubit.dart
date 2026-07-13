import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../nutrition/data/models/food_entity.dart';
import '../../../nutrition/logic/usecases/nutrition_usecases.dart';
import '../../../profile/logic/usecases/profile_usecases.dart';
import '../../../profile/data/models/user_profile_entity.dart';
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
      emit(HomeError(_map(profileResult.failureOrNull!)));
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
    l.date.year  == today.year &&
        l.date.month == today.month &&
        l.date.day   == today.day)
        .toList() ?? [];

    // ─── Streak حساب ───────────────────────────────────────────
    final streak = _calcStreak(progress?.workoutLogs ?? []);

    // ─── Daily Nutrition default ───────────────────────────────
    final dailyNutrition = nutrition ??
        DailyNutrition(
          date:        today,
          entries:     const [],
          calorieGoal: profile.dailyCalorieGoal,
        );

    emit(HomeLoaded(HomeSummary(
      profile:        profile,
      dailyNutrition: dailyNutrition,
      todayWorkouts:  todayLogs,
      weeklyWorkouts: progress?.totalWorkouts ?? 0,
      currentStreak:  streak,
    )));
  }

  Future<void> refresh() => load();

  // ─── Streak حسابها من الـ logs ─────────────────────────────
  int _calcStreak(List<WorkoutLog> logs) {
    if (logs.isEmpty) return 0;

    // نجمع الأيام الفريدة اللي اتمرن فيها
    final workedDays = logs
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // الأحدث أول

    if (workedDays.isEmpty) return 0;

    final today    = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // لو مش اتمرن امبارح ولا النهارده — streak = 0
    if (workedDays.first != todayDate && workedDays.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < workedDays.length; i++) {
      final diff = workedDays[i - 1].difference(workedDays[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _map(AppFailure f) => switch (f) {
    NetworkFailure()    => 'لا يوجد اتصال بالإنترنت',
    CacheFailure()      => 'خطأ في قراءة البيانات المحلية',
    UnexpectedFailure() => 'حدث خطأ غير متوقع',
    _                   => 'حدث خطأ، حاول مجدداً',
  };
}
