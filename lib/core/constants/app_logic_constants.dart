class AppLogicConstants {
  AppLogicConstants._();

  static const String pageIdChest = 'chest';
  static const String pageIdLats = 'lats';
  static const String pageIdShoulder = 'shoulder';
  static const String pageIdHands = 'hands';
  static const String pageIdLegs = 'legs';
  static const String pageIdBelly = 'belly';

  static const double bmiUnderweightMax = 18.5;
  static const double bmiNormalMax = 24.9;
  static const double bmiOverweightMax = 29.9;
  static const double bmiObeseMax = 40.0;

  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
  };

  static const int pageSize = 20;
}