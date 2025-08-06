import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for managing application theme state
class ThemeProvider extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Load theme from shared preferences
  void _loadTheme() {
    final themeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      state = ThemeMode.values[themeIndex];
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    await _prefs.setInt(_themeKey, theme.index);
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setTheme(ThemeMode.light);
        break;
      case ThemeMode.system:
        await setTheme(ThemeMode.light);
        break;
    }
  }

  /// Set to light theme
  Future<void> setLightTheme() async {
    await setTheme(ThemeMode.light);
  }

  /// Set to dark theme
  Future<void> setDarkTheme() async {
    await setTheme(ThemeMode.dark);
  }

  /// Set to system theme
  Future<void> setSystemTheme() async {
    await setTheme(ThemeMode.system);
  }

  /// Check if current theme is light
  bool get isLight => state == ThemeMode.light;

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;

  /// Check if current theme follows system
  bool get isSystem => state == ThemeMode.system;
}

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Theme provider instance
final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ThemeProvider(prefs);
});

/// Extension for getting effective brightness
extension ThemeModeExtension on ThemeMode {
  /// Get effective brightness for the given platform brightness
  Brightness getEffectiveBrightness(Brightness platformBrightness) {
    switch (this) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return platformBrightness;
    }
  }
}
