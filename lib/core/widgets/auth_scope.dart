import 'package:flutter/material.dart';
import '../../features/auth/presentation/state/auth_notifier.dart';

class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.authNotifier,
    required super.child,
  });

  final AuthNotifier authNotifier;

  static AuthNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found. Wrap app with AuthScope.');
    return scope!.authNotifier;
  }

  static AuthNotifier? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    return scope?.authNotifier;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      oldWidget.authNotifier != authNotifier;
}
