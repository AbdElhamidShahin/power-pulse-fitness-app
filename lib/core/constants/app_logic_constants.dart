class AppLogicConstants {
  AppLogicConstants._();

  // ─── Exercise Page IDs (Match JSON keys) ───────────────────
  static const String pageIdChest = 'chest';
  static const String pageIdLats = 'lats';
  static const String pageIdShoulder = 'shoulder';
  static const String pageIdHands = 'hands';
  static const String pageIdLegs = 'legs';
  static const String pageIdBelly = 'belly';

  // ─── BMI Thresholds ──────────────────────────────────────────
  static const double bmiUnderweightMax = 18.5;
  static const double bmiNormalMax = 24.9;
  static const double bmiOverweightMax = 29.9;
  static const double bmiObeseMax = 40.0;

  // ─── Calorie Activity Multipliers ────────────────────────────
  // تم تحسين المفاتيح لتعبّر عن مستوى النشاط بدلاً من أسماء مبهمة مثل culc1
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,          // نشاط قليل جداً
    'lightly_active': 1.375,   // نشاط خفيف
    'moderately_active': 1.55, // نشاط متوسط
    'very_active': 1.725,      // نشاط عالي
    'extra_active': 1.9,       // نشاط عالي جداً الرياضيين
  };

  // ─── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;
}