import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/food_entity.dart';

/// NutritionLocalService — Local Storage
/// يخزن وجبات اليوم في SharedPreferences كـ JSON
/// في الـ production يتحول لـ Hive
abstract interface class NutritionLocalService {
  Future<List<MealEntry>> getMealEntries(DateTime date);
  Future<void> addMealEntry(MealEntry entry);
  Future<void> deleteMealEntry(String entryId);
  Future<double> getCalorieGoal();
  Future<void> saveCalorieGoal(double goal);
}

final class NutritionLocalServiceImpl implements NutritionLocalService {
  NutritionLocalServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _calorieGoalKey  = 'calorie_goal';
  static const double _defaultGoal = 2000;

  String _dateKey(DateTime date) =>
      'meals_${date.year}_${date.month}_${date.day}';

  @override
  Future<List<MealEntry>> getMealEntries(DateTime date) async {
    try {
      final raw = _prefs.getString(_dateKey(date));
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => _entryFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      throw const CacheException(message: 'خطأ في قراءة الوجبات');
    }
  }

  @override
  Future<void> addMealEntry(MealEntry entry) async {
    try {
      final existing = await getMealEntries(entry.loggedAt);
      final updated = [...existing, entry];
      await _prefs.setString(_dateKey(entry.loggedAt), jsonEncode(updated.map(_entryToJson).toList()));
    } catch (_) {
      throw const CacheException(message: 'خطأ في حفظ الوجبة');
    }
  }

  @override
  Future<void> deleteMealEntry(String entryId) async {
    try {
      final today = DateTime.now();
      final existing = await getMealEntries(today);
      final updated = existing.where((e) => e.id != entryId).toList();
      await _prefs.setString(_dateKey(today), jsonEncode(updated.map(_entryToJson).toList()));
    } catch (_) {
      throw const CacheException(message: 'خطأ في حذف الوجبة');
    }
  }

  @override
  Future<double> getCalorieGoal() async =>
      _prefs.getDouble(_calorieGoalKey) ?? _defaultGoal;

  @override
  Future<void> saveCalorieGoal(double goal) async =>
      _prefs.setDouble(_calorieGoalKey, goal);

  // ─── JSON serialization ─────────────────────────────────────
  Map<String, dynamic> _entryToJson(MealEntry e) => {
        'id':         e.id,
        'mealType':   e.mealType.name,
        'quantity':   e.quantity,
        'loggedAt':   e.loggedAt.toIso8601String(),
        'food': {
          'id':          e.food.id,
          'name':        e.food.name,
          'calories':    e.food.calories,
          'protein':     e.food.protein,
          'carbs':       e.food.carbs,
          'fat':         e.food.fat,
          'fiber':       e.food.fiber,
          'sugar':       e.food.sugar,
          'servingSize': e.food.servingSize,
          'servingUnit': e.food.servingUnit,
          'imageUrl':    e.food.imageUrl,
          'brand':       e.food.brand,
        },
      };

  MealEntry _entryFromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>;
    final food = FoodItem(
      id:          foodJson['id'] as String,
      name:        foodJson['name'] as String,
      calories:    (foodJson['calories'] as num).toDouble(),
      protein:     (foodJson['protein'] as num).toDouble(),
      carbs:       (foodJson['carbs'] as num).toDouble(),
      fat:         (foodJson['fat'] as num).toDouble(),
      fiber:       (foodJson['fiber'] as num? ?? 0).toDouble(),
      sugar:       (foodJson['sugar'] as num? ?? 0).toDouble(),
      servingSize: (foodJson['servingSize'] as num? ?? 100).toDouble(),
      servingUnit: foodJson['servingUnit'] as String? ?? 'g',
      imageUrl:    foodJson['imageUrl'] as String?,
      brand:       foodJson['brand'] as String?,
    );
    return MealEntry(
      id:        json['id'] as String,
      food:      food,
      mealType:  MealType.values.byName(json['mealType'] as String),
      quantity:  (json['quantity'] as num).toDouble(),
      loggedAt:  DateTime.parse(json['loggedAt'] as String),
    );
  }
}
