import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repo/tools_repositories.dart';
import 'tools_states.dart';


class BmiCubit extends Cubit<BmiState> {
  BmiCubit(this._repository) : super(const BmiInitial());

  final BmiRepository _repository;

  void calculate({required double heightCm, required double weightKg}) {
    final result = _repository.calculate(heightCm: heightCm, weightKg: weightKg);
    switch (result) {
      case ApiSuccess(:final data): emit(BmiLoaded(data));
      case ApiFailure(:final failure): emit(BmiError(failure.message));
    }
  }
}


class FoodCubit extends Cubit<FoodState> {
  FoodCubit(this._repository) : super(const FoodInitial());

  final FoodRepository _repository;

  Future<void> search(String query) async {
    if (state is FoodLoading) return;
    emit(const FoodLoading());
    final result = await _repository.getFoodDetails(query);
    switch (result) {
      case ApiSuccess(:final data): emit(FoodLoaded(data));
      case ApiFailure(:final failure): emit(FoodError(failure.message));
    }
  }
}


class IdealWeightCubit extends Cubit<IdealWeightState> {
  IdealWeightCubit(this._repository) : super(const IdealWeightInitial());

  final IdealWeightRepository _repository;

  void calculate({required double heightCm, required String gender}) {
    final result = _repository.calculate(heightCm: heightCm, gender: gender);
    switch (result) {
      case ApiSuccess(:final data): emit(IdealWeightLoaded(data));
      case ApiFailure(:final failure): emit(IdealWeightError(failure.message));
    }
  }
}


class CalorieCubit extends Cubit<CalorieState> {
  CalorieCubit(this._repository) : super(const CalorieInitial());

  final CalorieRepository _repository;

  void calculate({
    required double heightCm,
    required double weightKg,
    required double ageYears,
    required String gender,
    required String activityLevel,
  }) {
    final result = _repository.calculate(
      heightCm: heightCm,
      weightKg: weightKg,
      ageYears: ageYears,
      gender: gender,
      activityLevel: activityLevel,
    );
    switch (result) {
      case ApiSuccess(:final data): emit(CalorieLoaded(data));
      case ApiFailure(:final failure): emit(CalorieError(failure.message));
    }
  }
}
