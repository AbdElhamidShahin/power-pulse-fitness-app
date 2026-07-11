import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/food_entity.dart';
import '../models/food_model.dart';

abstract interface class NutritionService {
  Future<List<FoodItem>> searchFood(String query, {int page});
  Future<FoodItem?> getFoodByBarcode(String barcode);
}

final class NutritionServiceImpl implements NutritionService {
  NutritionServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.foodSearch,
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page': page,
          'page_size': 20,
          'fields':
              '_id,product_name,product_name_ar,brands,nutriments,serving_quantity,image_url',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      return FoodModel.toEntityList(products);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.foodByBarcode}/$barcode.json',
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      return FoodModel.fromOpenFoodFacts(product).toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
