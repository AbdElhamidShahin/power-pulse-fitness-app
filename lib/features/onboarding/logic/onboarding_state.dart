sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingSelecting extends OnboardingState {
  const OnboardingSelecting({
    required this.selectedLevel,
    required this.selectedGoal,
  });

  final String selectedLevel;
  final String selectedGoal;
}

final class OnboardingSaving extends OnboardingState {
  const OnboardingSaving();
}

final class OnboardingDone extends OnboardingState {
  const OnboardingDone();
}

final class OnboardingError extends OnboardingState {
  const OnboardingError(this.message);
  final String message;
}
