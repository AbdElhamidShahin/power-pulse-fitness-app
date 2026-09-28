import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const List<String> _tabs = [
    AppRouter.home,
    AppRouter.exercises,
    AppRouter.nutrition,
    AppRouter.progress,
    AppRouter.profile,
  ];

  int _calculateSelectedIndex(String location) {
    final index = _tabs.indexWhere((route) => location.startsWith(route));
    return index < 0 ? 0 : index;
  }

  void _onTabSelected(BuildContext context, int index, int currentIndex) {
    if (index != currentIndex) {
      context.go(_tabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => _onTabSelected(context, index, currentIndex),
      ),
    );
  }
}
