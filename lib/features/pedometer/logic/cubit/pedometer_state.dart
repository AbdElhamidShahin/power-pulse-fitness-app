sealed class PedometerState {
  const PedometerState();
}

final class PedometerInitial extends PedometerState {
  const PedometerInitial();
}

final class PedometerUnavailable extends PedometerState {
  const PedometerUnavailable({
    this.permissionDenied = false,
    this.permanentlyDenied = false,
  });

  /// الصلاحية مرفوضة (نقدر نطلبها تاني)
  final bool permissionDenied;

  /// الصلاحية مرفوضة نهائياً (لازم يفتحها من إعدادات الموبايل)
  final bool permanentlyDenied;
}

final class PedometerCounting extends PedometerState {
  const PedometerCounting({
    required this.steps,
    required this.goal,
  });
  final int steps;
  final int goal;

  double get progress => (steps / goal.clamp(1, 99999)).clamp(0.0, 1.0);
  bool   get goalReached => steps >= goal;

  PedometerCounting copyWith({int? steps, int? goal}) => PedometerCounting(
        steps: steps ?? this.steps,
        goal:  goal  ?? this.goal,
      );
}
