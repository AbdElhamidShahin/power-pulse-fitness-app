import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

/// MainShell — الغلاف الأساسي
/// ⚠️ ترتيب الـ routes يطابق ترتيب JSX NAV بالظبط:
/// JSX NAV: [profile, progress, nutrition, workout, home]
/// index:       0        1          2         3       4
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  // ✅ نفس ترتيب JSX: profile | progress | nutrition | exercises | home
  static const _routes = [
    AppRouter.profile,    // 0 — حسابي  (👤)
    AppRouter.progress,   // 1 — تقدمي   (📈)
    AppRouter.nutrition,  // 2 — التغذية (🥗)
    AppRouter.exercises,  // 3 — التمارين(🏋️)
    AppRouter.home,       // 4 — الرئيسية(🏠)
  ];

  int _indexFromLocation(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _routes.length; i++) {
      if (path.startsWith(_routes[i])) return i;
    }
    return 4; // الرئيسية افتراضياً
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFromLocation(context);

    // ✅ Status bar: أيقونات داكنة (Light theme)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:     Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) {
          if (i != index) context.go(_routes[i]);
        },
      ),
    );
  }
}
