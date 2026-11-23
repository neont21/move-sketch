import 'package:flutter/foundation.dart';

import '../enums/activity_type.dart';
import '../enums/sketch_slot.dart';

/// 스케치 일러스트를 구성하는 개별 그래픽 파츠 메타데이터를 나타내는 불변 모델입니다.
@immutable
class SketchPart {
  /// 파츠의 고유 식별자.
  final String id;
  /// 파츠가 배치되는 캔버스 레이어 슬롯.
  final SketchSlot slot;
  /// 파츠가 속한 난이도 티어. (기본 파츠는 0)
  final int tier;
  /// 식별을 위한 파츠의 한국어 명칭.
  final String name;
  /// 파츠 그래픽 PNG 에셋 파일 경로.
  final String assetPath;
  /// 동적 색상 변경(Tint) 지원 여부.
  final bool supportsTint;
  /// 기본 적용 색상의 ARGB 32비트 정수값.
  final int? defaultColorValue;
  /// 특정 운동 종목 전용 파츠인 경우 해당 종목을 지정. (공용인 경우 `null`)
  final ActivityType? activityType;

  const SketchPart({
    required this.id,
    required this.slot,
    required this.name,
    required this.assetPath,
    this.tier = 0,
    this.supportsTint = false,
    this.defaultColorValue,
    this.activityType,
  });

  /// 슬롯의 Z-인덱스 렌더링 우선순위 정수값을 반환합니다.
  int get zIndex => slot.zIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SketchPart && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
