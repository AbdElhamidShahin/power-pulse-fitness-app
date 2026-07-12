import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/progress_entity.dart';
import '../services/progress_local_service.dart';

abstract interface class ProgressRepository {
  Future<ApiResult<ProgressSummary>> getSummary(ProgressPeriod period);
  Future<ApiResult<void>> addWeightEntry(WeightEntry entry);
  Future<ApiResult<void>> deleteWeightEntry(String id);
  Future<ApiResult<void>> logWorkout(WorkoutLog log);
}

final class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({required this.localService});

  final ProgressLocalService localService;

  @override
  Future<ApiResult<ProgressSummary>> getSummary(ProgressPeriod period) async {
    try {
      final days = period.days;
      final weights  = await localService.getWeightEntries(limitDays: days);
      final workouts = await localService.getWorkoutLogs(limitDays: days);

      final summary = ProgressSummary(
        totalWorkouts:      workouts.length,
        totalMinutes:       workouts.fold(0, (s, w) => s + w.durationMinutes),
        totalCaloriesBurned:workouts.fold(0, (s, w) => s + w.caloriesBurned),
        currentWeight:      weights.isNotEmpty ? weights.last.weight : null,
        startWeight:        weights.isNotEmpty ? weights.first.weight : null,
        weightEntries:      weights,
        workoutLogs:        workouts,
        weeklyWorkoutPoints:_buildWeeklyPoints(workouts, days),
        weightChartPoints:  _buildWeightPoints(weights),
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
