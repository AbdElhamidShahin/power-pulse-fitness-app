/// Progress Entities — Domain Layer
/// Pure Dart — Zero Flutter imports

/// تسجيل وزن يومي
final class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.note,
  });

  final String id;
  final double weight; // kg
  final DateTime date;
  final String? note;
}

/// تمرين مكتمل
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

/// نقطة بيانات للرسم البياني
final class ChartPoint {
  const ChartPoint({required this.x, required this.y, this.label});
  final double x;
  final double y;
  final String? label;
}

/// نشاط يوم واحد — بيجمع الخطوات + الأكل + المياه + التمرين
/// (البيانات جاية من باقي أجزاء التطبيق)
final class DailyActivity {
  const DailyActivity({
    required this.date,
    this.steps = 0,
    this.caloriesIn = 0,
    this.waterLiters = 0,
    this.workoutMinutes = 0,
  });

  final DateTime date;
  final int steps;
  final double caloriesIn;
  final double waterLiters;
  final int workoutMinutes;
}

/// ملخص أسبوعي / شهري
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
    this.dailyActivity = const [],
    this.avgSteps = 0,
    this.avgCaloriesIn = 0,
    this.avgWaterLiters = 0,
    this.plannedDays = 0,
    this.plannedDaysDone = 0,
    this.heightCm,
    this.calorieGoal,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final double totalCaloriesBurned;
  final double? currentWeight;
  final double? startWeight;
  final List<WeightEntry> weightEntries;
  final List<WorkoutLog> workoutLogs;
  final List<ChartPoint> weeklyWorkoutPoints; // تمارين كل أسبوع
  final List<ChartPoint> weightChartPoints;
  final int currentStreak; // وزن على مدى الوقت

  // ─── مربوط بباقي التطبيق ───────────────────────────────
  final List<DailyActivity> dailyActivity; // آخر 7 أيام
  final int avgSteps; // متوسط الخطوات (الأيام اللي فيها بيانات)
  final double avgCaloriesIn; // متوسط السعرات المتناولة
  final double avgWaterLiters; // متوسط المياه
  final int plannedDays; // أيام التمرين المخططة (آخر 7 أيام)
  final int plannedDaysDone; // اللي اتنفّذ منها
  final double? heightCm; // من الملف الشخصي
  final double? calorieGoal; // هدف السعرات من الملف الشخصي

  double get planAdherence =>
      plannedDays == 0 ? 0 : (plannedDaysDone / plannedDays).clamp(0.0, 1.0);

  /// BUGFIX: الطول كان ثابت 1.78 — دلوقتي من الملف الشخصي.
  double? get bmi {
    if (currentWeight == null) return null;
    final heightInMeters = ((heightCm ?? 0) > 0 ? heightCm! : 178) / 100;
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
