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

  Future<void> loadToday() async {
    _today = DateTime.now();
    emit(const NutritionLoading());
    await _silentReload(showLoading: false);
  }

  Future<void> _silentReload({bool showLoading = false}) async {
    final result = await _repository.getDailyNutrition(_today);
    switch (result) {
      case Success(:final data):
        emit(NutritionLoaded(daily: data));
      case Failure(:final failure):
        emit(NutritionError(_msg(failure)));
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
        emit(NutritionError(_msg(failure)));
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
        emit(NutritionError(_msg(failure)));
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

  String _msg(AppFailure f) => switch (f) {
        NetworkFailure() => 'تحقق من اتصال الإنترنت',
        CacheFailure() => 'خطأ في حفظ البيانات',
        ServerFailure() => 'خطأ في الخادم',
        NotFoundFailure() => 'البيانات غير موجودة',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
      };
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
        emit(FoodSearchError(_msg(failure)));
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

  String _msg(AppFailure f) => switch (f) {
        NetworkFailure() => 'تحقق من اتصال الإنترنت',
        _ => 'حدث خطأ غير متوقع',
      };
}

// ════════════════════════════════════════════════════════════════
// AddMealCubit
// ════════════════════════════════════════════════════════════════
final class AddMealCubit extends Cubit<AddMealState> {
  AddMealCubit(this._repository) : super(const AddMealIdle());

  final NutritionRepository _repository;

  Future<void> addMeal({
    required FoodItem food,
    required MealType mealType,
    required double quantity,
  }) async {
    emit(const AddMealLoading());

    final entry = MealEntry(
      id: '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
      food: food,
      mealType: mealType,
      quantity: quantity,
      loggedAt: DateTime.now(),
    );

    final result = await _repository.addMealEntry(entry);
    switch (result) {
      case Success():
        emit(const AddMealSuccess());
      case Failure(:final failure):
        emit(AddMealError(_msg(failure)));
    }
  }

  void reset() => emit(const AddMealIdle());

  String _msg(AppFailure f) => switch (f) {
        CacheFailure() => 'خطأ في حفظ الوجبة',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
        _ => 'حدث خطأ',
      };
}
