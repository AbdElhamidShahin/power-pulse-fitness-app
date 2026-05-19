import 'package:flutter/material.dart';

/// Navigation helpers.
///
/// The original codebase had identical PageRouteBuilder + transition logic
/// copy-pasted in at least 4 places:
///   • custom_text_feild.dart
///   • ToolsScreen.dart
///   • costom_bosh.dart
///
/// Centralised here so any future tweak applies everywhere.
class NavigationUtils {
  NavigationUtils._();

  /// Fade + scale transition — used for top-level section navigation.
  static Route<T> fadeScaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        final scale = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  /// Slide-from-right + fade transition — used for exercise detail pages.
  static Route<T> slideRightRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fade = CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }
}
