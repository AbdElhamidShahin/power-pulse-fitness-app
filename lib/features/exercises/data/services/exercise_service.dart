import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exercise_entity.dart';
import '../models/exercise_model.dart';

abstract interface class ExerciseService {
  Future<List<Exercise>> getExercises({int limit, int offset});
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPart, {int limit});
  Future<List<Exercise>> searchExercisesByName(String name, {int limit});
  Future<Exercise> getExerciseById(String id);
  Future<List<String>> getBodyPartList();
}

final class ExerciseServiceImpl implements ExerciseService {
  ExerciseServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Exercise>> getExercises({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.exercises,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return ExerciseModel.toEntityList(response.data as List);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<Exercise>> getExercisesByBodyPart(
    String bodyPart, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.exercisesByTarget}/$bodyPart',
        queryParameters: {'limit': limit},
      );
      return ExerciseModel.toEntityList(response.data as List);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<Exercise>> searchExercisesByName(
    String name, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.exercisesByName}/$name',
        queryParameters: {'limit': limit},
      );
      return ExerciseModel.toEntityList(response.data as List);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Exercise> getExerciseById(String id) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.exerciseById}/$id',
      );
      return ExerciseModel.fromJson(response.data as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<String>> getBodyPartList() async {
    try {
      final response = await _dio.get(ApiEndpoints.bodyPartList);
      return (response.data as List).map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
