import 'package:flutter/foundation.dart';

import '../enums/activity_type.dart';
import '../enums/sketch_slot.dart';
import 'sketch_part.dart';

/// 슬롯별 파츠 조합, 의상 틴트 색상 및 최종 합성 이미지 경로를 관리하는 불변 모델입니다.
@immutable
class SketchComposition {
  /// 각 슬롯에 장착된 스케치 파츠 맵.
  final Map<SketchSlot, SketchPart> parts;
  /// 슬롯별 적용된 틴트 색상(ARGB 정수값) 맵.
  final Map<SketchSlot, int> tintColors;
  /// 합성 렌더링 완료 후 로컬에 저장된 이미지 파일의 경로.
  final String? imagePath;

  const SketchComposition({
    required this.parts,
    this.tintColors = const {},
    this.imagePath,
  });

  /// 파츠들을 Z-인덱스 오름차순으로 정렬하여 반환합니다.
  List<SketchPart> get orderedParts {
    final list = parts.values.toList();
    list.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'parts': parts.map(
        (key, value) => MapEntry(key.name, {
          'id': value.id,
          'slot': value.slot.name,
          'tier': value.tier,
          'name': value.name,
          'assetPath': value.assetPath,
          'supportsTint': value.supportsTint,
          'defaultColorValue': value.defaultColorValue,
          'activityType': value.activityType?.name,
        }),
      ),
      'tintColors': tintColors.map((key, value) => MapEntry(key.name, value)),
      'imagePath': imagePath,
    };
  }

  factory SketchComposition.fromMap(Map<String, dynamic> map) {
    final rawParts = (map['parts'] as Map?)?.cast<String, dynamic>() ?? {};
    final parsedParts = <SketchSlot, SketchPart>{};
    for (final entry in rawParts.entries) {
      final slot = SketchSlot.fromString(entry.key);
      if (entry.value is! Map) continue;
      final partMap = entry.value as Map<String, dynamic>;
      parsedParts[slot] = SketchPart(
        id: partMap['id'] as String,
        slot: slot,
        tier: (partMap['tier'] as num?)?.toInt() ?? 0,
        name: partMap['name'] as String? ?? '',
        assetPath: partMap['assetPath'] as String,
        supportsTint: partMap['supportsTint'] as bool? ?? false,
        defaultColorValue: (partMap['defaultColorValue'] as num?)?.toInt(),
        activityType: partMap['activityType'] != null
            ? ActivityType.fromString(partMap['activityType'] as String?)
            : null,
      );
    }
    final rawTints = (map['tintColors'] as Map?)?.cast<String, dynamic>() ?? {};
    final parsedTints = <SketchSlot, int>{};
    for (final entry in rawTints.entries) {
      final slot = SketchSlot.fromString(entry.key);
      parsedTints[slot] = (entry.value as num).toInt();
    }
    return SketchComposition(
      parts: parsedParts,
      tintColors: parsedTints,
      imagePath: map['imagePath'] as String?,
    );
  }

  SketchComposition copyWith({
    Map<SketchSlot, SketchPart>? parts,
    Map<SketchSlot, int>? tintColors,
    String? imagePath,
  }) {
    return SketchComposition(
      parts: parts ?? this.parts,
      tintColors: tintColors ?? this.tintColors,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SketchComposition &&
          runtimeType == other.runtimeType &&
          imagePath == other.imagePath &&
          mapEquals(parts, other.parts) &&
          mapEquals(tintColors, other.tintColors);

  @override
  int get hashCode => Object.hash(
    imagePath,
    Object.hashAllUnordered(parts.entries),
    Object.hashAllUnordered(tintColors.entries),
  );
}
