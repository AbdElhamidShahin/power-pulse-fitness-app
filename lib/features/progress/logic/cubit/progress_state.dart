import '../../data/models/progress_entity.dart';

sealed class ProgressState {
  const ProgressState();
}

final class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.summary,
    required this.period,
  });

  final ProgressSummary summary;
  final ProgressPeriod period;

  ProgressLoaded copyWith({ProgressSummary? summary, ProgressPeriod? period}) =>
      ProgressLoaded(
        summary: summary ?? this.summary,
        period:  period  ?? this.period,
      );
}

final class ProgressError extends ProgressState {
  const ProgressError(this.message);
  final String message;
}

// ─── Weight Log State ─────────────────────────────────────────
sealed class WeightLogState {
  const WeightLogState();
}

final class WeightLogIdle extends WeightLogState {
  const WeightLogIdle();
}

final class WeightLogLoading extends WeightLogState {
  const WeightLogLoading();
}

final class WeightLogSuccess extends WeightLogState {
  const WeightLogSuccess();
}

final class WeightLogError extends WeightLogState {
  const WeightLogError(this.message);
  final String message;
}
