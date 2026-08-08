final class AppSettings {
  const AppSettings({
    this.isDarkMode = false,
    this.isMetricUnits = true,
    this.notificationsEnabled = true,
  });

  final bool isDarkMode;
  final bool isMetricUnits;
  final bool notificationsEnabled;

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isMetricUnits,
    bool? notificationsEnabled,
  }) =>
      AppSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isMetricUnits: isMetricUnits ?? this.isMetricUnits,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}
