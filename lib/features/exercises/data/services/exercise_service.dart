import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exercise_entity.dart';
import '../models/exercise_model.dart';

abstract interface class ExerciseService {
  Future<List<Exercise>> fetchAllExercises();
}

final class ExerciseServiceImpl implements ExerciseService {
  ExerciseServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Exercise>> fetchAllExercises() async {
    try {
      final response = await _dio.get<List<int>>(
        ApiEndpoints.exercisesJson,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response');
      }
      final jsonString = utf8.decode(response.data!);
      final data = jsonDecode(jsonString);

      if (data is List) {
        return ExerciseModel.toEntityList(data);
      }
      throw const ServerException(message: 'Unexpected response format');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
