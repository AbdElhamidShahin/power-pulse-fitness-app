import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'dio_client.dart';

class FoodService {
  final Dio _dio;

  FoodService(Dio dio) : _dio = dio;
  factory FoodService.withDefaultDio() {
    return FoodService(DioClient().dio);
  }

  Future<Map<String, dynamic>> getFoodDetails(String food) async {
    try {
      final response = await _dio.get(
        AppConstants.foodApiBaseUrl,
        queryParameters: {
          'ingr': food,
          'app_id': AppConstants.foodApiAppId,
          'app_key': AppConstants.foodApiAppKey,
        },
      );

      final Map<String, dynamic> jsonData = response.data;
      if (jsonData['hints'] != null && jsonData['hints'].isNotEmpty) {
        final nutrients = jsonData['hints'][0]['food']['nutrients'];
        final label =
            jsonData['hints'][0]['food']['label']?.toString() ?? 'N/A';

        return {
          'calories': nutrients['ENERC_KCAL']?.toString() ?? 'N/A',
          'fat': nutrients['FAT']?.toString() ?? 'N/A',
          'protein': nutrients['PROCNT']?.toString() ?? 'N/A',
          'carbs': nutrients['CHOCDF']?.toString() ?? 'N/A',
          'label': label,
        };
      } else {
        throw Exception('No details found for this food');
      }
    } catch (_) {
      throw Exception('Network error — unable to fetch food details');
    }
  }
}
