import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../data/pedometer_service.dart';
import 'pedometer_state.dart';

final class PedometerCubit extends Cubit<PedometerState> {
  PedometerCubit({required PedometerService service})
      : _service = service,
        super(const PedometerInitial());

  final PedometerService _service;
  StreamSubscription<int>? _sub;

  static const int defaultGoal = 8000; // هدف 8000 خطوة يومياً

  /// آمن للاستدعاء أكتر من مرة — مش بيعمل اشتراك مكرر.
  Future<void> start() async {
    if (_sub != null) return;

    // نعرض الخطوات المحفوظة فوراً
    emit(PedometerCounting(steps: _service.savedDailySteps, goal: defaultGoal));

    final status = await _service.ensurePermission();
    if (isClosed) return;
    if (!status.isGranted) {
      emit(PedometerUnavailable(
        permissionDenied: true,
        permanentlyDenied: status.isPermanentlyDenied,
      ));
      return;
    }

    _sub = _service.dailyStepsStream.listen(
      _onSteps,
      onError: (_) {
        _sub?.cancel();
        _sub = null;
        if (!isClosed) emit(const PedometerUnavailable());
      },
      cancelOnError: true,
    );
  }

  Future<void> _onSteps(int steps) async {
    if (isClosed) return;
    final current = state;
    emit(current is PedometerCounting
        ? current.copyWith(steps: steps)
        : PedometerCounting(steps: steps, goal: defaultGoal));

    if (await _service.consumeGoalNotification(steps, defaultGoal)) {
      NotificationService.instance.showStepsGoalReached(steps);
    }
  }

  /// بعد ما المستخدم يمنح الصلاحية (من الزرار أو من إعدادات الموبايل)
  Future<void> retry() async {
    await _sub?.cancel();
    _sub = null;
    await start();
  }

  /// بيتنادى لما التطبيق يرجع للـ foreground — لو العداد كان واقف بسبب الصلاحية
  Future<void> retryIfUnavailable() async {
    if (state is PedometerUnavailable) await retry();
  }

  Future<void> openSystemSettings() => _service.openSettings();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
