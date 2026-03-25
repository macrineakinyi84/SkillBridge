import 'package:flutter/material.dart';

/// SkillBridge spacing scale (4pt base grid). Use for padding/margins.
/// See docs/UI_DESIGN.md.
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

  /// Minimum touch target 48dp per PDR 4.3 / WCAG. Use for list row min height, button height, etc.
  static const double minTouchTarget = 48;
}
