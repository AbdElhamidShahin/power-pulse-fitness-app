import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/pedometer_service.dart';
import 'pedometer_state.dart';

final class PedometerCubit extends Cubit<PedometerState> {
  PedometerCubit({required PedometerService service})
      : _service = service,
        super(const PedometerInitial());

  final PedometerService _service;
  StreamSubscription<int>? _sub;

  static const int defaultGoal = 8000; // هدف 8000 خطوة يومياً

  Future<void> start() async {
    // نعرض الخطوات المحفوظة فوراً
    final saved = _service.savedDailySteps;
    emit(PedometerCounting(steps: saved, goal: defaultGoal));

    // نشترك في الـ stream
    _sub = _service.dailyStepsStream.listen(
      (steps) {
        if (state is PedometerCounting) {
          emit((state as PedometerCounting).copyWith(steps: steps));
        } else {
          emit(PedometerCounting(steps: steps, goal: defaultGoal));
        }
      },
      onError: (_) => emit(const PedometerUnavailable()),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
