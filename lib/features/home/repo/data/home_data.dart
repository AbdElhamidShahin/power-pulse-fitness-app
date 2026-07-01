import '../../../../core/services/user_profile_service.dart';

class HomeData {
  const HomeData({
    required this.streak,
    required this.trainedToday,
    required this.atRisk,
    required this.thisWeekHistory,
    required this.startWeekday,
  });

  final int streak;
  final bool trainedToday;
  final bool atRisk;
  final List<WorkoutRecord> thisWeekHistory;

  final int startWeekday;
}
