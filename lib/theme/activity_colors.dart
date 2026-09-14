import 'package:flutter/material.dart';

extension ActivityColorsBuildContext on BuildContext {
  ActivityColors get activityColors =>
      Theme.of(this).extension<ActivityColors>()!;
}

class ActivityColors extends ThemeExtension<ActivityColors> {
  final Color jogging;
  final Color joggingInk;
  final Color joggingFill;
  final Color riding;
  final Color ridingInk;
  final Color ridingFill;

  const ActivityColors({
    required this.jogging,
    required this.joggingInk,
    required this.joggingFill,
    required this.riding,
    required this.ridingInk,
    required this.ridingFill,
  });

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

