import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../data/models/food_entity.dart';
import '../../data/repositories/nutrition_repository.dart';
import 'nutrition_state.dart';

final class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit(this._repository) : super(const NutritionInitial());

  final NutritionRepository _repository;
  DateTime _today = DateTime.now();
  DateTime get selectedDate => _today;

  Future<void> loadToday() async {
    await loadDate(DateTime.now());
  }

  Future<void> reloadSelectedDate() async {
    await _silentReload(showLoading: false);
  }

  Future<void> loadDate(DateTime date) async {
    // Normalize to a calendar day; adding 24 hours can drift across DST.
    _today = DateTime(date.year, date.month, date.day);
    emit(const NutritionLoading());
    await _silentReload(showLoading: false);
  }

  void goToPreviousDay() => loadDate(DateTime(_today.year, _today.month, _today.day - 1));
  void goToNextDay() {
    if (isToday) return;
    loadDate(DateTime(_today.year, _today.month, _today.day + 1));
  }
  bool get isToday {
    final now = DateTime.now();
    return _today.year == now.year &&
        _today.month == now.month &&
        _today.day == now.day;
  }

  Future<void> _silentReload({bool showLoading = false}) async {
    final requestedDate = _today;
    final result = await _repository.getDailyNutrition(requestedDate);
    // Ignore stale responses if the user quickly navigated to another day.
    if (isClosed || requestedDate != _today) return;
    switch (result) {
      case Success(:final data):
        emit(NutritionLoaded(daily: data));
      case Failure(:final failure):
        emit(NutritionError(failure.userMessage));
    }
  }

  Future<void> addEntry(MealEntry entry) async {
    final prev = state;

    if (prev is NutritionLoaded) {
      emit(NutritionLoaded(
        daily: prev.daily.copyWith(
          entries: [...prev.daily.entries, entry],
        ),
      ));
    }

    final result = await _repository.addMealEntry(entry);
    switch (result) {
      case Success():
        await _silentReload();
      case Failure(:final failure):
        if (prev is NutritionLoaded) emit(prev);
        emit(NutritionError(failure.userMessage));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Delete Entry — Optimistic UI
  // ════════════════════════════════════════════════════════════
  Future<void> deleteEntry(String entryId) async {
    final prev = state;
    if (prev is! NutritionLoaded) return;

    emit(NutritionLoaded(
      daily: prev.daily.copyWith(
        entries: prev.daily.entries.where((e) => e.id != entryId).toList(),
      ),
    ));

    final result = await _repository.deleteMealEntry(entryId, _today);
    switch (result) {
      case Success():
        await _silentReload();
      case Failure(:final failure):
        emit(prev);
        emit(NutritionError(failure.userMessage));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Water
  // ════════════════════════════════════════════════════════════
  static const double _waterStep = 0.25;
  static const double _waterMax = 5.0;

  Future<void> addWater() async {
    final prev = state;
    if (prev is! NutritionLoaded) return;
    final next = (prev.daily.waterLiters + _waterStep).clamp(0.0, _waterMax);
    emit(NutritionLoaded(daily: prev.daily.copyWith(waterLiters: next)));
    await _repository.saveWaterLiters(next, _today);
  }

  Future<void> removeWater() async {
    final prev = state;
    if (prev is! NutritionLoaded) return;
    final next = (prev.daily.waterLiters - _waterStep).clamp(0.0, _waterMax);
    emit(NutritionLoaded(daily: prev.daily.copyWith(waterLiters: next)));
    await _repository.saveWaterLiters(next, _today);
  }

  Future<void> setWater(double liters) async {
    final prev = state;
    if (prev is! NutritionLoaded) return;
    final next = liters.clamp(0.0, _waterMax);
    emit(NutritionLoaded(daily: prev.daily.copyWith(waterLiters: next)));
    await _repository.saveWaterLiters(next, _today);
  }
  // _msg أُزيلت — استخدم AppFailureX.userMessage
}

// ════════════════════════════════════════════════════════════════
// FoodSearchCubit
// ════════════════════════════════════════════════════════════════
final class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit(this._repository) : super(const FoodSearchIdle());

  final NutritionRepository _repository;
  bool _isLoadingMore = false;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const FoodSearchIdle());
      return;
    }
    emit(const FoodSearchLoading());
    final result = await _repository.searchFood(query.trim(), page: 1);
    switch (result) {
      case Success(:final data):
        emit(FoodSearchLoaded(
          results: data,
          query: query.trim(),
          hasMore: data.length >= 20,
          page: 1,
        ));
      case Failure(:final failure):
        emit(FoodSearchError(failure.userMessage));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! FoodSearchLoaded || !current.hasMore || _isLoadingMore)
      return;

    _isLoadingMore = true;
    final result =
    await _repository.searchFood(current.query, page: current.page + 1);
    switch (result) {
      case Success(:final data):
        emit(current.copyWith(
          results: [...current.results, ...data],
          hasMore: data.length >= 20,
          page: current.page + 1,
        ));
      case Failure():
        break;
    }
    _isLoadingMore = false;
  }

  void clear() => emit(const FoodSearchIdle());
  // _msg أُزيلت — استخدم AppFailureX.userMessage
}

// ════════════════════════════════════════════════════════════════
// AddMealCubit
// ════════════════════════════════════════════════════════════════
final class AddMealCubit extends Cubit<AddMealState> {
  AddMealCubit(this._repository) : super(const AddMealIdle());

  final NutritionRepository _repository;

  Future<bool> addMeal({
    required FoodItem food,
    required MealType mealType,
    required double quantity,
    DateTime? loggedAt,
  }) async {
    emit(const AddMealLoading());

    final entry = MealEntry(
      id: '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
      food: food,
      mealType: mealType,
      quantity: quantity,
      loggedAt: loggedAt ?? DateTime.now(),
    );

    final result = await _repository.addMealEntry(entry);
    switch (result) {
      case Success():
        emit(const AddMealSuccess());
        return true;
      case Failure(:final failure):
        emit(AddMealError(failure.userMessage));
        return false;
    }
  }

  void reset() => emit(const AddMealIdle());
  // _msg أُزيلت — استخدم AppFailureX.userMessage
}
