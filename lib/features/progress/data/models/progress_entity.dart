
final class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.note,
  });

  final String id;
  final double weight;
  final DateTime date;
  final String? note;
}

final class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.exerciseCount = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final double caloriesBurned;
  final int exerciseCount;
}

final class ChartPoint {
  const ChartPoint({required this.x, required this.y, this.label});
  final double x;
  final double y;
  final String? label;
}

final class ProgressSummary {
  const ProgressSummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCaloriesBurned,
    required this.currentWeight,
    required this.startWeight,
    required this.weightEntries,
    required this.workoutLogs,
    required this.weeklyWorkoutPoints,
    required this.weightChartPoints,
    this.currentStreak = 0,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final double totalCaloriesBurned;
  final double? currentWeight;
  final double? startWeight;
  final List<WeightEntry> weightEntries;
  final List<WorkoutLog> workoutLogs;
  final List<ChartPoint> weeklyWorkoutPoints;
  final List<ChartPoint> weightChartPoints;
  final int currentStreak;

  double? get bmi {
    if (currentWeight == null) return null;
    const heightInMeters = 1.78;
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  double? get weightChange => (currentWeight != null && startWeight != null)
      ? currentWeight! - startWeight!
      : null;

  bool get isWeightLoss => (weightChange ?? 0) < 0;

  String get totalMinutesFormatted {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h > 0 ? '${h}س ${m}د' : '${m}د';
  }
}

enum ProgressPeriod { week, month, threeMonths }

extension ProgressPeriodX on ProgressPeriod {
  String get labelAr => switch (this) {
        ProgressPeriod.week => 'أسبوع',
        ProgressPeriod.month => 'شهر',
        ProgressPeriod.threeMonths => '3 أشهر',
      };

  int get days => switch (this) {
        ProgressPeriod.week => 7,
        ProgressPeriod.month => 30,
        ProgressPeriod.threeMonths => 90,
      };
}
