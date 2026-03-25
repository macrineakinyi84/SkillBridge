import 'package:flutter/material.dart';

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double full = 9999;

  static BorderRadius get radiusS => BorderRadius.circular(s);
  static BorderRadius get radiusM => BorderRadius.circular(m);
  static BorderRadius get radiusL => BorderRadius.circular(l);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
}
