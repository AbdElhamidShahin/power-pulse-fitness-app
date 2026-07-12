


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../usecases/exercise_usecases.dart';
import 'exercises_state.dart';

final class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit({
    required GetExercisesUseCase getExercises,
    required GetExercisesByBodyPartUseCase getByBodyPart,
    required GetBodyPartListUseCase getBodyParts,
  })  : _getExercises = getExercises,
        _getByBodyPart = getByBodyPart,
        _getBodyParts = getBodyParts,
        super(const ExercisesInitial());

  final GetExercisesUseCase _getExercises;
  final GetExercisesByBodyPartUseCase _getByBodyPart;
  final GetBodyPartListUseCase _getBodyParts;

  static const String _allFilter = 'all';
  int _offset = 0;

  /// Initial load — exercises + body parts list
  Future<void> loadInitial() async {
    emit(const ExercisesLoading());

    final bodyPartsResult = await _getBodyParts();
    final exercisesResult = await _getExercises(limit: 20, offset: 0);

    // Both must succeed
    bodyPartsResult.fold(
      onFailure: (f) => emit(ExercisesError(_mapFailure(f))),
      onSuccess: (bodyParts) {
        exercisesResult.fold(
          onFailure: (f) => emit(ExercisesError(_mapFailure(f))),
          onSuccess: (exercises) {
            _offset = exercises.length;
            emit(ExercisesLoaded(
              exercises: exercises,
              bodyParts: [_allFilter, ...bodyParts],
              selectedBodyPart: _allFilter,
              hasMore: exercises.length >= 20,
            ));
          },
        );
      },
    );
  }

  /// Filter by body part
  Future<void> filterByBodyPart(String bodyPart) async {
    final current = state;
    if (current is! ExercisesLoaded) return;
    if (current.selectedBodyPart == bodyPart) return;

    emit(const ExercisesLoading());
    _offset = 0;

    if (bodyPart == _allFilter) {
      final result = await _getExercises(limit: 20, offset: 0);
      result.fold(
        onFailure: (f) => emit(ExercisesError(_mapFailure(f))),
        onSuccess: (exercises) {
          _offset = exercises.length;
          emit(current.copyWith(
            exercises: exercises,
            selectedBodyPart: _allFilter,
            hasMore: exercises.length >= 20,
          ));
        },
      );
      return;
    }

    final result = await _getByBodyPart(bodyPart);
    result.fold(
      onFailure: (f) => emit(ExercisesError(_mapFailure(f))),
      onSuccess: (exercises) {
        emit(current.copyWith(
          exercises: exercises,
          selectedBodyPart: bodyPart,
          hasMore: false, // ExerciseDB returns all for a target
        ));
      },
    );
  }

  /// Load more — pagination (all filter only)
  Future<void> loadMore() async {
    final current = state;
    if (current is! ExercisesLoaded) return;
    if (!current.hasMore) return;
    if (current.selectedBodyPart != _allFilter) return;

    final result = await _getExercises(limit: 20, offset: _offset);
    result.fold(
      onFailure: (_) {}, // silent — don't break existing list
      onSuccess: (more) {
        _offset += more.length;
        emit(current.copyWith(
          exercises: [...current.exercises, ...more],
          hasMore: more.length >= 20,
        ));
      },
    );
  }

  // ─── Private ──────────────────────────────────────────────
  String _mapFailure(AppFailure f) => switch (f) {
        NetworkFailure()    => 'تحقق من اتصال الإنترنت',
        ServerFailure()     => 'خطأ في الخادم، حاول لاحقاً',
        NotFoundFailure()   => 'لم يتم العثور على التمارين',
        CacheFailure()      => 'خطأ في التخزين المحلي',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
      };
}

/// ExerciseSearchCubit — Search only
final class ExerciseSearchCubit extends Cubit<ExerciseSearchState> {
  ExerciseSearchCubit(this._searchExercises)
      : super(const ExerciseSearchIdle());

  final SearchExercisesUseCase _searchExercises;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const ExerciseSearchIdle());
      return;
    }

    emit(const ExerciseSearchLoading());
    final result = await _searchExercises(query.trim());
    result.fold(
      onFailure: (f) => emit(ExerciseSearchError(_mapFailure(f))),
      onSuccess: (exercises) => emit(ExerciseSearchLoaded(exercises)),
    );
  }

  void clear() => emit(const ExerciseSearchIdle());

  String _mapFailure(AppFailure f) => switch (f) {
        NetworkFailure()    => 'تحقق من اتصال الإنترنت',
        ServerFailure()     => 'خطأ في الخادم، حاول لاحقاً',
        _                   => 'حدث خطأ غير متوقع',
      };
}

/// ExerciseDetailCubit — Single exercise detail
final class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this._getById) : super(const ExerciseDetailInitial());

  final GetExerciseByIdUseCase _getById;

  Future<void> load(String id) async {
    emit(const ExerciseDetailLoading());
    final result = await _getById(id);
    result.fold(
      onFailure: (f) => emit(ExerciseDetailError(_mapFailure(f))),
      onSuccess: (exercise) => emit(ExerciseDetailLoaded(exercise)),
    );
  }

  String _mapFailure(AppFailure f) => switch (f) {
        NetworkFailure()    => 'تحقق من اتصال الإنترنت',
        NotFoundFailure()   => 'التمرين غير موجود',
        _                   => 'حدث خطأ غير متوقع',
      };
}
