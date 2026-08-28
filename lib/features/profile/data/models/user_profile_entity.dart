/// UserProfile Entity — Domain Layer
/// Pure Dart — Zero Flutter imports

enum FitnessGoal {
  loseFat,
  buildMuscle,
  endurance,
  maintain,
  lose,
  gain,
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
}

enum Gender {
  male,
  female,
}

extension FitnessGoalX on FitnessGoal {
  String get labelAr => switch (this) {
        FitnessGoal.loseFat => 'حرق الدهون',
        FitnessGoal.buildMuscle => 'بناء العضلات',
        FitnessGoal.endurance => 'تحسين اللياقة',
        FitnessGoal.maintain => 'الحفاظ على الوزن',
        FitnessGoal.lose => 'خسارة الوزن',
        FitnessGoal.gain => 'زيادة الوزن',
      };
}

extension ActivityLevelX on ActivityLevel {
  String get labelAr => switch (this) {
        ActivityLevel.sedentary => 'خامل (مكتب)',
        ActivityLevel.light => 'خفيف (1-3 أيام)',
        ActivityLevel.moderate => 'معتدل (3-5 أيام)',
        ActivityLevel.active => 'نشيط (6-7 أيام)',
        ActivityLevel.veryActive => 'نشيط جداً (رياضي)',
      };

  double get multiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}

extension GenderX on Gender {
  String get labelAr => switch (this) {
        Gender.male => 'ذكر',
        Gender.female => 'أنثى',
      };
}

final class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.goal,
    required this.activityLevel,
    this.avatarPath,
  });

  final String name;
  final String email;
  final int age;
  final double heightCm;
  final double weightKg;
  final Gender gender;
  final FitnessGoal goal;
  final ActivityLevel activityLevel;
  final String? avatarPath;

  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory => switch (bmi) {
        < 18.5 => 'نقص في الوزن',
        < 25.0 => 'وزن طبيعي',
        < 30.0 => 'زيادة في الوزن',
        _ => 'سمنة',
      };

  double get bmr => switch (gender) {
        Gender.male => (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5,
        Gender.female => (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161,
      };

  double get tdee => bmr * activityLevel.multiplier;

  double get dailyCalorieGoal => switch (goal) {
        FitnessGoal.loseFat => tdee - 500,
        FitnessGoal.buildMuscle => tdee + 300,
        FitnessGoal.endurance => tdee,
        FitnessGoal.maintain => tdee,
        FitnessGoal.lose => tdee - 500,
        FitnessGoal.gain => tdee + 500,
      };
  double get dailyProteinGoal => switch (goal) {
        FitnessGoal.buildMuscle => weightKg * 2.2,
        FitnessGoal.loseFat => weightKg * 2.0,
        _ => weightKg * 1.6,
      };

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    double? heightCm,
    double? weightKg,
    Gender? gender,
    FitnessGoal? goal,
    ActivityLevel? activityLevel,
    String? avatarPath,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        gender: gender ?? this.gender,
        goal: goal ?? this.goal,
        activityLevel: activityLevel ?? this.activityLevel,
        avatarPath: avatarPath ?? this.avatarPath,
      );
}

/// Default profile للمستخدم الجديد
const kDefaultProfile = UserProfile(
  name: 'المستخدم',
  email: '',
  age: 25,
  heightCm: 175,
  weightKg: 75,
  gender: Gender.male,
  goal: FitnessGoal.maintain,
  activityLevel: ActivityLevel.moderate,
);
