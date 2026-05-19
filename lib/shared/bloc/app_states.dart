/// All BLoC states for the app.
///
/// Previously lib/model/bloc/states.dart — moved to shared/bloc/app_states.dart
/// so all features can import from one place.
abstract class AppState {}

class AppInitialState extends AppState {}

// ── Navigation ────────────────────────────────────────────────────────────────
class NewsIntiatialState extends AppState {}

class NewsBottomnavBarState extends AppState {}

class AppChangeModeState extends AppState {
  final bool isDark;
  AppChangeModeState(this.isDark);
}

// ── BMI ───────────────────────────────────────────────────────────────────────
class AppStateUpdatedState extends AppState {}

class BMICalculationState extends AppState {}

class HeightUpdatedState extends AppState {}

class weightUpdatedState extends AppState {}

class GenderUpdatedState extends AppState {}

// ── Ideal Weight ─────────────────────────────────────────────────────────────
class IdelWeightState extends AppState {}

// ── Calorie Calculator ────────────────────────────────────────────────────────
class calculateIBWState extends AppState {}

class calculateFinalResultState extends AppState {}

class calculateFinalResultstate extends AppState {}

class AppCalculationState extends AppState {}

// ── Food Details ──────────────────────────────────────────────────────────────
class getFoodDetailsState extends AppState {}

class detailsintegrsState extends AppState {}

class FoodDetailsLoadingState extends AppState {}

class FoodDetailsSuccessState extends AppState {}

class FoodDetailsErrorState extends AppState {
  final String errorMessage;
  FoodDetailsErrorState(this.errorMessage);
}
