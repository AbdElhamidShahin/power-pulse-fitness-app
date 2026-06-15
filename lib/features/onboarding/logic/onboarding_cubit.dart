import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../data/repositories/onboarding_repo.dart';
import 'onboarding_state.dart';


class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository)
      : super(const OnboardingSelecting(
    selectedLevel: 'مبتدئ',
    selectedGoal: 'بناء العضلات',
  ));

  final OnboardingRepository _repository;


  static const levels = ['مبتدئ', 'متوسط', 'متقدم'];
  static const goals  = ['بناء العضلات', 'إنقاص الوزن', 'تحسين اللياقة', 'الحفاظ على الوزن'];


  String get currentLevel => switch (state) {
    OnboardingSelecting(:final selectedLevel) => selectedLevel,
    _ => levels.first,
  };

  String get currentGoal => switch (state) {
    OnboardingSelecting(:final selectedGoal) => selectedGoal,
    _ => goals.first,
  };


  void selectLevel(String level) {
    if (state is! OnboardingSelecting) return;
    emit(OnboardingSelecting(
      selectedLevel: level,
      selectedGoal: currentGoal,
    ));
  }

  void selectGoal(String goal) {
    if (state is! OnboardingSelecting) return;
    emit(OnboardingSelecting(
      selectedLevel: currentLevel,
      selectedGoal: goal,
    ));
  }

  Future<void> finish() async {
    if (state is OnboardingSaving) return;

    final level = currentLevel;
    final goal  = currentGoal;

    emit(const OnboardingSaving());

    final result = await _repository.saveProfile(level: level, goal: goal);

    switch (result) {
      case ApiSuccess():
        emit(const OnboardingDone());
      case ApiFailure(:final failure):
        emit(OnboardingError(failure.message));
    }
  }
}
