// Spacing system for Power Pulse.
// Use these values everywhere instead of hardcoded numbers.
// Named by size, not purpose — keeps things flexible.

import 'package:flutter/material.dart';

abstract class AppSpacing {
  AppSpacing._();

  // Fixed spacing values (in logical pixels)
  static const double xxs =  2.0;
  static const double xs  =  4.0;
  static const double s   =  8.0;
  static const double m   = 12.0;
  static const double l   = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double x3l = 32.0;
  static const double x4l = 40.0;
  static const double x5l = 48.0;

  // Common screen padding
  static const double screenH = 18.0; // horizontal screen padding
  static const double screenV = 16.0; // vertical screen padding

  // Reusable SizedBox gaps (saves rebuilding the same widget repeatedly)
  static const Widget gapXXS = SizedBox(height: xxs);
  static const Widget gapXS  = SizedBox(height: xs);
  static const Widget gapS   = SizedBox(height: s);
  static const Widget gapM   = SizedBox(height: m);
  static const Widget gapL   = SizedBox(height: l);
  static const Widget gapXL  = SizedBox(height: xl);
  static const Widget gapXXL = SizedBox(height: xxl);
  static const Widget gap3XL = SizedBox(height: x3l);
  static const Widget gap4XL = SizedBox(height: x4l);

  static const Widget gapWXXS = SizedBox(width: xxs);
  static const Widget gapWXS  = SizedBox(width: xs);
  static const Widget gapWS   = SizedBox(width: s);
  static const Widget gapWM   = SizedBox(width: m);
  static const Widget gapWL   = SizedBox(width: l);
  static const Widget gapWXL  = SizedBox(width: xl);

  // Common EdgeInsets presets
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: screenH,
    vertical:   screenV,
  );
  static const EdgeInsets paddingScreenH = EdgeInsets.symmetric(
    horizontal: screenH,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(l);
  static const EdgeInsets paddingCardSmall = EdgeInsets.all(m);
}
