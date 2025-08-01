import 'package:flutter/material.dart';

/// Service for handling navigation throughout the app.
///
/// Provides a centralized way to navigate between screens
/// without requiring BuildContext in non-widget classes.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get the current navigator state.
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  /// Push a new route and replace the current one.
  static Future<T?> pushReplacement<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushReplacementNamed<T, Object?>(
      routeName,
      arguments: arguments,
    );
  }
  
  /// Push a new route onto the navigation stack.
  static Future<T?> push<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
  
  /// Pop the current route from the navigation stack.
  static void pop<T extends Object?>([T? result]) {
    return navigator!.pop<T>(result);
  }
  
  /// Push a new route and clear the entire navigation stack.
  static Future<T?> pushAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Check if we can pop the current route.
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }
  
  /// Pop until a specific route is reached.
  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }
}
