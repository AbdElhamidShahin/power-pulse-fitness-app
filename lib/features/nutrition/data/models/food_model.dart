import 'food_entity.dart';

/// FoodModel — Data Layer
/// Parses JSON from Open Food Facts API (free, no key needed)
final class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.servingSize = 100,
    this.imageUrl,
    this.brand,
  });

  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double servingSize;
  final String? imageUrl;
  final String? brand;

  factory FoodModel.fromOpenFoodFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    return FoodModel(
      id:          json['_id']?.toString()                    ?? '',
      name:        _extractName(json),
      calories:    _toDouble(nutriments['energy-kcal_100g'])  ?? 0,
      protein:     _toDouble(nutriments['proteins_100g'])     ?? 0,
      carbs:       _toDouble(nutriments['carbohydrates_100g'])?? 0,
      fat:         _toDouble(nutriments['fat_100g'])          ?? 0,
      fiber:       _toDouble(nutriments['fiber_100g'])        ?? 0,
      sugar:       _toDouble(nutriments['sugars_100g'])       ?? 0,
      servingSize: _toDouble(json['serving_quantity'])        ?? 100,
      imageUrl:    json['image_url']?.toString(),
      brand:       json['brands']?.toString(),
    );
  }

  FoodItem toEntity() => FoodItem(
        id:          id,
        name:        name,
        calories:    calories,
        protein:     protein,
        carbs:       carbs,
        fat:         fat,
        fiber:       fiber,
        sugar:       sugar,
        servingSize: servingSize,
        imageUrl:    imageUrl,
        brand:       brand,
      );

  static List<FoodItem> toEntityList(List<dynamic> products) => products
      .map((p) => FoodModel.fromOpenFoodFacts(p as Map<String, dynamic>).toEntity())
      .where((f) => f.name.isNotEmpty && f.calories > 0)
      .toList();

  // ─── Helpers ──────────────────────────────────────────────
  static String _extractName(Map<String, dynamic> json) {
    return json['product_name_ar']?.toString().trim().isNotEmpty == true
        ? json['product_name_ar'].toString().trim()
        : json['product_name']?.toString().trim() ?? '';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
