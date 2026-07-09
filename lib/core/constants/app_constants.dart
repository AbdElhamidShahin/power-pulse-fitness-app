class AppConstants {
  AppConstants._();

  static const String appName = 'Power Pulse';
  static const String privacyPolicyUrl =
      'https://www.freeprivacypolicy.com/live/931d000c-ebf9-46ec-a72d-a619560a7173';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yourcompanyname.yourappname';


  static const String foodApiBaseUrl = String.fromEnvironment(
    'FOOD_API_BASE_URL',
    defaultValue: 'https://api.edamam.com/api/food-database/v2/parser',
  );
  static const String foodApiAppId = String.fromEnvironment(
    'FOOD_API_APP_ID',
    defaultValue: '',
  );
  static const String foodApiAppKey = String.fromEnvironment(
    'FOOD_API_APP_KEY',
    defaultValue: '',
  );

  static const String backgroundImage = 'assets/images/123456.jpg';
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



  // ─── Spacing ───────────────────────────────────────────────
  static const double spaceXXS =  2.0;
  static const double spaceXS  =  4.0;
  static const double spaceS   =  8.0;
  static const double spaceM   = 12.0;
  static const double spaceL   = 16.0;
  static const double spaceXL  = 20.0;
  static const double spaceXXL = 24.0;
  static const double space3XL = 32.0;
  static const double space4XL = 40.0;
  static const double space5XL = 48.0;

  // ─── Border Radius ─────────────────────────────────────────
  static const double radiusXS   =  6.0;
  static const double radiusS    = 10.0;
  static const double radiusM    = 14.0;
  static const double radiusL    = 18.0;
  static const double radiusXL   = 24.0;
  static const double radiusXXL  = 32.0;
  static const double radiusPill = 100.0;

  // ─── Screen Padding ────────────────────────────────────────
  static const double screenPaddingH = 18.0; // horizontal
  static const double screenPaddingV = 16.0; // vertical

  // ─── Component Sizes ───────────────────────────────────────
  // Buttons
  static const double buttonHeightLarge  = 52.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightSmall  = 36.0;

  // Icons
  static const double iconXS = 14.0;
  static const double iconS  = 18.0;
  static const double iconM  = 22.0;
  static const double iconL  = 28.0;
  static const double iconXL = 36.0;

  // Avatars
  static const double avatarS  = 32.0;
  static const double avatarM  = 42.0;
  static const double avatarL  = 56.0;
  static const double avatarXL = 80.0;

  // Cards
  static const double cardHeightHero  = 180.0;
  static const double cardHeightSmall = 100.0;
  static const double exerciseThumb   =  56.0;

  // Bottom Nav
  static const double bottomNavHeight = 64.0;

  // ─── Elevation / Blur ──────────────────────────────────────
  static const double blurGlass  = 12.0;
  static const double blurLight  =  6.0;

  // ─── Animation Durations ───────────────────────────────────
  static const Duration durationFast   = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow   = Duration(milliseconds: 400);
  static const Duration durationPage   = Duration(milliseconds: 300);

  // ─── API ───────────────────────────────────────────────────
  static const int apiTimeoutSeconds   = 15;
  static const int apiCacheDays        =  1;

  // ─── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;
}