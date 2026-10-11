# Phase 9 — Home workout, weekly plan, and startup permissions

## Changes
- Fixed the `/workout-logger` route to provide the shared `WorkoutPlanCubit`, which `WorkoutLoggerScreen` reads when starting a workout.
- Fixed the home daily-goal rows to display `current value / target` rather than `target / current value`.
- Changed the weekly strips to display Saturday → Sunday → Monday → Tuesday → Wednesday → Thursday → Friday, which appears right-to-left in the Arabic RTL UI.
- Enforced Friday as a rest day in workout-plan loading, editing, adding exercises, and saving. Existing saved plans with Friday workouts are normalized on load.
- Sequenced startup permission/service initialization so notification/exact-alarm prompts finish before the activity-recognition prompt is requested.

## Validation
- Checked all edited source snippets and the weekday mapping.
- Flutter/Dart SDK is not available in this environment, so `dart format`, `flutter analyze`, and an Android build could not be run. Please run those checks in a Flutter-enabled environment and test the permission dialogs on a real Android device.
