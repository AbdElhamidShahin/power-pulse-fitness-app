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

  // كاش في الذاكرة للجلسة: نفس البحث متكررش شبكة
  final Map<String, List<FoodItem>> _cache = {};

  @override
  Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    // 1. قاعدة البيانات المحلية (أكلات مصرية/عربية + معلبات) — أول صفحة بس
    //    (قبل كده كانت بتتكرر في كل صفحة تحميل)
    final localResults =
        page == 1 ? ArabicFoodDatabase.search(query) : <FoodItem>[];

    // 2. Open Food Facts: منتجات مصر الأول، وبعدها العالمي
    try {
      final apiResults = await _searchOpenFoodFacts(query, page: page);

      final combined = <String, FoodItem>{};
      for (final item in localResults) {
        combined[item.id] = item;
      }
      for (final item in apiResults) {
        combined.putIfAbsent(item.id, () => item);
      }
      return combined.values.toList();
    } catch (_) {
      // لو الـ API فشل (Open Food Facts أحياناً بيرجّع 503) نرجع المحلي بس
      return localResults;
    }
  }

  Future<List<FoodItem>> _searchOpenFoodFacts(
    String query, {
    int page = 1,
  }) async {
    final cacheKey = '${query.toLowerCase()}|$page';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    // نبحث في منتجات مصر + العالمي بالتوازي، وفشل واحد مايوقّعش التاني
    final results = await Future.wait([
      _offRequest(query, page: page, egyptOnly: true),
      _offRequest(query, page: page, egyptOnly: false),
    ]);

    final merged = <String, FoodItem>{};
    for (final list in results) {
      for (final item in list) {
        merged.putIfAbsent(item.id, () => item);
      }
    }
    final out = merged.values.toList();
    if (out.isNotEmpty) _cache[cacheKey] = out;
    return out;
  }

  Future<List<FoodItem>> _offRequest(
    String query, {
    required int page,
    required bool egyptOnly,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.foodSearch,
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page': page,
          'page_size': egyptOnly ? 20 : 12,
          'lc': 'ar',
          if (egyptOnly) ...{
            'tagtype_0': 'countries',
            'tag_contains_0': 'contains',
            'tag_0': 'egypt',
          },
          'fields':
              'code,product_name,product_name_ar,product_name_en,brands,nutriments,serving_quantity,image_url',
          'sort_by': 'unique_scans_n',
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return const [];
      final products = data['products'] as List<dynamic>? ?? [];
      return FoodModel.toEntityList(products);
    } catch (_) {
      return const [];
    }
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
