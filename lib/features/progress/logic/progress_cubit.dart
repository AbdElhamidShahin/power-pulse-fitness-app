import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/user_profile_service.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._profileService) : super(const ProgressLoading());

  final UserProfileService _profileService;

  void load() {
    try {
      final history = _profileService.thisWeekHistory;
      final total = _profileService.currentStreak;
      final streak = _profileService.currentStreak;
      final weekCount = history.length;

      if (_profileService.currentStreak == 0 && history.isEmpty) {
        emit(const ProgressEmpty());
        return;
      }

      emit(ProgressLoaded(
        totalWorkouts: total,
        currentStreak: streak,
        thisWeekCount: weekCount,
        history: history,
      ));
    } catch (e) {
      emit(ProgressError('فشل تحميل بيانات التقدم: ${e.toString()}'));
    }
  }
}
