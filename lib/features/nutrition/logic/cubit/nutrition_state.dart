import '../../data/models/food_entity.dart';

sealed class NutritionState {
  const NutritionState();
}

final class NutritionInitial extends NutritionState {
  const NutritionInitial();
}

final class NutritionLoading extends NutritionState {
  const NutritionLoading();
}

final class NutritionLoaded extends NutritionState {
  const NutritionLoaded({required this.daily});
  final DailyNutrition daily;

  NutritionLoaded copyWith({DailyNutrition? daily}) =>
      NutritionLoaded(daily: daily ?? this.daily);
}

final class NutritionError extends NutritionState {
  const NutritionError(this.message);
  final String message;
}

/// FoodSearchState — البحث عن طعام
sealed class FoodSearchState {
  const FoodSearchState();
}

final class FoodSearchIdle extends FoodSearchState {
  const FoodSearchIdle();
}

final class FoodSearchLoading extends FoodSearchState {
  const FoodSearchLoading();
}

final class FoodSearchLoaded extends FoodSearchState {
  const FoodSearchLoaded({
    required this.results,
    required this.query,
    this.hasMore = true,
    this.page = 1,
  });
  final List<FoodItem> results;
  final String query;
  final bool hasMore;
  final int page;

  FoodSearchLoaded copyWith({
    List<FoodItem>? results,
    bool? hasMore,
    int? page,
  }) =>
      FoodSearchLoaded(
        results: results ?? this.results,
        query: query,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );
}

final class FoodSearchError extends FoodSearchState {
  const FoodSearchError(this.message);
  final String message;
}

/// AddMealState — إضافة وجبة
sealed class AddMealState {
  const AddMealState();
}

final class AddMealIdle extends AddMealState {
  const AddMealIdle();
}

final class AddMealLoading extends AddMealState {
  const AddMealLoading();
}

final class AddMealSuccess extends AddMealState {
  const AddMealSuccess();
}

final class AddMealError extends AddMealState {
  const AddMealError(this.message);
  final String message;
}
