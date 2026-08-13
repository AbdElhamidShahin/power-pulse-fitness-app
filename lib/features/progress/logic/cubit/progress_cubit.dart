import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../../data/models/progress_entity.dart';
import '../usecases/progress_usecases.dart';
import 'progress_state.dart';

final class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({required GetProgressSummaryUseCase getSummary})
      : _getSummary = getSummary,
        super(const ProgressInitial());

  final GetProgressSummaryUseCase _getSummary;

  Future<void> load([ProgressPeriod period = ProgressPeriod.month]) async {
    emit(const ProgressLoading());
    final result = await _getSummary(period);
    result.fold(
      onSuccess: (summary) =>
          emit(ProgressLoaded(summary: summary, period: period)),
      onFailure: (f) => emit(ProgressError(_map(f))),
    );
  }

  Future<void> changePeriod(ProgressPeriod period) async {
    final current = state;
    if (current is ProgressLoaded && current.period == period) return;
    await load(period);
  }

  String _map(AppFailure f) => switch (f) {
        CacheFailure()      => 'خطأ في قراءة البيانات',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
        _                   => 'حدث خطأ',
      };
}

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
      onFailure: (f) => emit(WeightLogError(_map(f))),
    );
  }

  Future<void> deleteEntry(String id) async {
    final result = await _deleteWeight(id);
    result.fold(
      onSuccess: (_) => emit(const WeightLogSuccess()),
      onFailure: (f) => emit(WeightLogError(_map(f))),
    );
  }

  void reset() => emit(const WeightLogIdle());

  String _map(AppFailure f) => switch (f) {
        CacheFailure() => 'خطأ في حفظ البيانات',
        _              => 'حدث خطأ',
      };
}
