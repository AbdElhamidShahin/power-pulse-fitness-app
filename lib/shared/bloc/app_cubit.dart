import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
/// Previously lib/model/bloc/cubit.dart.
/// Only change: imports updated to the new folder structure.
/// All business logic is preserved exactly as-is.
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(NewsIntiatialState());

  static AppCubit get(context) => BlocProvider.of<AppCubit>(context);

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
  final TextEditingController _controller = TextEditingController();

  void getFoodDetails(String text) async {
    isLoading = true;
    errorMessage = '';
    showImage = false;
    emit(FoodDetailsLoadingState());
    try {} catch (e) {
      errorMessage = 'Error: $e';
      emit(FoodDetailsErrorState(errorMessage));
    }
  }

  final foodService = FoodService(Dio());

  void detailsintegrs() async {
    try {
      final details = await foodService.getFoodDetails(_controller.text);
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

  void Idelweight() {
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
    emit(IdelWeightState());
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
  int Result = 0;

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
    emit(calculateIBWState());
  }

  void calculateFinalResult() {
    calculateIBW();
    if (result0 > 0) {
      showCalorieTexts = true;
      final multipliers = AppConstants.activityMultipliers;
      finalResult =
          result0 * (multipliers[activityLevel] ?? 1.0);
    }
    emit(calculateFinalResultState());
  }
}
