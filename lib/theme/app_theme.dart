import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _background = Color(0xFF0D1B2A);
  static const _surface = Color(0xFF1B263B);
  static const _primary = Color(0xFF4CC9F0);
  static const _secondary = Color(0xFF415A77);
  static const _onSurface = Color(0xFFE0E1DD);

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      onSurface: _onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _background,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _secondary,
        contentTextStyle: const TextStyle(color: _onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
