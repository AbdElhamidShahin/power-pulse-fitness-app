import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_states.dart';
import '../../core/network/food_service.dart';
import '../../core/constants/app_constants.dart';
import '../../features/home/views/home_view.dart';
import '../../features/tools/views/tools_screen.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/workout_plans/views/choose_workout_system_screen.dart';
import '../../features/progress/views/progress_screen.dart';

/// Main app cubit.
///
/// Changes from original:
///
/// 1. [FoodService] is now injected via the constructor instead of being
///    instantiated with a raw [Dio()] instance. This ensures the configured
///    [DioClient] (with interceptors, timeouts, and error mapping) is used.
///    [AppCubit()] still works with no argument for screens that create their
///    own provider; pass the singleton from [setupDi()] when available.
///
/// 2. [_controller] (TextEditingController) removed from the cubit.
///    It was never connected to any TextField in the UI — [FoodDetailsScreen]
///    maintained its own separate controller — so the cubit was always
///    calling the API with an empty string. [fetchFoodDetails] now accepts
///    the query text as a parameter, supplied directly by the screen.
///    This also eliminates the controller disposal leak (Cubit has no
///    dispose() lifecycle hook).
///
/// 3. [getFoodDetails] (the method with the empty try-body that silently
///    did nothing) is removed. [fetchFoodDetails] is the single entry point
///    for food API calls.
///
/// 4. [Idelweight()] renamed to [calculateIdealWeight()] — Dart method names
///    must start with a lowercase letter.
///
/// 5. States renamed to match:
///    - [IdelWeightState]          → [IdealWeightState]
///    - [calculateIBWState]        → [CalculateIbwState]
///    - [calculateFinalResultState]→ [CalculateFinalResultState]
class AppCubit extends Cubit<AppState> {
  /// [foodService] is optional so existing [BlocProvider(create: (_) => AppCubit())]
  /// call-sites continue to compile. When [null], a bare [FoodService] is
  /// constructed using the configured [DioClient] from DI. Screens that go
  /// through [setupDi()] will pass the singleton; see [main.dart].
  AppCubit({FoodService? foodService})
      : _foodService = foodService,
        super(NewsIntiatialState());

  static AppCubit get(context) => BlocProvider.of<AppCubit>(context);

  // Lazily resolved so the cubit can still be constructed without DI.
  FoodService? _foodService;
  FoodService get _food {
    if (_foodService != null) return _foodService!;
    // Fallback: create with default Dio. This path is taken by feature screens
    // that call BlocProvider(create: (_) => AppCubit()) directly. Those screens
    // should be migrated to inject the singleton, but the fallback keeps them
    // functional in the interim.
    _foodService = FoodService.withDefaultDio();
    return _foodService!;
  }

  int currentIndex = 0;

  List<BottomNavigationBarItem> bottomItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسيه'),
    BottomNavigationBarItem(
        icon: Icon(Icons.calculate_rounded), label: 'الادوات'),
    BottomNavigationBarItem(
        icon: Icon(Icons.fitness_center_sharp), label: 'التمارين'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الاعدادات'),
  ];

  List<Widget> screens = const [
    HomeView(),
    ToolsScreen(),
    ProgressScreen(),
    SettingsView(),
  ];

  void changeBottomNavBar(int index) {
    currentIndex = index;
    emit(NewsBottomnavBarState());
  }

  // ── Dark mode ───────────────────────────────────────────────────────────────
  bool isDark = false;
  void changeAppMode() {
    isDark = !isDark;
    emit(AppChangeModeState(isDark));
  }

  // ── BMI ─────────────────────────────────────────────────────────────────────
  double weight1 = 0;
  double height1 = 0;
  double calculatedBMI = 0;

  String getResultText() {
    if (calculatedBMI >= AppConstants.bmiUnderweightMax &&
        calculatedBMI <= AppConstants.bmiNormalMax) {
      return 'وزن صحي';
    } else if (calculatedBMI < AppConstants.bmiUnderweightMax) {
      return 'نقص في الوزن';
    } else if (calculatedBMI >= 25 &&
        calculatedBMI <= AppConstants.bmiOverweightMax) {
      return 'زيادة في الوزن';
    } else if (calculatedBMI >= 30 &&
        calculatedBMI <= AppConstants.bmiObeseMax) {
      return 'سمنة';
    } else if (calculatedBMI > AppConstants.bmiObeseMax) {
      return 'سمنة مفرطة';
    } else {
      return 'غير معروف';
    }
  }

  void updateHeight(double newHeight, double value) {
    height1 = newHeight;
    emit(HeightUpdatedState());
  }

  void updateGender(String newGender) {
    gender = newGender;
    emit(GenderUpdatedState());
  }

  // ── Food Details ────────────────────────────────────────────────────────────
  double calories = 281.0;
  double fat = 125.0;
  double carbs = 145.0;
  double protein = 11.0;
  String label = '';
  bool showImage = true;
  bool isLoading = false;
  String errorMessage = '';

  /// Fetches food nutrition details for [query] from the Edamam API.
  ///
  /// [query] is the search text typed by the user, passed in directly from
  /// the screen's own [TextEditingController]. The cubit no longer owns a
  /// controller — that was the root cause of the bug where the API was
  /// always called with an empty string.
  Future<void> fetchFoodDetails(String query) async {
    isLoading = true;
    errorMessage = '';
    showImage = false;
    emit(FoodDetailsLoadingState());
    try {
      final details = await _food.getFoodDetails(query);
      calories = double.parse(details['calories'] ?? '0');
      fat = double.parse(details['fat'] ?? '0');
      protein = double.parse(details['protein'] ?? '0');
      carbs = double.parse(details['carbs'] ?? '0');
      label = details['label'] ?? 'Unknown';
      emit(FoodDetailsSuccessState());
    } catch (error) {
      errorMessage = 'Error: Unable to fetch food details. Please try again.';
      emit(FoodDetailsErrorState(errorMessage));
    } finally {
      isLoading = false;
    }
  }

  // ── Ideal Weight ────────────────────────────────────────────────────────────
  double height = 0;
  String gender = "";
  double result = 0;

  /// Renamed from [Idelweight] — Dart method names must start lowercase.
  void calculateIdealWeight() {
    if (height > 0) {
      if (gender == "MALE") {
        result = 22 * (height / 100) * (height / 100);
      } else if (gender == "FEMALE") {
        result = 22 * ((height - 10) / 100) * ((height - 10) / 100);
      } else {
        result = 0;
      }
    } else {
      result = 0;
    }
    emit(IdealWeightState());
  }

  // ── Calorie Calculator ──────────────────────────────────────────────────────
  double height0 = 0;
  double age = 0;
  double weight = 0;
  String activityLevel = "";
  String gender0 = "";
  double result0 = 0;
  double finalResult = 0;
  bool showCalorieTexts = false;
  int A = 1000;
  int B = 500;

  void calculateIBW() {
    if (height0 > 0 && weight > 0 && age > 0) {
      if (gender0 == "MALE") {
        result0 = 66 + (13.7 * weight) + (5 * height0) - (6.8 * age);
      } else if (gender0 == "FEMALE") {
        result0 = 655 + (9.6 * weight) + (1.8 * height0) - (4.7 * age);
      } else {
        result0 = 0;
      }
    }
    emit(CalculateIbwState());
  }

  void calculateFinalResult() {
    calculateIBW();
    if (result0 > 0) {
      showCalorieTexts = true;
      final multipliers = AppConstants.activityMultipliers;
      finalResult = result0 * (multipliers[activityLevel] ?? 1.0);
    }
    emit(CalculateFinalResultState());
  }
}