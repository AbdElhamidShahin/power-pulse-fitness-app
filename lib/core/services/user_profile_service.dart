import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// UserProfileService — the persistent backbone of the product.
///
/// Responsibilities:
///   1. Onboarding data   — goal, fitness level, preferred system, start day
///   2. Streak engine     — last workout date, current streak, longest streak
///   3. Workout history   — per-session records (day, duration, calories, exercises)
///   4. BMI baseline      — persisted so user can see change over time
///
/// All reads are synchronous after init(). Call await init() once at app start.
/// The service is a singleton — get via UserProfileService.instance.
class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  SharedPreferences? _prefs;

  // ── Keys ───────────────────────────────────────────────────────────────────
  static const _kGoal            = 'profile_goal';
  static const _kLevel           = 'profile_level';
  static const _kSystem          = 'profile_system';
  static const _kStartDay        = 'profile_start_day';
  static const _kStreak          = 'streak_current';
  static const _kStreakLongest   = 'streak_longest';
  static const _kLastWorkout     = 'streak_last_workout_date'; // ISO 8601 date string
  static const _kHistory         = 'workout_history';          // JSON list
  static const _kBmiBaseline     = 'bmi_baseline';
  static const _kCalBaseline     = 'cal_baseline';
  static const _kOnboardingDone  = 'onboarding_done';

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'Call UserProfileService.instance.init() before use');
    return _prefs!;
  }

  // ── Onboarding ──────────────────────────────────────────────────────────────
  bool get onboardingDone   => _p.getBool(_kOnboardingDone) ?? false;
  String get fitnessGoal    => _p.getString(_kGoal)   ?? '';
  String get fitnessLevel   => _p.getString(_kLevel)  ?? '';
  String get preferredSystem => _p.getString(_kSystem) ?? '';
  int    get startWeekday   => _p.getInt(_kStartDay)   ?? 1; // 1=Monday

  Future<void> saveOnboarding({
    required String goal,
    required String level,
    String system = '',
    int startWeekday = 1,
  }) async {
    await _p.setString(_kGoal,     goal);
    await _p.setString(_kLevel,    level);
    await _p.setString(_kSystem,   system);
    await _p.setInt(_kStartDay,    startWeekday);
    await _p.setBool(_kOnboardingDone, true);
  }

  // ── Streak engine ───────────────────────────────────────────────────────────
  int get currentStreak  => _p.getInt(_kStreak)        ?? 0;
  int get longestStreak  => _p.getInt(_kStreakLongest)  ?? 0;

  String? get _lastWorkoutDateStr => _p.getString(_kLastWorkout);

  DateTime? get lastWorkoutDate {
    final s = _lastWorkoutDateStr;
    return s != null ? DateTime.tryParse(s) : null;
  }

  /// Call when user completes a workout session.
  /// Returns the updated streak count.
  Future<int> recordWorkoutCompleted() async {
    final now        = DateTime.now();
    final todayDate  = DateTime(now.year, now.month, now.day);
    final last       = lastWorkoutDate;
    int streak       = currentStreak;

    if (last == null) {
      // First ever workout
      streak = 1;
    } else {
      final lastDate   = DateTime(last.year, last.month, last.day);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 0) {
        // Already trained today — no change
        return streak;
      } else if (difference == 1) {
        // Consecutive day — increment
        streak += 1;
      } else {
        // Streak broken — reset to 1
        streak = 1;
      }
    }

    await _p.setInt(_kStreak, streak);
    await _p.setString(_kLastWorkout, todayDate.toIso8601String());

    // Update longest
    if (streak > longestStreak) {
      await _p.setInt(_kStreakLongest, streak);
    }

    return streak;
  }

  /// Whether the user trained today (for home screen state)
  bool get trainedToday {
    final last = lastWorkoutDate;
    if (last == null) return false;
    final now = DateTime.now();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  /// Days since last workout — used for "streak at risk" messaging
  int get daysSinceLastWorkout {
    final last = lastWorkoutDate;
    if (last == null) return 999;
    return DateTime.now().difference(last).inDays;
  }

  // ── Workout history ─────────────────────────────────────────────────────────
  List<WorkoutRecord> get history {
    final raw = _p.getString(_kHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => WorkoutRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkoutRecord(WorkoutRecord record) async {
    final current = history;
    current.insert(0, record); // newest first
    // Keep last 90 sessions max
    final trimmed = current.take(90).toList();
    await _p.setString(_kHistory, jsonEncode(trimmed.map((r) => r.toJson()).toList()));
  }

  // Week history (last 7 days)
  List<WorkoutRecord> get thisWeekHistory {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return history.where((r) => r.date.isAfter(cutoff)).toList();
  }

  int get weeklyWorkoutCount     => thisWeekHistory.length;
  int get weeklyTotalMinutes     => thisWeekHistory.fold(0, (sum, r) => sum + r.durationMinutes);
  int get weeklyTotalCalories    => thisWeekHistory.fold(0, (sum, r) => sum + r.estimatedCalories);

  // ── BMI & Calorie baselines ─────────────────────────────────────────────────
  double get bmiBaseline  => _p.getDouble(_kBmiBaseline) ?? 0;
  double get calBaseline  => _p.getDouble(_kCalBaseline) ?? 0;

  Future<void> saveBmiBaseline(double bmi) =>
      _p.setDouble(_kBmiBaseline, bmi);

  Future<void> saveCalBaseline(double cal) =>
      _p.setDouble(_kCalBaseline, cal);

  // ── Arabic pluralization ──────────────────────────────────────────────────
  /// Returns correct Arabic plural form for streak day count.
  static String streakDayLabel(int days) {
    if (days == 0) return 'لا أيام';
    if (days == 1) return 'يوم واحد';
    if (days == 2) return 'يومان';
    if (days >= 3 && days <= 10) return 'أيام متتالية';
    return 'يوماً متتالياً';
  }

  // ── Coaching voice — streak messages ───────────────────────────────────────
  /// Returns a context-aware coaching message based on streak state.
  static String streakMessage(int streak, {bool atRisk = false}) {
    if (atRisk) {
      return 'سلسلتك على المحك — تدرب اليوم للحفاظ عليها';
    }
    if (streak == 0)  return 'كل رحلة تبدأ بيوم واحد';
    if (streak == 1)  return 'اليوم الأول — البداية هي أصعب خطوة';
    if (streak == 2)  return 'يومان متتاليان — هذا يُحسب';
    if (streak == 3)  return 'ثلاثة أيام — العادة تبدأ هنا';
    if (streak < 7)   return 'أنت في المنطقة — لا تتوقف';
    if (streak == 7)  return 'أسبوع كامل — إنجاز حقيقي';
    if (streak < 14)  return 'لديك زخم — هذا ما يبنيه المتدربون الجادون';
    if (streak == 14) return 'أسبوعان — جسدك يتغير الآن';
    if (streak < 30)  return 'في منتصف الطريق — الاستمرارية هي النتيجة';
    if (streak == 30) return 'شهر كامل — أنت من القلائل';
    return 'مستوى نخبة — هذا الانضباط لا يُشترى';
  }

  /// Returns a coaching message for the completion screen based on session stats
  static String completionMessage({
    required int durationMinutes,
    required int streak,
    required int exerciseCount,
  }) {
    if (streak >= 30) return 'هذا ما يبدو عليه الانضباط الحقيقي.';
    if (streak >= 14) return 'أسبوعان من الثبات. جسدك يلاحظ.';
    if (streak >= 7)  return 'أسبوع كامل. أنت تبني شيئاً حقيقياً.';
    if (durationMinutes >= 50) return 'جلسة ممتازة. هذا الجهد يُترجَم.';
    if (exerciseCount >= 5)    return 'تمارين متعددة في جلسة واحدة. استمر.';
    if (streak == 1)           return 'البداية الأصعب. الآن أصبح أسهل.';
    return 'تمرين منجز. هذا هو الفرق بين من يتكلم ومن يفعل.';
  }
}

// ── WorkoutRecord data model ───────────────────────────────────────────────
class WorkoutRecord {
  final DateTime date;
  final String muscleGroup;   // e.g. 'عضلات الصدر'
  final int durationMinutes;
  final int estimatedCalories;
  final int exerciseCount;
  final String systemName;    // e.g. 'Push Pull Legs'

  const WorkoutRecord({
    required this.date,
    required this.muscleGroup,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exerciseCount,
    this.systemName = '',
  });

  factory WorkoutRecord.fromJson(Map<String, dynamic> j) => WorkoutRecord(
        date:               DateTime.parse(j['date'] as String),
        muscleGroup:        j['muscleGroup']       as String? ?? '',
        durationMinutes:    j['durationMinutes']   as int?    ?? 0,
        estimatedCalories:  j['estimatedCalories'] as int?    ?? 0,
        exerciseCount:      j['exerciseCount']     as int?    ?? 0,
        systemName:         j['systemName']        as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'date':               date.toIso8601String(),
        'muscleGroup':        muscleGroup,
        'durationMinutes':    durationMinutes,
        'estimatedCalories':  estimatedCalories,
        'exerciseCount':      exerciseCount,
        'systemName':         systemName,
      };
}
