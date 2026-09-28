
final class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.nameAr = '',
    this.fiber = 0,
    this.sugar = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.imageUrl,
    this.brand,
  });

  final String id;
  final String name;
  final String nameAr;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double servingSize;
  final String servingUnit;
  final String? imageUrl;
  final String? brand;

  String get displayName => nameAr.trim().isNotEmpty ? nameAr.trim() : name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAr': nameAr,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'servingSize': servingSize,
    'servingUnit': servingUnit,
    'imageUrl': imageUrl,
    'brand': brand,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    nameAr: json['nameAr'] as String? ?? '',
    calories: (json['calories'] as num? ?? 0).toDouble(),
    protein: (json['protein'] as num? ?? 0).toDouble(),
    carbs: (json['carbs'] as num? ?? 0).toDouble(),
    fat: (json['fat'] as num? ?? 0).toDouble(),
    fiber: (json['fiber'] as num? ?? 0).toDouble(),
    sugar: (json['sugar'] as num? ?? 0).toDouble(),
    servingSize: (json['servingSize'] as num? ?? 100).toDouble(),
    servingUnit: json['servingUnit'] as String? ?? 'g',
    imageUrl: json['imageUrl'] as String?,
    brand: json['brand'] as String?,
  );

  @override
  bool operator ==(Object other) => other is FoodItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ════════════════════════════════════════════════════════════════
// MealEntry Entity
// ════════════════════════════════════════════════════════════════
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
  final double quantity; // grams
  final DateTime loggedAt;

  double get calories => food.calories * quantity / food.servingSize;
  double get protein => food.protein * quantity / food.servingSize;
  double get carbs => food.carbs * quantity / food.servingSize;
  double get fat => food.fat * quantity / food.servingSize;

  // ─── Local JSON Serialization ──────────────────────────────
  Map<String, dynamic> toJson() => {
    'id': id,
    'food': food.toJson(),
    'mealType': mealType.name,
    'quantity': quantity,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'] as String? ?? '',
    food: FoodItem.fromJson(json['food'] as Map<String, dynamic>),
    mealType: MealType.values.firstWhere(
          (e) => e.name == json['mealType'],
      orElse: () => MealType.snack,
    ),
    quantity: (json['quantity'] as num? ?? 100).toDouble(),
    loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ??
        DateTime.now(),
  );
}

// ════════════════════════════════════════════════════════════════
// MealType Enum
// ════════════════════════════════════════════════════════════════
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get labelAr => switch (this) {
    MealType.breakfast => 'الإفطار',
    MealType.lunch => 'الغداء',
    MealType.dinner => 'العشاء',
    MealType.snack => 'وجبة خفيفة',
  };

  String get icon => switch (this) {
    MealType.breakfast => '🌅',
    MealType.lunch => '☀️',
    MealType.dinner => '🌙',
    MealType.snack => '🍎',
  };
}

// ════════════════════════════════════════════════════════════════
// DailyNutrition Entity
// ════════════════════════════════════════════════════════════════
final class DailyNutrition {
  const DailyNutrition({
    required this.date,
    required this.entries,
    required this.calorieGoal,
    this.waterLiters = 0.0,
    this.waterGoal = 2.5,
    this.proteinGoal = 180,
    this.carbsGoal = 250,
    this.fatGoal = 65,
  });

  final DateTime date;
  final List<MealEntry> entries;
  final double calorieGoal;
  final double waterLiters;
  final double waterGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  double get totalCalories => entries.fold(0, (s, e) => s + e.calories);
  double get totalProtein => entries.fold(0, (s, e) => s + e.protein);
  double get totalCarbs => entries.fold(0, (s, e) => s + e.carbs);
  double get totalFat => entries.fold(0, (s, e) => s + e.fat);

  double get caloriesLeft =>
      (calorieGoal - totalCalories).clamp(0, calorieGoal);

  double get calorieProgress =>
      calorieGoal > 0 ? (totalCalories / calorieGoal).clamp(0.0, 1.0) : 0.0;

  List<MealEntry> entriesFor(MealType type) =>
      entries.where((e) => e.mealType == type).toList();

  DailyNutrition copyWith({
    List<MealEntry>? entries,
    double? waterLiters,
    double? calorieGoal,
  }) =>
      DailyNutrition(
        date: date,
        entries: entries ?? this.entries,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        waterLiters: waterLiters ?? this.waterLiters,
        waterGoal: waterGoal,
        proteinGoal: proteinGoal,
        carbsGoal: carbsGoal,
        fatGoal: fatGoal,
      );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'calorieGoal': calorieGoal,
    'waterLiters': waterLiters,
    'waterGoal': waterGoal,
    'proteinGoal': proteinGoal,
    'carbsGoal': carbsGoal,
    'fatGoal': fatGoal,
  };

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    entries: (json['entries'] as List<dynamic>? ?? [])
        .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    calorieGoal: (json['calorieGoal'] as num? ?? 2000).toDouble(),
    waterLiters: (json['waterLiters'] as num? ?? 0.0).toDouble(),
    waterGoal: (json['waterGoal'] as num? ?? 2.5).toDouble(),
    proteinGoal: (json['proteinGoal'] as num? ?? 180).toDouble(),
    carbsGoal: (json['carbsGoal'] as num? ?? 250).toDouble(),
    fatGoal: (json['fatGoal'] as num? ?? 65).toDouble(),
  );
}