sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLaunching extends SettingsState {
  const SettingsLaunching();
}

final class SettingsLaunched extends SettingsState {
  const SettingsLaunched();
}

final class SettingsLaunchError extends SettingsState {
  const SettingsLaunchError(this.message);
  final String message;
}
