import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exercise_entity.dart';
import '../models/exercise_model.dart';

/// ExerciseRemoteService — Data / Service Layer
/// يجيب الـ JSON الكاملة من jsDelivr CDN (مرة واحدة بس)
abstract interface class ExerciseService {
  /// جيب كل التمارين دفعة واحدة من CDN
  Future<List<Exercise>> fetchAllExercises();
}

final class ExerciseServiceImpl implements ExerciseService {
  ExerciseServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Exercise>> fetchAllExercises() async {
    try {
      final response = await _dio.get(ApiEndpoints.exercisesJson);
      final data = response.data;

      // الـ response ممكن يكون List مباشرة أو String محتاج parse
      if (data is List) {
        return ExerciseModel.toEntityList(data);
      }
      throw const ServerException(message: 'Unexpected response format');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
