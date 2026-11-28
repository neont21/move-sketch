import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'activity_colors.dart';

/// MoveSketch 앱의 브랜드 컬러 팔레트와 Material 3 [ThemeData]를 정의하는 테마 클래스입니다.
abstract final class MoveSketchTheme {
  /// 보조 강조 및 컨테이너용 밝은 브랜드 오렌지 색상.
  static const Color brand300 = Color(0xFFEC6E38);

  /// 기본 브랜드 메인 오렌지 색상.
  static const Color brand400 = Color(0xFFDD4814);

  /// 눌림·강조 상태용 진한 브랜드 오렌지 색상.
  static const Color brand500 = Color(0xFFAE3000);

  /// 브랜드 오렌지 틴트 강조 색상.
  static const Color brandTint16 = Color(0xFFD54100);

  /// 손글씨 제목·라벨 등에 사용하는 보조 네이비 색상.
  static const Color navy = Color(0xFF3A4A7A);

  /// 오류 및 경고 상태용 브릭 레드 색상.
  static const Color brickRed = Color(0xFFB23B1A);

  /// 종이 질감의 기본 스캐폴드 배경 색상.
  static const Color paperBackground = Color(0xFFFBF7F2);

  /// 카드 및 입력 필드 표면 색상.
  static const Color paperSurface = Colors.white;

  /// 비활성·보조 컨테이너용 따뜻한 틴트 배경 색상.
  static const Color paperTint = Color(0xFFF0E7DC);

  /// 기본 본문 및 제목용 진한 잉크 색상.
  static const Color ink = Color(0xFF1F1B19);

  /// 보조 설명 텍스트용 중간 톤 잉크 색상.
  static const Color inkMuted = Color(0xFF4A423D);

  /// 캡션·플레이스홀더용 연한 잉크 색상.
  static const Color inkFaint = Color(0xFF8A7D73);

  /// 기본 테두리 색상.
  static const Color border = Color(0xFFEAE3DA);

  /// 강조된 구분선 및 테두리 색상.
  static const Color borderStrong = Color(0xFFDDD2C5);

  /// 모달·오버레이용 반투명 딤 색상.
  static const Color dim = Color(0x80000000);

  /// 앱 전역에 적용되는 라이트 모드 Material 3 [ThemeData].
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: paperBackground,
      colorScheme: const ColorScheme.light(
        primary: brand400,
        onPrimary: Colors.white,
        primaryContainer: brand300,
        secondary: navy,
        secondaryContainer: paperTint,
        tertiary: ink,
        tertiaryFixed: inkMuted,
        tertiaryContainer: inkFaint,
        surface: paperSurface,
        surfaceDim: dim,
        surfaceContainer: paperBackground,
        onSurface: ink,
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
          letterSpacing: -0.2,
          color: navy,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: -0.2,
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
        foregroundColor: ink,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        centerTitle: false,
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) => const Icon(Icons.chevron_left),
      ),
      focusColor: brand400.withValues(alpha: 0.12),
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: brand400, size: 24);
          }
          return const IconThemeData(color: inkFaint, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: brand400,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: inkFaint,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperSurface,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: border),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
          borderRadius: BorderRadius.circular(20),
        ),
        counterStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: inkFaint,
        ),
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: navy,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: inkFaint,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: const BoxConstraints(maxWidth: 480),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand400,
          foregroundColor: Colors.white,
          disabledBackgroundColor: paperTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inkFaint,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: const [ActivityColors.light],
    );
  }
}
