import '../repo/data/home_data.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);
  final HomeData data;
}

final class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
