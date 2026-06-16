import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/views/home_view.dart';
import '../../features/progress/views/progress_screen.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/tools/views/tools_screen.dart';
import 'app_states.dart';


class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppInitial());

  static AppCubit get(BuildContext context) => BlocProvider.of<AppCubit>(context);


  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeView(),
    ToolsScreen(),
    ProgressScreen(),
    SettingsView(),
  ];

  final List<BottomNavigationBarItem> bottomItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_filled),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calculate_outlined),
      activeIcon: Icon(Icons.calculate_rounded),
      label: 'الأدوات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart_rounded),
      label: 'التقدم',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'الإعدادات',
    ),
  ];

  void changeBottomNavBar(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    emit(AppTabChanged(index));
  }
}
