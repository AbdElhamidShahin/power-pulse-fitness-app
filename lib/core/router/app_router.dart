import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/shell/main_shell.dart';

abstract class AppRouter {
  AppRouter._();

  // ─── Route Names ──────────────────────────────────────────
  static const String onboarding    = '/onboarding';
  static const String home          = '/home';
  static const String exercises     = '/exercises';
  static const String exerciseDetail= '/exercises/:id';
  static const String nutrition     = '/nutrition';
  static const String progress      = '/progress';
  static const String profile       = '/profile';

  // ─── Router ───────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const _PlaceholderScreen(label: 'الرئيسية'),
          ),
          GoRoute(
            path: exercises,
            name: 'exercises',
            builder: (context, state) => const _PlaceholderScreen(label: 'التمارين'),
            routes: [
              GoRoute(
                path: ':id',
                name: 'exerciseDetail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _PlaceholderScreen(label: 'تفاصيل التمرين $id');
                },
              ),
            ],
          ),
          GoRoute(
            path: nutrition,
            name: 'nutrition',
            builder: (context, state) => const _PlaceholderScreen(label: 'التغذية'),
          ),
          GoRoute(
            path: progress,
            name: 'progress',
            builder: (context, state) => const _PlaceholderScreen(label: 'تقدمي'),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const _PlaceholderScreen(label: 'حسابي'),
          ),
        ],
      ),

      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const _PlaceholderScreen(label: 'Onboarding'),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير موجودة\n${state.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
      ),
    ),
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFFBFFF00),
          ),
        ),
      ),
    );
  }
}
