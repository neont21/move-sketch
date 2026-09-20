import 'dart:math';
import 'package:flutter/foundation.dart';
import '../enums/character_type.dart';
import '../enums/sketch_slot.dart';

@immutable
class SketchPart {
  final String id;
  final SketchSlot slot;
  final int tier;
  final String name;
  final String assetPath;
  final bool supportsTint;
  final int? defaultColorValue;

  const SketchPart({
    required this.id,
    required this.slot,
    required this.name,
    required this.assetPath,
    this.tier = 0,
    this.supportsTint = false,
    this.defaultColorValue,
  });

  int get zIndex => slot.zIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SketchPart && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SketchComposition {
  final Map<SketchSlot, SketchPart> parts;
  final Map<SketchSlot, int> tintColors;
  final String? imagePath;

  const SketchComposition({
    required this.parts,
    this.tintColors = const {},
    this.imagePath,
  });

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
        }),
      ),
      'tintColors': tintColors.map((key, value) => MapEntry(key.name, value)),
      'imagePath': imagePath,
    };
  }

  factory SketchComposition.fromMap(Map<String, dynamic> map) {
    final rawParts = map['parts'] as Map<String, dynamic>? ?? {};
    final parsedParts = <SketchSlot, SketchPart>{};
    for (final entry in rawParts.entries) {
      final slot = SketchSlot.fromString(entry.key);
      final p = entry.value as Map<String, dynamic>;
      parsedParts[slot] = SketchPart(
        id: p['id'] as String,
        slot: slot,
        tier: (p['tier'] as num?)?.toInt() ?? 0,
        name: p['name'] as String? ?? '',
        assetPath: p['assetPath'] as String,
        supportsTint: p['supportsTint'] as bool? ?? false,
        defaultColorValue: (p['defaultColorValue'] as num?)?.toInt(),
      );
    }
    final rawTints = map['tintColors'] as Map<String, dynamic>? ?? {};
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

@immutable
class SketchPartsCatalog {
  const SketchPartsCatalog._();

  static final Random _random = Random();

  static const SketchPart defaultBackground = SketchPart(
    id: 'bg_default',
    slot: SketchSlot.background,
    name: '동네 길거리',
    assetPath: 'assets/sample_sketch.png',
  );

  static final List<SketchPart> allParts = [
    ...CharacterType.values.map((c) => c.toSketchPart()),
    defaultBackground,

    const SketchPart(
      id: 'bg_park_day',
      slot: SketchSlot.background,
      tier: 1,
      name: '햇살 가득한 공원',
      assetPath: 'assets/sketch_parts/bg_park_day.png',
    ),
    const SketchPart(
      id: 'bg_river_sunset',
      slot: SketchSlot.background,
      tier: 2,
      name: '노을 지는 강변',
      assetPath: 'assets/sketch_parts/bg_river_sunset.png',
    ),
    const SketchPart(
      id: 'bg_city_night',
      slot: SketchSlot.background,
      tier: 3,
      name: '반짝이는 도심 야경',
      assetPath: 'assets/sketch_parts/bg_city_night.png',
    ),
    const SketchPart(
      id: 'bg_hangang_track',
      slot: SketchSlot.background,
      tier: 1,
      name: '한강 자전거길',
      assetPath: 'assets/sketch_parts/bg_hangang_track.png',
    ),
    const SketchPart(
      id: 'bg_coastal_road',
      slot: SketchSlot.background,
      tier: 2,
      name: '시원한 해안 도로',
      assetPath: 'assets/sketch_parts/bg_coastal_road.png',
    ),
    const SketchPart(
      id: 'bg_mountain_pass',
      slot: SketchSlot.background,
      tier: 3,
      name: '도전적인 업힐 고갯길',
      assetPath: 'assets/sketch_parts/bg_mountain_pass.png',
    ),

    const SketchPart(
      id: 'expr_smile',
      slot: SketchSlot.expression,
      tier: 1,
      name: '가벼운 미소',
      assetPath: 'assets/sketch_parts/expr_smile.png',
    ),
    const SketchPart(
      id: 'expr_energetic',
      slot: SketchSlot.expression,
      tier: 2,
      name: '활기찬 표정',
      assetPath: 'assets/sketch_parts/expr_energetic.png',
    ),
    const SketchPart(
      id: 'expr_proud',
      slot: SketchSlot.expression,
      tier: 3,
      name: '뿌듯한 표정',
      assetPath: 'assets/sketch_parts/expr_proud.png',
    ),
    const SketchPart(
      id: 'expr_relaxed',
      slot: SketchSlot.expression,
      tier: 1,
      name: '여유로운 표정',
      assetPath: 'assets/sketch_parts/expr_relaxed.png',
    ),
    const SketchPart(
      id: 'expr_confident',
      slot: SketchSlot.expression,
      tier: 2,
      name: '자신만만한 표정',
      assetPath: 'assets/sketch_parts/expr_confident.png',
    ),
    const SketchPart(
      id: 'expr_thrilled',
      slot: SketchSlot.expression,
      tier: 3,
      name: '짜릿한 표정',
      assetPath: 'assets/sketch_parts/expr_thrilled.png',
    ),

    const SketchPart(
      id: 'costume_sport_t1',
      slot: SketchSlot.costume,
      tier: 1,
      name: '베이직 러닝 웨어',
      assetPath: 'assets/sketch_parts/costume_sport_t1.png',
      supportsTint: true,
    ),
    const SketchPart(
      id: 'costume_sport_t2',
      slot: SketchSlot.costume,
      tier: 2,
      name: '프로 러너 셋업',
      assetPath: 'assets/sketch_parts/costume_sport_t2.png',
      supportsTint: true,
    ),
    const SketchPart(
      id: 'costume_sport_t3',
      slot: SketchSlot.costume,
      tier: 3,
      name: '챔피언 윈드브레이커',
      assetPath: 'assets/sketch_parts/costume_sport_t3.png',
      supportsTint: true,
    ),
    const SketchPart(
      id: 'costume_jersey_t1',
      slot: SketchSlot.costume,
      tier: 1,
      name: '에어로 사이클 저지',
      assetPath: 'assets/sketch_parts/costume_jersey_t1.png',
      supportsTint: true,
    ),
    const SketchPart(
      id: 'costume_jersey_t2',
      slot: SketchSlot.costume,
      tier: 2,
      name: '투어링 슈트',
      assetPath: 'assets/sketch_parts/costume_jersey_t2.png',
      supportsTint: true,
    ),
    const SketchPart(
      id: 'costume_jersey_t3',
      slot: SketchSlot.costume,
      tier: 3,
      name: '마스터 빕숏 & 저지',
      assetPath: 'assets/sketch_parts/costume_jersey_t3.png',
      supportsTint: true,
    ),

    const SketchPart(
      id: 'prop_water_bottle',
      slot: SketchSlot.prop,
      tier: 1,
      name: '스포츠 물병',
      assetPath: 'assets/sketch_parts/prop_water_bottle.png',
    ),
    const SketchPart(
      id: 'prop_camera',
      slot: SketchSlot.prop,
      tier: 2,
      name: '미니 액션캠',
      assetPath: 'assets/sketch_parts/prop_camera.png',
    ),
    const SketchPart(
      id: 'prop_explorer_flag',
      slot: SketchSlot.prop,
      tier: 3,
      name: '탐험가의 깃발',
      assetPath: 'assets/sketch_parts/prop_explorer_flag.png',
    ),
    const SketchPart(
      id: 'prop_helmet_light',
      slot: SketchSlot.prop,
      tier: 1,
      name: '안전 헬멧 라이트',
      assetPath: 'assets/sketch_parts/prop_helmet_light.png',
    ),
    const SketchPart(
      id: 'prop_cyclocomputer',
      slot: SketchSlot.prop,
      tier: 2,
      name: '스마트 사이클링 컴퓨터',
      assetPath: 'assets/sketch_parts/prop_cyclocomputer.png',
    ),
    const SketchPart(
      id: 'prop_pannier_bag',
      slot: SketchSlot.prop,
      tier: 3,
      name: '투어링 패니어 백',
      assetPath: 'assets/sketch_parts/prop_pannier_bag.png',
    ),

    const SketchPart(
      id: 'effect_breeze',
      slot: SketchSlot.effect,
      tier: 1,
      name: '산들바람',
      assetPath: 'assets/sketch_parts/effect_breeze.png',
    ),
    const SketchPart(
      id: 'effect_sparkle',
      slot: SketchSlot.effect,
      tier: 2,
      name: '반짝이는 땀방울',
      assetPath: 'assets/sketch_parts/effect_sparkle.png',
    ),
    const SketchPart(
      id: 'effect_fire_boost',
      slot: SketchSlot.effect,
      tier: 3,
      name: '버스트 불꽃',
      assetPath: 'assets/sketch_parts/effect_fire_boost.png',
    ),
    const SketchPart(
      id: 'effect_wind_lines',
      slot: SketchSlot.effect,
      tier: 1,
      name: '스피드 바람선',
      assetPath: 'assets/sketch_parts/effect_wind_lines.png',
    ),
    const SketchPart(
      id: 'effect_lightning_trail',
      slot: SketchSlot.effect,
      tier: 2,
      name: '번개 잔상 트레일',
      assetPath: 'assets/sketch_parts/effect_lightning_trail.png',
    ),
    const SketchPart(
      id: 'effect_supersonic',
      slot: SketchSlot.effect,
      tier: 3,
      name: '초음속 충격파',
      assetPath: 'assets/sketch_parts/effect_supersonic.png',
    ),
  ];
  static SketchPart? findById(String id) {
    try {
      return allParts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static SketchPart? getPartForSlotAndTier(SketchSlot slot, int tier) {
    final candidates = allParts
        .where((p) => p.slot == slot && p.tier == tier)
        .toList();
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;
    return candidates[_random.nextInt(candidates.length)];
  }

  static SketchPart getCharacterPart(String? characterId) {
    return CharacterType.fromString(characterId).toSketchPart();
  }
}
