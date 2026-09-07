import 'package:flutter/material.dart';

class MoveSketchTheme {
  static const Color brand300 = Color(0xFFEC6E38);
  static const Color brand400 = Color(0xFFDD4814);
  static const Color brand500 = Color(0xFFAE3000);
  static const Color brandTint16 = Color(0xFFD54100);

  static const Color jogging = Color(0xFF599940);
  static const Color joggingText = Color(0xFF2D6121);

  static const Color riding = Color(0xFF8864C0);
  static const Color ridingText = Color(0xFF643B9A);

  static const Color navy = Color(0xFF3A4A7A);
  static const Color brickRed = Color(0xFFB23B1A);

  static const Color paperBackground = Color(0xFFFBF7F2);
  static const Color paperSurface = Colors.white;
  static const Color paperTint = Color(0xFFF0E7DC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: paperBackground,
      colorScheme: const ColorScheme.light(
        primary: brand400,
        onPrimary: Colors.white,
        primaryContainer: brandTint16,
        secondary: navy,
        surface: paperSurface,
        onSurface: brand500,
        error: brickRed,
      ),
      fontFamily: 'NotoSansKR',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: brand500,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: brand500,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: brand500,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: navy,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paperBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: brand500,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: brand500,
        ),
      ),
      focusColor: brand400.withValues(alpha: 0.12),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand400,
          foregroundColor: Colors.white,
          disabledBackgroundColor: paperTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brand500,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}