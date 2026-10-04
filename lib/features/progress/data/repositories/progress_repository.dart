import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../nutrition/data/services/nutrition_local_service.dart';
import '../../../pedometer/data/pedometer_service.dart';
import '../../../profile/data/services/profile_local_service.dart';
import '../../../workout_plan/data/services/workout_plan_service.dart';
import '../models/progress_entity.dart';
import '../services/progress_local_service.dart';

abstract interface class ProgressRepository {
  Future<ApiResult<ProgressSummary>> getSummary(ProgressPeriod period);
  Future<ApiResult<void>> addWeightEntry(WeightEntry entry);
  Future<ApiResult<void>> deleteWeightEntry(String id);
  Future<ApiResult<void>> logWorkout(WorkoutLog log);
}

final class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({
    required this.localService,
    this.nutritionService,
    this.pedometerService,
    this.profileService,
    this.planService,
  });

  final ProgressLocalService localService;

  // ─── مصادر باقي التطبيق (اختيارية) ──────────────────────
  final NutritionLocalService? nutritionService;
  final PedometerService? pedometerService;
  final ProfileLocalService? profileService;
  final WorkoutPlanService? planService;

  @override
  Future<ApiResult<ProgressSummary>> getSummary(ProgressPeriod period) async {
    try {
      final days = period.days;
      final weights  = await localService.getWeightEntries(limitDays: days);
      final workouts = await localService.getWorkoutLogs(limitDays: days);

      // نحسب الـ streak من كل السجلات (مش مقيدة بالفترة)
      final allWorkouts = await localService.getWorkoutLogs(limitDays: 3650);
      final streak = _calcStreak(allWorkouts);

      // ─── ربط بباقي التطبيق: ملف شخصي + خطوات + أكل + مياه + خطة ───
      final profile = await _safe(() => profileService?.getProfile());
      final plan = await _safe(() => planService?.getPlan());

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final activity = <DailyActivity>[];
      var stepsSum = 0, stepsDays = 0;
      var calSum = 0.0, calDays = 0;
      var waterSum = 0.0, waterDays = 0;

      for (int i = days - 1; i >= 0; i--) {
        final d = todayDate.subtract(Duration(days: i));
        final steps = pedometerService?.stepsForDay(d) ?? 0;
        final meals = await _safe(() => nutritionService?.getMealEntries(d));
        final cal = meals?.fold<double>(0, (s, e) => s + e.calories) ?? 0.0;
        final water =
            await _safe(() => nutritionService?.getWaterLiters(d)) ?? 0.0;
        final mins = allWorkouts
            .where((w) =>
                w.date.year == d.year &&
                w.date.month == d.month &&
                w.date.day == d.day)
            .fold<int>(0, (s, w) => s + w.durationMinutes);

        if (steps > 0) { stepsSum += steps; stepsDays++; }
        if (cal > 0) { calSum += cal; calDays++; }
        if (water > 0) { waterSum += water; waterDays++; }

        if (i < 7) {
          activity.add(DailyActivity(
            date: d,
            steps: steps,
            caloriesIn: cal,
            waterLiters: water,
            workoutMinutes: mins,
          ));
        }
      }

      // التزام بالخطة: آخر 7 أيام
      var planned = 0, done = 0;
      if (plan != null) {
        for (int i = 0; i < 7; i++) {
          final d = todayDate.subtract(Duration(days: i));
          if (plan.dayFor(d).hasExercises) {
            planned++;
            final did = allWorkouts.any((w) =>
                w.date.year == d.year &&
                w.date.month == d.month &&
                w.date.day == d.day);
            if (did) done++;
          }
        }
      }

      final profileWeight =
          (profile != null && profile.weightKg > 0) ? profile.weightKg : null;

      final summary = ProgressSummary(
        totalWorkouts:      workouts.length,
        totalMinutes:       workouts.fold(0, (s, w) => s + w.durationMinutes),
        totalCaloriesBurned:workouts.fold(0, (s, w) => s + w.caloriesBurned),
        currentWeight:      weights.isNotEmpty
            ? weights.last.weight
            : profileWeight,
        startWeight:        weights.isNotEmpty ? weights.first.weight : null,
        weightEntries:      weights,
        workoutLogs:        workouts,
        weeklyWorkoutPoints:_buildWeeklyPoints(workouts, days),
        weightChartPoints:  _buildWeightPoints(weights),
        currentStreak:      streak,
        dailyActivity:      activity,
        avgSteps:           stepsDays == 0 ? 0 : (stepsSum / stepsDays).round(),
        avgCaloriesIn:      calDays == 0 ? 0 : calSum / calDays,
        avgWaterLiters:     waterDays == 0 ? 0 : waterSum / waterDays,
        plannedDays:        planned,
        plannedDaysDone:    done,
        heightCm:           (profile != null && profile.heightCm > 0)
            ? profile.heightCm
            : null,
        calorieGoal:        profile?.dailyCalorieGoal,
      );

      return Success(summary);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> addWeightEntry(WeightEntry entry) async {
    try {
      await localService.addWeightEntry(entry);
      // الوزن الجديد يتحدّث في الملف الشخصي كمان (عشان الرئيسية وحساب السعرات)
      try {
        final p = await profileService?.getProfile();
        if (p != null) {
          await profileService!.saveProfile(p.copyWith(weightKg: entry.weight));
        }
      } catch (_) {}
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    }
  }

  @override
  Future<ApiResult<void>> deleteWeightEntry(String id) async {
    try {
      await localService.deleteWeightEntry(id);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    }
  }

  @override
  Future<ApiResult<void>> logWorkout(WorkoutLog log) async {
    try {
      await localService.logWorkout(log);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    }
  }

  /// قراءة مصدر خارجي من غير ما فشله يوقّع صفحة التقدم كلها
  Future<T?> _safe<T>(Future<T?>? Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  // ─── Streak Calculator ─────────────────────────────────────
  int _calcStreak(List<WorkoutLog> logs) {
    if (logs.isEmpty) return 0;
    final days = logs.map((l) {
      final d = l.date;
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()..sort((a, b) => b.compareTo(a)); // أحدث أول

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int streak = 0;
    DateTime expected = today;

    for (final day in days) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isBefore(expected)) {
        break; // انقطع الـ streak
      }
    }
    return streak;
  }

  // ─── Chart Builders ─────────────────────────────────────────
  /// تمارين لكل يوم خلال الفترة
  List<ChartPoint> _buildWeeklyPoints(List<WorkoutLog> logs, int days) {
    final now = DateTime.now();
    final points = <ChartPoint>[];

    // آخر 7 أيام أو كل أسبوع حسب الفترة
    final buckets = days <= 7 ? days : (days / 7).ceil();
    final bucketDays = days <= 7 ? 1 : 7;

    for (int i = 0; i < buckets; i++) {
      final start = now.subtract(Duration(days: days - (i * bucketDays)));
      final end   = start.add(Duration(days: bucketDays));
      final count = logs
          .where((l) => l.date.isAfter(start) && l.date.isBefore(end))
          .length;
      points.add(ChartPoint(x: i.toDouble(), y: count.toDouble()));
    }
    return points;
  }

  /// وزن على مدار الوقت
  List<ChartPoint> _buildWeightPoints(List<WeightEntry> entries) {
    return entries
        .asMap()
        .entries
        .map((e) => ChartPoint(
      x:     e.key.toDouble(),
      y:     e.value.weight,
      label: '${e.value.date.day}/${e.value.date.month}',
    ))
        .toList();
  }
}
