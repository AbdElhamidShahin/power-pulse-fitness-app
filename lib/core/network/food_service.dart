import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Network service for the Edamam food API.
///
/// Previously lived at lib/model/dio/dio.dart as `NewsService` (misnamed).
/// Moved to core/network with a clearer name and uses AppConstants for
/// the API credentials instead of hardcoded strings.
class FoodService {
  final Dio dio;

  FoodService(this.dio);

  Future<Map<String, dynamic>> getFoodDetails(String food) async {
    try {
      final response = await dio.get(
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
