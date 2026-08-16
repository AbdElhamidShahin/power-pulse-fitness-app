import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/cloud_sync_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/food_entity.dart';

abstract interface class NutritionLocalService {
  Future<List<MealEntry>> getMealEntries(DateTime date);
  Future<void> addMealEntry(MealEntry entry);
  Future<void> deleteMealEntry(String entryId, DateTime date);
  Future<double> getCalorieGoal();
  Future<void> saveCalorieGoal(double goal);
  Future<double> getWaterLiters(DateTime date);
  Future<void> saveWaterLiters(double liters, DateTime date);
}

final class NutritionLocalServiceImpl implements NutritionLocalService {
  NutritionLocalServiceImpl(
    this._prefs,
    this._auth,
    this._firestore,
  );

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _calorieGoalKey = 'calorie_goal';
  static const double _defaultGoal = 2000.0;

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _mealsKey(DateTime d) => 'meals_${_dateStr(d)}';
  String _waterKey(DateTime d) => 'water_${_dateStr(d)}';

  // ════════════════════════════════════════════════════════════
  // Meals
  // ════════════════════════════════════════════════════════════
  @override
  Future<List<MealEntry>> getMealEntries(DateTime date) async {
    try {
      final raw = _prefs.getString(_mealsKey(date));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _entryFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'خطأ في قراءة الوجبات: $e');
    }
  }

  @override
  Future<void> addMealEntry(MealEntry entry) async {
    try {
      final existing = await getMealEntries(entry.loggedAt);
      final filtered = existing.where((e) => e.id != entry.id).toList();
      final updated = [...filtered, entry];
      await _prefs.setString(
        _mealsKey(entry.loggedAt),
        jsonEncode(updated.map(_entryToJson).toList()),
      );

      // ─── Cloud sync ────────────────────────────────────────────────────────
      CloudSyncService.syncNutrition(_prefs, _auth, _firestore);
    } catch (e) {
      throw CacheException(message: 'خطأ في حفظ الوجبة: $e');
    }
  }

  @override
  Future<void> deleteMealEntry(String entryId, DateTime date) async {
    try {
      final existing = await getMealEntries(date);
      final updated = existing.where((e) => e.id != entryId).toList();
      await _prefs.setString(
        _mealsKey(date),
        jsonEncode(updated.map(_entryToJson).toList()),
      );

      // ─── Cloud sync ────────────────────────────────────────────────────────
      CloudSyncService.syncNutrition(_prefs, _auth, _firestore);
    } catch (e) {
      throw CacheException(message: 'خطأ في حذف الوجبة: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Calorie Goal
  // ════════════════════════════════════════════════════════════
  //
  // Storage note: calorie_goal is persisted as a String (the double value
  // encoded via toString) so that syncLocalKeyToCloud — which uses
  // prefs.getString — can read it directly.  A legacy double entry from
  // older builds is read as a fallback and then migrated to String format.
  @override
  Future<double> getCalorieGoal() async {
    try {
      // Prefer the canonical String form.
      final strVal = _prefs.getString(_calorieGoalKey);
      if (strVal != null) return double.tryParse(strVal) ?? _defaultGoal;

      // Legacy: old builds stored this as a double — migrate on read.
      final legacyDouble = _prefs.getDouble(_calorieGoalKey);
      if (legacyDouble != null) {
        // Migrate to string format silently.
        await _prefs.setString(_calorieGoalKey, legacyDouble.toString());
        return legacyDouble;
      }

      return _defaultGoal;
    } catch (e) {
      throw CacheException(message: 'خطأ في قراءة هدف السعرات: $e');
    }
  }

  @override
  Future<void> saveCalorieGoal(double goal) async {
    try {
      // Store as String so syncLocalKeyToCloud can read it via prefs.getString.
      await _prefs.setString(_calorieGoalKey, goal.toString());
      CloudSyncService.syncKey(_prefs, _auth, _firestore, _calorieGoalKey);
    } catch (e) {
      throw CacheException(message: 'خطأ في حفظ هدف السعرات: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Water
  // ════════════════════════════════════════════════════════════
  @override
  Future<double> getWaterLiters(DateTime date) async {
    try {
      return _prefs.getDouble(_waterKey(date)) ?? 0.0;
    } catch (e) {
      throw CacheException(message: 'خطأ في قراءة كمية المياه: $e');
    }
  }

  @override
  Future<void> saveWaterLiters(double liters, DateTime date) async {
    try {
      await _prefs.setDouble(_waterKey(date), liters.clamp(0.0, 10.0));

      // ─── Cloud sync ────────────────────────────────────────────────────────
      CloudSyncService.syncNutrition(_prefs, _auth, _firestore);
    } catch (e) {
      throw CacheException(message: 'خطأ في حفظ كمية المياه: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // JSON Serialization
  // ════════════════════════════════════════════════════════════
  Map<String, dynamic> _entryToJson(MealEntry e) => {
        'id': e.id,
        'mealType': e.mealType.name,
        'quantity': e.quantity,
        'loggedAt': e.loggedAt.toIso8601String(),
        'food': {
          'id': e.food.id,
          'name': e.food.name,
          'nameAr': e.food.nameAr,
          'calories': e.food.calories,
          'protein': e.food.protein,
          'carbs': e.food.carbs,
          'fat': e.food.fat,
          'fiber': e.food.fiber,
          'sugar': e.food.sugar,
          'servingSize': e.food.servingSize,
          'servingUnit': e.food.servingUnit,
          'imageUrl': e.food.imageUrl,
          'brand': e.food.brand,
        },
      };

  MealEntry _entryFromJson(Map<String, dynamic> json) {
    final fj = json['food'] as Map<String, dynamic>;
    final food = FoodItem(
      id: fj['id'] as String,
      name: fj['name'] as String,
      nameAr: fj['nameAr'] as String? ?? '',
      calories: (fj['calories'] as num).toDouble(),
      protein: (fj['protein'] as num).toDouble(),
      carbs: (fj['carbs'] as num).toDouble(),
      fat: (fj['fat'] as num).toDouble(),
      fiber: (fj['fiber'] as num? ?? 0).toDouble(),
      sugar: (fj['sugar'] as num? ?? 0).toDouble(),
      servingSize: (fj['servingSize'] as num? ?? 100).toDouble(),
      servingUnit: fj['servingUnit'] as String? ?? 'g',
      imageUrl: fj['imageUrl'] as String?,
      brand: fj['brand'] as String?,
    );

    // Safe MealType parsing
    final mealTypeStr = json['mealType'] as String? ?? '';
    final mealType = MealType.values.firstWhere(
      (e) => e.name == mealTypeStr,
      orElse: () => MealType.snack,
    );

    return MealEntry(
      id: json['id'] as String,
      food: food,
      mealType: mealType,
      quantity: (json['quantity'] as num).toDouble(),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}
