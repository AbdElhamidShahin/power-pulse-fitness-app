final class AppSettings {
  const AppSettings({
    this.isDarkMode = false,
    this.isMetricUnits = true,
    this.notificationsEnabled = true,
    this.locale = 'ar',
  });

  final bool isDarkMode;
  final bool isMetricUnits;
  final bool notificationsEnabled;
  final String locale; // 'ar' or 'en'

  bool get isArabic => locale == 'ar';

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isMetricUnits,
    bool? notificationsEnabled,
    String? locale,
  }) =>
      AppSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isMetricUnits: isMetricUnits ?? this.isMetricUnits,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        locale: locale ?? this.locale,
      );
}
