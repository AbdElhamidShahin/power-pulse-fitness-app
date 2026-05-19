/// App-wide constants extracted from hardcoded literals across the codebase.
class AppConstants {
  AppConstants._();

  // ── App meta ─────────────────────────────────────────────────────────────────
  static const String appName = 'Power Pulse';

  // ── External URLs (Settings screen) ─────────────────────────────────────────
  static const String privacyPolicyUrl =
      'https://www.freeprivacypolicy.com/live/931d000c-ebf9-46ec-a72d-a619560a7173';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yourcompanyname.yourappname';

  // ── Food API (model/dio/dio.dart) ────────────────────────────────────────────
  static const String foodApiBaseUrl =
      'https://api.edamam.com/api/food-database/v2/parser';
  static const String foodApiAppId = 'c022070b';
  static const String foodApiAppKey = 'dcda98c1bc8b9b4473c336b4f4966639';

  // ── Asset paths ──────────────────────────────────────────────────────────────
  static const String exercisesJson = 'assets/exercises.json';
  static const String backgroundImage = 'assets/images/123456.jpg';

  // Category images (Home_veiw)
  static const String imgChest = 'assets/catogry/chest.jpg';
  static const String imgLates = 'assets/catogry/lates.jpg';
  static const String imgShoulder = 'assets/catogry/shorter.jpeg';
  static const String imgRest = 'assets/catogry/6.jpg';
  static const String imgHands = 'assets/catogry/hands.jpg';
  static const String imgLegs = 'assets/catogry/legs.jpg';
  static const String imgBelly = 'assets/catogry/beuly.jpg';

  // ── Exercise page IDs (match JSON keys) ─────────────────────────────────────
  static const String pageIdChest = 'chest';
  static const String pageIdLates = 'lates';
  static const String pageIdShoulder = 'shorter';
  static const String pageIdHands = 'hands';
  static const String pageIdLegs = 'legs';
  static const String pageIdBelly = 'beily';

  // ── BMI thresholds ───────────────────────────────────────────────────────────
  static const double bmiUnderweightMax = 18.5;
  static const double bmiNormalMax = 24.9;
  static const double bmiOverweightMax = 29.9;
  static const double bmiObeseMax = 40.0;

  // ── Calorie activity multipliers ─────────────────────────────────────────────
  static const Map<String, double> activityMultipliers = {
    'culc1': 1.2,
    'culc2': 1.375,
    'culc3': 1.55,
    'culc4': 1.725,
    'culc5': 1.9,
  };
}
