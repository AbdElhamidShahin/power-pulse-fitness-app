import '../../../../core/services/user_profile_service.dart';

sealed class ProgressState {
  const ProgressState();
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

final class ProgressEmpty extends ProgressState {
  const ProgressEmpty();
}

final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.thisWeekCount,
    required this.history,
  });

  final int totalWorkouts;
  final int currentStreak;
  final int thisWeekCount;
  final List<WorkoutRecord> history;
}

final class ProgressError extends ProgressState {
  const ProgressError(this.message);
  final String message;
}
