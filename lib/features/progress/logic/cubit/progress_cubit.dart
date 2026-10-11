import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/app_data_bus.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../../data/models/progress_entity.dart';
import '../usecases/progress_usecases.dart';
import 'progress_state.dart';

final class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({required GetProgressSummaryUseCase getSummary})
      : _getSummary = getSummary,
        super(const ProgressInitial()) {
    // صفحة التقدم مربوطة ببقية التطبيق: أي وجبة/تمرين/وزن/ماء يتسجّل
    // بيحدّثها تلقائياً.
    _busSub = AppDataBus.stream.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        final s = state;
        if (!isClosed && s is ProgressLoaded) load(s.period, true);
      });
    });
  }

  final GetProgressSummaryUseCase _getSummary;
  StreamSubscription<void>? _busSub;
  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    _busSub?.cancel();
    return super.close();
  }

  Future<void> load([
    ProgressPeriod period = ProgressPeriod.month,
    bool silent = false,
  ]) async {
    if (!silent || state is! ProgressLoaded) emit(const ProgressLoading());
    final result = await _getSummary(period);
    result.fold(
      onSuccess: (summary) =>
          emit(ProgressLoaded(summary: summary, period: period)),
      onFailure: (f) => emit(ProgressError(f.userMessage)),
    );
  }

  Future<void> changePeriod(ProgressPeriod period) async {
    final current = state;
    if (current is ProgressLoaded && current.period == period) return;
    await load(period);
  }

  // _map أُزيلت — استخدم AppFailureX.userMessage
}

/// WeightLogCubit — إضافة / حذف الوزن
final class WeightLogCubit extends Cubit<WeightLogState> {
  WeightLogCubit({
    required AddWeightEntryUseCase addWeight,
    required DeleteWeightEntryUseCase deleteWeight,
  })  : _addWeight = addWeight,
        _deleteWeight = deleteWeight,
        super(const WeightLogIdle());

  final AddWeightEntryUseCase _addWeight;
  final DeleteWeightEntryUseCase _deleteWeight;

  Future<void> addEntry(double weight, {String? note}) async {
    emit(const WeightLogLoading());
    final entry = WeightEntry(
      id:     'w_${DateTime.now().millisecondsSinceEpoch}',
      weight: weight,
      date:   DateTime.now(),
      note:   note,
    );
    final result = await _addWeight(entry);
    result.fold(
      onSuccess: (_) => emit(const WeightLogSuccess()),
      onFailure: (f) => emit(WeightLogError(f.userMessage)),
    );
  }

  Future<void> deleteEntry(String id) async {
    final result = await _deleteWeight(id);
    result.fold(
      onSuccess: (_) => emit(const WeightLogSuccess()),
      onFailure: (f) => emit(WeightLogError(f.userMessage)),
    );
  }

  void reset() => emit(const WeightLogIdle());

  // _map أُزيلت — استخدم AppFailureX.userMessage
}
