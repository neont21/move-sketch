import 'package:flutter/material.dart';

class MoveSketchTheme {
  static const Color brand300 = Color(0xFFEC6E38);
  static const Color brand400 = Color(0xFFDD4814);
  static const Color brand500 = Color(0xFFAE3000);
  static const Color brandTint16 = Color(0xFFD54100);

  static const Color jogging = Color(0xFF599940);
  static const Color joggingInk = Color(0xFF2D6121);
  static const Color joggingFill = Color(0x2E599940);

  static const Color riding = Color(0xFF8864C0);
  static const Color ridingInk = Color(0xFF643B9A);
  static const Color ridingFill = Color(0x298864C0);

  static const Color navy = Color(0xFF3A4A7A);
  static const Color brickRed = Color(0xFFB23B1A);

  static const Color paperBackground = Color(0xFFFBF7F2);
  static const Color paperSurface = Colors.white;
  static const Color paperTint = Color(0xFFF0E7DC);

  static const Color ink = Color(0xFF1F1B19);
  static const Color inkMuted = Color(0xFF4A423D);
  static const Color inkFaint = Color(0xFF8A7D73);

  static const Color border = Color(0xFFEAE3DA);
  static const Color borderStrong = Color(0xFFDDD2C5);

  static const Color dim = Color(0x80000000);

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
        tertiary: ink,
        tertiaryFixed: inkMuted,
        tertiaryContainer: inkFaint,
        surface: paperSurface,
        surfaceDim: dim,
        secondaryContainer: paperBackground,
        onSurface: brand500,
        outline: border,
        outlineVariant: borderStrong,
        error: brickRed,
      ),
      fontFamily: 'NotoSansKR',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: 'NanumHandWriting',
          color: navy,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'NanumHandWriting',
          color: navy,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'NanumHandWriting',
          color: navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: navy,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: navy,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: inkFaint,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: inkFaint,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paperBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: brand400,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        centerTitle: false,
      ),
      focusColor: brand400.withValues(alpha: 0.12),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand400,
          foregroundColor: Colors.white,
          disabledBackgroundColor: paperTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
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