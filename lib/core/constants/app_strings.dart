/// App-wide string constants (English only).
/// UI strings that need localization → use context.l10n instead.
abstract class AppStrings {
  AppStrings._();

  // ─── App ────────────────────────────────────────────────────
  static const String appName = 'Power Pulse';

  // ─── Muscle Groups (English keys for API mapping) ───────────
  static const String muscleChest    = 'chest';
  static const String muscleBack     = 'back';
  static const String muscleLegs     = 'legs';
  static const String muscleShoulder = 'shoulders';
  static const String muscleArms     = 'upper arms';
  static const String muscleCore     = 'core';
  static const String muscleCardio   = 'cardio';

  // ─── Levels (English keys for API mapping) ──────────────────
  static const String levelBeginner    = 'beginner';
  static const String levelIntermediate = 'intermediate';
  static const String levelAdvanced    = 'advanced';
  static const String level            = 'level';
}
