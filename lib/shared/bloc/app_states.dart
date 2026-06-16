
sealed class AppState {
  const AppState();
}

final class AppInitial extends AppState {
  const AppInitial();
}

final class AppTabChanged extends AppState {
  const AppTabChanged(this.index);
  final int index;
}
