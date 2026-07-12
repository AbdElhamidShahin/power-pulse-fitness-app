import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../../data/models/food_entity.dart';
import '../usecases/nutrition_usecases.dart';
import 'nutrition_state.dart';


final class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit({
    required GetDailyNutritionUseCase getDailyNutrition,
    required AddMealEntryUseCase addMealEntry,
    required DeleteMealEntryUseCase deleteMealEntry,
  })  : _getDailyNutrition = getDailyNutrition,
        _addMealEntry = addMealEntry,
        _deleteMealEntry = deleteMealEntry,
        super(const NutritionInitial());

  final GetDailyNutritionUseCase _getDailyNutrition;
  final AddMealEntryUseCase _addMealEntry;
  final DeleteMealEntryUseCase _deleteMealEntry;

  Future<void> loadToday() async {
    emit(const NutritionLoading());
    final result = await _getDailyNutrition(DateTime.now());
    result.fold(
      onSuccess: (daily) => emit(NutritionLoaded(daily: daily)),
      onFailure: (f) => emit(NutritionError(_map(f))),
    );
  }

  Future<void> addEntry(MealEntry entry) async {
    final result = await _addMealEntry(entry);
    result.fold(
      onSuccess: (_) => loadToday(),
      onFailure: (f) => emit(NutritionError(_map(f))),
    );
  }

  Future<void> deleteEntry(String entryId) async {
    final result = await _deleteMealEntry(entryId);
    result.fold(
      onSuccess: (_) => loadToday(),
      onFailure: (f) => emit(NutritionError(_map(f))),
    );
  }

  String _map(AppFailure f) => switch (f) {
        NetworkFailure()    => 'تحقق من اتصال الإنترنت',
        CacheFailure()      => 'خطأ في حفظ البيانات',
        ServerFailure()     => 'خطأ في الخادم',
        NotFoundFailure()   => 'البيانات غير موجودة',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
      };
}

/// FoodSearchCubit — البحث عن أكل + pagination
final class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit(this._searchFood) : super(const FoodSearchIdle());

  final SearchFoodUseCase _searchFood;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const FoodSearchIdle());
      return;
    }
    emit(const FoodSearchLoading());
    final result = await _searchFood(query.trim(), page: 1);
    result.fold(
      onSuccess: (items) => emit(FoodSearchLoaded(
        results: items,
        query: query.trim(),
        hasMore: items.length >= 20,
        page: 1,
      )),
      onFailure: (f) => emit(FoodSearchError(_map(f))),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! FoodSearchLoaded || !current.hasMore) return;

    final nextPage = current.page + 1;
    final result = await _searchFood(current.query, page: nextPage);
    result.fold(
      onSuccess: (more) => emit(current.copyWith(
        results: [...current.results, ...more],
        hasMore: more.length >= 20,
        page: nextPage,
      )),
      onFailure: (_) {}, // silent — keep existing results
    );
  }

  void clear() => emit(const FoodSearchIdle());

  String _map(AppFailure f) => switch (f) {
        NetworkFailure() => 'تحقق من اتصال الإنترنت',
        _                => 'حدث خطأ غير متوقع',
      };
}

/// AddMealCubit — إضافة وجبة + تحديد الكمية
final class AddMealCubit extends Cubit<AddMealState> {
  AddMealCubit(this._addMealEntry) : super(const AddMealIdle());

  final AddMealEntryUseCase _addMealEntry;

  Future<void> addMeal({
    required FoodItem food,
    required MealType mealType,
    required double quantity,
  }) async {
    emit(const AddMealLoading());

    final entry = MealEntry(
      id:        '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
      food:      food,
      mealType:  mealType,
      quantity:  quantity,
      loggedAt:  DateTime.now(),
    );

    final result = await _addMealEntry(entry);
    result.fold(
      onSuccess: (_) => emit(const AddMealSuccess()),
      onFailure: (f) => emit(AddMealError(_map(f))),
    );
  }

  void reset() => emit(const AddMealIdle());

  String _map(AppFailure f) => switch (f) {
        CacheFailure()      => 'خطأ في حفظ الوجبة',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
        _                   => 'حدث خطأ',
      };
}
