import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/food_entity.dart';
import '../models/food_model.dart';
import 'arabic_food_database.dart';

abstract interface class NutritionService {
  Future<List<FoodItem>> searchFood(String query, {int page});
  Future<FoodItem?> getFoodByBarcode(String barcode);
}

final class NutritionServiceImpl implements NutritionService {
  NutritionServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    // 1. ابحث في قاعدة البيانات العربية المحلية أولاً
    final localResults = ArabicFoodDatabase.search(query);

    // 2. اجمع مع نتائج الـ API (Open Food Facts with Arabic preference)
    try {
      final apiResults = await _searchOpenFoodFacts(query, page: page);

      // دمج النتائج: المحلية أولاً ثم API بدون تكرار
      final combined = <String, FoodItem>{};
      for (final item in localResults) {
        combined[item.id] = item;
      }
      for (final item in apiResults) {
        if (!combined.containsKey(item.id)) {
          combined[item.id] = item;
        }
      }
      return combined.values.toList();
    } catch (_) {
      // لو الـ API فشل، نرجع النتائج المحلية بس
      return localResults;
    }
  }

  Future<List<FoodItem>> _searchOpenFoodFacts(
    String query, {
    int page = 1,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.foodSearch,
      queryParameters: {
        'search_terms': query,
        'search_simple': 1,
        'action': 'process',
        'json': 1,
        'page': page,
        'page_size': 15,
        // نفضّل المنتجات اللي عندها اسم عربي
        'fields':
            '_id,product_name,product_name_ar,brands,nutriments,serving_quantity,image_url',
        'sort_by': 'popularity',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final products = data['products'] as List<dynamic>? ?? [];
    return FoodModel.toEntityList(products);
  }

  @override
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.foodByBarcode}/$barcode.json',
      );
      final data = response.data as Map<String, dynamic>;

      final status = data['status'];
      if (status != 1 && status != '1') return null;

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      return FoodModel.fromOpenFoodFacts(product).toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw ServerException(message: 'خطأ في معالجة الـ Barcode: $e');
    }
  }
}
