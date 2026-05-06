import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static VoidCallback? _loginRedirectHandler;

  static void registerLoginRedirectHandler(VoidCallback handler) {
    _loginRedirectHandler = handler;
  }

  static void redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loginRedirectHandler?.call();
    });
  }
}
