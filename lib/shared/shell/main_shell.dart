import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav.dart';
import '../../core/router/app_router.dart';


class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _routes = [
    AppRouter.home,
    AppRouter.exercises,
    AppRouter.nutrition,
    AppRouter.progress,
    AppRouter.profile,
  ];

  int _indexFromLocation(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFromLocation(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) {
          if (i != index) {
            context.go(_routes[i]);
          }
        },
      ),
    );
  }
}
