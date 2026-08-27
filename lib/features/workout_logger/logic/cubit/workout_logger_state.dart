import '../../data/models/workout_session_entity.dart';

sealed class WorkoutLoggerState {
  const WorkoutLoggerState();
}

class WorkoutLoggerInitial extends WorkoutLoggerState {
  const WorkoutLoggerInitial();
}

class WorkoutLoggerLoading extends WorkoutLoggerState {
  const WorkoutLoggerLoading();
}

/// لا يوجد تمرين نشط
class WorkoutLoggerIdle extends WorkoutLoggerState {
  const WorkoutLoggerIdle();
}

/// تمرين نشط جاري
class WorkoutLoggerActive extends WorkoutLoggerState {
  const WorkoutLoggerActive(this.session);
  final WorkoutSession session;
}

/// انتهى التمرين — عرض الملخص
class WorkoutLoggerFinished extends WorkoutLoggerState {
  const WorkoutLoggerFinished(this.session);
  final WorkoutSession session;
}

class WorkoutLoggerError extends WorkoutLoggerState {
  const WorkoutLoggerError(this.message);
  final String message;
}
