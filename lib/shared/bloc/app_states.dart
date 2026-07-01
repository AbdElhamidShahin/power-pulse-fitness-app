/// All BLoC states for the app.
///
/// Previously lib/model/bloc/states.dart — moved to shared/bloc/app_states.dart
/// so all features can import from one place.
///
/// Removed states (were declared but never emitted or listened to anywhere):
///   - AppInitialState       (duplicate of NewsIntiatialState; cubit starts with NewsIntiatialState)
///   - BMICalculationState   (never emitted)
///   - weightUpdatedState    (never emitted; naming violation: lowercase start)
///   - calculateFinalResultstate (duplicate of calculateFinalResultState; differed only in casing)
///   - AppCalculationState   (never emitted)
///   - getFoodDetailsState   (never emitted; getFoodDetails() body was empty)
///   - detailsintegrsState   (never emitted)
///
/// Renamed for Dart UpperCamelCase compliance:
///   - calculateIBWState          → CalculateIbwState
///   - calculateFinalResultState  → CalculateFinalResultState  (already correct except first char)
///
/// AppChangeModeState is kept: it is emitted by changeAppMode() and the
/// infrastructure is in place for a future settings toggle to consume it.
///
/// AppStateUpdatedState is kept: it is emitted directly in bmi_widget.dart
/// to trigger a rebuild after inline BMI calculation.
abstract class AppState {}

// ── Navigation ────────────────────────────────────────────────────────────────
class NewsIntiatialState extends AppState {}

class NewsBottomnavBarState extends AppState {}

class AppChangeModeState extends AppState {
  final bool isDark;
  AppChangeModeState(this.isDark);
}

// ── BMI ───────────────────────────────────────────────────────────────────────
/// Emitted by bmi_widget.dart after an inline BMI calculation to trigger a
/// BlocConsumer rebuild. Kept because it has an active call-site.
class AppStateUpdatedState extends AppState {}

class HeightUpdatedState extends AppState {}

class GenderUpdatedState extends AppState {}

// ── Ideal Weight ─────────────────────────────────────────────────────────────
class IdealWeightState extends AppState {}

// ── Calorie Calculator ────────────────────────────────────────────────────────
class CalculateIbwState extends AppState {}

class CalculateFinalResultState extends AppState {}

// ── Food Details ──────────────────────────────────────────────────────────────
class FoodDetailsLoadingState extends AppState {}

class FoodDetailsSuccessState extends AppState {}

class FoodDetailsErrorState extends AppState {
  final String errorMessage;
  FoodDetailsErrorState(this.errorMessage);
}