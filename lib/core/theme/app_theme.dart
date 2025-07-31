// Flutter imports:
import 'package:flutter/material.dart';

/// App theme configuration for Snakes Fight
class AppTheme {
  // Primary colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryGreen = Color(0xFF81C784);
  static const Color accentColor = Color(0xFFFF5722);
  
  // Game colors
  static const Color snakeColor = Color(0xFF2E7D32);
  static const Color foodColor = Color(0xFFFF5722);
  static const Color backgroundGame = Color(0xFF1B5E20);
  
  // UI colors
  static const Color surface = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color error = Color(0xFFD32F2F);
  
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
