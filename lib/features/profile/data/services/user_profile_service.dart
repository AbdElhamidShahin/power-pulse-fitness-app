import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─── WorkoutRecord ───────────────────────────────────────────
class WorkoutRecord {
  WorkoutRecord({required this.date});
  final DateTime date;

  Map<String, dynamic> toJson() => {'date': date.toIso8601String()};

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      WorkoutRecord(date: DateTime.parse(json['date'] as String));
}

// ─── UserProfile Model ───────────────────────────────────────
class UserProfile {
  const UserProfile({
    this.name = '',
    this.age = 0,
    this.weightKg = 0,
    this.heightCm = 0,
    this.goal = '',
    this.fitnessLevel = '',
    this.startWeekday = 1,
  });

  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final String goal;
  final String fitnessLevel;
  final int startWeekday;

  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final h = heightCm / 100;
    return weightKg / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b <= 0) return '—';
    if (b < 18.5) return 'نقص في الوزن';
    if (b < 25) return 'طبيعي';
    if (b < 30) return 'زيادة في الوزن';
    return 'سمنة';
  }

  // Daily calorie goal (Mifflin-St Jeor simplified)
  int get dailyCalorieGoal {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 2000;
    // BMR (assuming male avg — can extend later)
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    const activityFactor = 1.55; // moderately active
    final tdee = bmr * activityFactor;
    return switch (goal) {
      'lose_weight'   => (tdee - 500).round(),
      'gain_muscle'   => (tdee + 300).round(),
      _               => tdee.round(),
    };
  }

  int get dailyProteinGoal {
    if (weightKg <= 0) return 150;
    return (weightKg * 1.8).round();
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? goal,
    String? fitnessLevel,
    int? startWeekday,
  }) => UserProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    goal: goal ?? this.goal,
    fitnessLevel: fitnessLevel ?? this.fitnessLevel,
    startWeekday: startWeekday ?? this.startWeekday,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'goal': goal,
    'fitnessLevel': fitnessLevel,
    'startWeekday': startWeekday,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'] as String? ?? '',
    age: (j['age'] as num?)?.toInt() ?? 0,
    weightKg: (j['weightKg'] as num?)?.toDouble() ?? 0,
    heightCm: (j['heightCm'] as num?)?.toDouble() ?? 0,
    goal: j['goal'] as String? ?? '',
    fitnessLevel: j['fitnessLevel'] as String? ?? '',
    startWeekday: (j['startWeekday'] as num?)?.toInt() ?? 1,
  );
}

// ─── UserProfileService ──────────────────────────────────────
class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const _kOnboardingDone = 'profile_onboarding_done';
  static const _kFitnessLevel   = 'profile_fitness_level';
  static const _kFitnessGoal    = 'profile_fitness_goal';
  static const _kStartWeekday   = 'profile_start_weekday';
  static const _kHistory        = 'profile_workout_history';
  static const _kProfile        = 'profile_user_data';

  late SharedPreferences _prefs;

  bool onboardingDone = false;
  String fitnessLevel = '';
  String fitnessGoal  = '';
  int startWeekday    = 1;

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  List<WorkoutRecord> _history = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    onboardingDone = _prefs.getBool(_kOnboardingDone) ?? false;
    fitnessLevel   = _prefs.getString(_kFitnessLevel) ?? '';
    fitnessGoal    = _prefs.getString(_kFitnessGoal) ?? '';
    startWeekday   = _prefs.getInt(_kStartWeekday) ?? 1;

    // Load profile
    final profileRaw = _prefs.getString(_kProfile);
    if (profileRaw != null) {
      try {
        _profile = UserProfile.fromJson(
            jsonDecode(profileRaw) as Map<String, dynamic>);
      } catch (_) {}
    } else {
      // Migrate old data
      _profile = UserProfile(
        fitnessLevel: fitnessLevel,
        goal: fitnessGoal,
        startWeekday: startWeekday,
      );
    }

    // Load history
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

  Future<void> saveOnboarding({
    required String level,
    required String goal,
    required int startWeekday,
  }) async {
    onboardingDone   = true;
    fitnessLevel     = level;
    fitnessGoal      = goal;
    this.startWeekday = startWeekday;

    _profile = _profile.copyWith(
      fitnessLevel: level,
      goal: goal,
      startWeekday: startWeekday,
    );

    await _prefs.setBool(_kOnboardingDone, true);
    await _prefs.setString(_kFitnessLevel, level);
    await _prefs.setString(_kFitnessGoal, goal);
    await _prefs.setInt(_kStartWeekday, startWeekday);
    await _saveProfile();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile      = updated;
    fitnessLevel  = updated.fitnessLevel;
    fitnessGoal   = updated.goal;
    startWeekday  = updated.startWeekday;
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    await _prefs.setString(_kProfile, jsonEncode(_profile.toJson()));
  }

  Future<void> recordWorkoutCompleted([DateTime? when]) async {
    _history.add(WorkoutRecord(date: when ?? DateTime.now()));
    await _prefs.setString(
      _kHistory,
      jsonEncode(_history.map((r) => r.toJson()).toList()),
    );
  }

  List<WorkoutRecord> get thisWeekHistory {
    final now          = DateTime.now();
    final startOfWeek  = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay   = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _history.where((r) => !r.date.isBefore(startOfDay)).toList();
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
    final last = _history.map((r) => r.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final now      = DateTime.now();
    final lastDate = DateTime(last.year, last.month, last.day);
    final today    = DateTime(now.year, now.month, now.day);
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

  static String streakDayLabel(int streak) =>
      streak == 1 ? 'يوم متتالي' : 'أيام متتالية';
}
