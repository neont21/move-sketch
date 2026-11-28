import 'package:flutter/material.dart';

/// [BuildContext]에서 [ActivityColors] 테마 확장에 간편하게 접근하기 위한 확장입니다.
extension ActivityColorsBuildContext on BuildContext {
  /// 현재 테마에 등록된 [ActivityColors] 인스턴스.
  ActivityColors get activityColors =>
      Theme.of(this).extension<ActivityColors>()!;
}

/// 운동 활동 유형별 시맨틱 색상을 정의하는 [ThemeExtension] 불변 모델입니다.
final class ActivityColors extends ThemeExtension<ActivityColors> {
  /// 조깅 대표 강조 색상.
  final Color jogging;

  /// 조깅 텍스트·아이콘용 진한 잉크 색상.
  final Color joggingInk;

  /// 조깅 배지·카드 배경용 반투명 채움 색상.
  final Color joggingFill;

  /// 라이딩 대표 강조 색상.
  final Color riding;

  /// 라이딩 텍스트·아이콘용 진한 잉크 색상.
  final Color ridingInk;

  /// 라이딩 배지·카드 배경용 반투명 채움 색상.
  final Color ridingFill;

  const ActivityColors({
    required this.jogging,
    required this.joggingInk,
    required this.joggingFill,
    required this.riding,
    required this.ridingInk,
    required this.ridingFill,
  });

  /// 라이트 테마용 기본 활동 색상 프리셋.
  static const light = ActivityColors(
    jogging: Color(0xFF599940),
    joggingInk: Color(0xFF2D6121),
    joggingFill: Color(0x2E599940),
    riding: Color(0xFF8864C0),
    ridingInk: Color(0xFF643B9A),
    ridingFill: Color(0x298864C0),
  );

  @override
  ActivityColors copyWith({
    Color? jogging,
    Color? joggingInk,
    Color? joggingFill,
    Color? riding,
    Color? ridingInk,
    Color? ridingFill,
  }) {
    return ActivityColors(
      jogging: jogging ?? this.jogging,
      joggingInk: joggingInk ?? this.joggingInk,
      joggingFill: joggingFill ?? this.joggingFill,
      riding: riding ?? this.riding,
      ridingInk: ridingInk ?? this.ridingInk,
      ridingFill: ridingFill ?? this.ridingFill,
    );
  }

  @override
  ActivityColors lerp(ThemeExtension<ActivityColors>? other, double t) {
    if (other is! ActivityColors) return this;

    return ActivityColors(
      jogging: Color.lerp(jogging, other.jogging, t)!,
      joggingInk: Color.lerp(joggingInk, other.joggingInk, t)!,
      joggingFill: Color.lerp(joggingFill, other.joggingFill, t)!,
      riding: Color.lerp(riding, other.riding, t)!,
      ridingInk: Color.lerp(ridingInk, other.ridingInk, t)!,
      ridingFill: Color.lerp(ridingFill, other.ridingFill, t)!,
    );
  }
}
