import 'food_entity.dart';

final class FoodModel {
  const FoodModel({
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
  final String? imageUrl;
  final String? brand;

  factory FoodModel.fromOpenFoodFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    final nameAr = json['product_name_ar']?.toString().trim() ?? '';
    final nameEn = json['product_name']?.toString().trim() ?? '';

    return FoodModel(
      id: json['_id']?.toString() ?? '',
      name: nameEn.isNotEmpty ? nameEn : nameAr,
      nameAr: nameAr,
      calories: _d(nutriments['energy-kcal_100g']) ?? 0,
      protein: _d(nutriments['proteins_100g']) ?? 0,
      carbs: _d(nutriments['carbohydrates_100g']) ?? 0,
      fat: _d(nutriments['fat_100g']) ?? 0,
      fiber: _d(nutriments['fiber_100g']) ?? 0,
      sugar: _d(nutriments['sugars_100g']) ?? 0,
      servingSize: _d(json['serving_quantity']) ?? 100,
      imageUrl: json['image_url']?.toString(),
      brand: json['brands']?.toString(),
    );
  }

  FoodItem toEntity() => FoodItem(
    id: id,
    name: name,
    nameAr: nameAr,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
    sugar: sugar,
    servingSize: servingSize,
    imageUrl: imageUrl,
    brand: brand,
  );

  static List<FoodItem> toEntityList(List<dynamic> products) => products
      .map((p) =>
      FoodModel.fromOpenFoodFacts(p as Map<String, dynamic>).toEntity())
      .where((f) => f.name.isNotEmpty && f.calories > 0)
      .toList();

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final sanitized = v.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(sanitized);
    }
    return null;
  }
}