import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutRecord {
  WorkoutRecord({required this.date});

  final DateTime date;

  Map<String, dynamic> toJson() => {'date': date.toIso8601String()};

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      WorkoutRecord(date: DateTime.parse(json['date'] as String));
}

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  static const _kOnboardingDone = 'profile_onboarding_done';
  static const _kFitnessLevel = 'profile_fitness_level';
  static const _kFitnessGoal = 'profile_fitness_goal';
  static const _kStartWeekday = 'profile_start_weekday';
  static const _kHistory = 'profile_workout_history';

  late SharedPreferences _prefs;

  bool onboardingDone = false;
  String fitnessLevel = '';
  String fitnessGoal = '';
  int startWeekday = 1;

  List<WorkoutRecord> _history = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    onboardingDone = _prefs.getBool(_kOnboardingDone) ?? false;
    fitnessLevel = _prefs.getString(_kFitnessLevel) ?? '';
    fitnessGoal = _prefs.getString(_kFitnessGoal) ?? '';
    startWeekday = _prefs.getInt(_kStartWeekday) ?? 1;

    final raw = _prefs.getString(_kHistory);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _history = list
            .map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _history = [];
      }
    }
  }

  /// Saves all onboarding selections and marks onboarding as complete.
  ///
  /// Previously named [completeOnboarding] and did not accept or persist
  /// [startWeekday]. The onboarding flow called [saveOnboarding] (which did
  /// not exist), causing a [NoSuchMethodError] at runtime that manifested as
  /// "LateInitializationError: Field '_prefs' has not been initialized".
  ///
  /// Renamed to [saveOnboarding] to match the call-site in [onboarding_flow.dart]
  /// and extended to persist [startWeekday], which is required by the home
  /// screen weekly plan offset logic.
  Future<void> saveOnboarding({
    required String level,
    required String goal,
    required int startWeekday,
  }) async {
    onboardingDone = true;
    fitnessLevel = level;
    fitnessGoal = goal;
    this.startWeekday = startWeekday;

    await _prefs.setBool(_kOnboardingDone, true);
    await _prefs.setString(_kFitnessLevel, level);
    await _prefs.setString(_kFitnessGoal, goal);
    await _prefs.setInt(_kStartWeekday, startWeekday);
  }

  Future<void> recordWorkoutCompleted([DateTime? when]) async {
    _history.add(WorkoutRecord(date: when ?? DateTime.now()));
    await _prefs.setString(
      _kHistory,
      jsonEncode(_history.map((r) => r.toJson()).toList()),
    );
  }

  List<WorkoutRecord> get thisWeekHistory {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _history.where((r) => !r.date.isBefore(startOfWeekDate)).toList();
  }

  bool get trainedToday {
    final now = DateTime.now();
    return _history.any((r) =>
        r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day);
  }

  int get daysSinceLastWorkout {
    if (_history.isEmpty) return 0;
    final last =
        _history.map((r) => r.date).reduce((a, b) => a.isAfter(b) ? a : b);
    final now = DateTime.now();
    final lastDate = DateTime(last.year, last.month, last.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(lastDate).inDays;
  }

  int get currentStreak {
    if (_history.isEmpty) return 0;
    final days = _history
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String streakMessage(int streak, {bool atRisk = false}) {
    if (streak == 0) return 'كل رحلة تبدأ بيوم واحد';
    if (atRisk) return 'سلسلتك في خطر — تدرب اليوم!';
    return 'أنت في المسار الصحيح، استمر!';
  }

  static String streakDayLabel(int streak) {
    return streak == 1 ? 'يوم م تتالي' : 'أيام متتالية';
  }
}
