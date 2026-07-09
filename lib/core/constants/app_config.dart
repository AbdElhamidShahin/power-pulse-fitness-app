class AppConfig {
  AppConfig._();

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

  static const int apiTimeoutSeconds = 15;
  static const int apiCacheDays = 1;
}