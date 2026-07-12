/// FoodItem Entity — Domain Layer
/// Pure Dart — Zero Flutter imports
final class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.imageUrl,
    this.brand,
  });

  final String id;
  final String name;
  final double calories;   // per serving
  final double protein;    // g
  final double carbs;      // g
  final double fat;        // g
  final double fiber;      // g
  final double sugar;      // g
  final double servingSize;
  final String servingUnit;
  final String? imageUrl;
  final String? brand;

  @override
  bool operator ==(Object other) => other is FoodItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// MealEntry — وجبة مسجلة في اليوم
final class MealEntry {
  const MealEntry({
    required this.id,
    required this.food,
    required this.mealType,
    required this.quantity,
    required this.loggedAt,
  });

  final String id;
  final FoodItem food;
  final MealType mealType;
  final double quantity;   // grams
  final DateTime loggedAt;

  double get calories => food.calories * quantity / food.servingSize;
  double get protein  => food.protein  * quantity / food.servingSize;
  double get carbs    => food.carbs    * quantity / food.servingSize;
  double get fat      => food.fat      * quantity / food.servingSize;
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get labelAr => switch (this) {
        MealType.breakfast => 'فطور',
        MealType.lunch     => 'غداء',
        MealType.dinner    => 'عشاء',
        MealType.snack     => 'وجبة خفيفة',
      };
}

/// DailyNutrition — ملخص يوم كامل
final class DailyNutrition {
  const DailyNutrition({
    required this.date,
    required this.entries,
    required this.calorieGoal,
  });

  final DateTime date;
  final List<MealEntry> entries;
  final double calorieGoal;

  double get totalCalories => entries.fold(0, (s, e) => s + e.calories);
  double get totalProtein  => entries.fold(0, (s, e) => s + e.protein);
  double get totalCarbs    => entries.fold(0, (s, e) => s + e.carbs);
  double get totalFat      => entries.fold(0, (s, e) => s + e.fat);
  double get caloriesLeft  => calorieGoal - totalCalories;
  double get calorieProgress => (totalCalories / calorieGoal).clamp(0, 1);

  List<MealEntry> entriesFor(MealType type) =>
      entries.where((e) => e.mealType == type).toList();
}
