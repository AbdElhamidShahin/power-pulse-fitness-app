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

      final allWorkouts = await localService.getWorkoutLogs(limitDays: 3650);
      final streak = _calcStreak(allWorkouts);

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
        currentStreak:      streak,
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

  int _calcStreak(List<WorkoutLog> logs) {
    if (logs.isEmpty) return 0;
    final days = logs.map((l) {
      final d = l.date;
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int streak = 0;
    DateTime expected = today;

    for (final day in days) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isBefore(expected)) {
        break;
      }
    }
    return streak;
  }


  List<ChartPoint> _buildWeeklyPoints(List<WorkoutLog> logs, int days) {
    final now = DateTime.now();
    final points = <ChartPoint>[];

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
