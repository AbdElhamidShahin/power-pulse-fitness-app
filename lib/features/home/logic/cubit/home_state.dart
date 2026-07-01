import '../../data/home_summary.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.summary);
  final HomeSummary summary;
}

final class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
