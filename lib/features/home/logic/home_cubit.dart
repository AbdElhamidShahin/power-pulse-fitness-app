import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../repo/data/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeLoading());

  final HomeRepository _repository;

  void load() {
    final result = _repository.getHomeData();
    switch (result) {
      case ApiSuccess(:final data):
        emit(HomeLoaded(data));
      case ApiFailure(:final failure):
        emit(HomeError(failure.message));
    }
  }
}
