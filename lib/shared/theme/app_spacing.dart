import 'package:flutter/material.dart';

// Single 4pt-based scale so layout is predictable and we avoid one-off values;
// see docs/UI_DESIGN.md and docs/UI_SYSTEM.md.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  static const EdgeInsets sectionGap = EdgeInsets.only(top: xl);
  static const double minTouchTarget = 48;
  /// Extra bottom padding when a FAB is shown so content doesn't sit under it.
  static const double bottomPaddingWithFab = 88;
  /// Vertical gap between major sections on scrollable screens.
  static const double sectionVerticalGap = 20;
}
