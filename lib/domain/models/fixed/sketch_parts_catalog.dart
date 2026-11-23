import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../config/assets.dart';
import '../enums/activity_type.dart';
import '../enums/character_type.dart';
import '../enums/sketch_slot.dart';
import 'sketch_part.dart';

/// 앱에 등록된 모든 스케치 파츠 에셋 목록과 슬롯/티어별 파츠 조회 유틸리티를 제공하는 카탈로그 클래스입니다.
@immutable
class SketchPartsCatalog {
  const SketchPartsCatalog._();

  static final Random _random = Random();

  /// 의상 파츠에 무작위로 적용할 수 있는 8가지 기본 색상(ARGB) 팔레트.
  static const List<int> costumeTintPalette = [
    0xFFEF4444,
    0xFFF97316,
    0xFFF59E0B,
    0xFF10B981,
    0xFF06B6D4,
    0xFF3B82F6,
    0xFF8B5CF6,
    0xFFEC4899,
  ];

  /// 의상 색상 팔레트에서 임의의 색상값을 추첨하여 반환합니다.
  static int getRandomCostumeTint() {
    return costumeTintPalette[_random.nextInt(costumeTintPalette.length)];
  }

  /// 미션 달성 이전의 기본 배경 파츠.
  static const SketchPart defaultBackground = SketchPart(
    id: 'bg_default',
    slot: SketchSlot.background,
    name: '동네 길거리',
    assetPath: Assets.bgDefault,
  );

  /// 미션 달성 이전의 기본 표정 파츠.
  static const SketchPart defaultExpression = SketchPart(
    id: 'expr_default',
    slot: SketchSlot.expression,
    name: '기본 표정',
    assetPath: Assets.exprDefault,
  );

  /// 시스템에 등록된 전체 스케치 파츠 목록.
  static final List<SketchPart> allParts = [
    ...CharacterType.values.map((character) => character.toSketchPart()),
    defaultBackground,

    const SketchPart(
      id: 'bg_park_day',
      slot: SketchSlot.background,
      tier: 1,
      name: '햇살 가득한 공원',
      assetPath: Assets.bgParkDay,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'bg_river_sunset',
      slot: SketchSlot.background,
      tier: 2,
      name: '노을 지는 강변',
      assetPath: Assets.bgRiverSunset,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'bg_city_night',
      slot: SketchSlot.background,
      tier: 3,
      name: '반짝이는 도심 야경',
      assetPath: Assets.bgCityNight,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'bg_hangang_track',
      slot: SketchSlot.background,
      tier: 1,
      name: '한강 자전거길',
      assetPath: Assets.bgHangangTrack,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'bg_coastal_road',
      slot: SketchSlot.background,
      tier: 2,
      name: '시원한 해안 도로',
      assetPath: Assets.bgCoastalRoad,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'bg_mountain_pass',
      slot: SketchSlot.background,
      tier: 3,
      name: '도전적인 업힐 고갯길',
      assetPath: Assets.bgMountainPass,
      activityType: ActivityType.riding,
    ),

    const SketchPart(
      id: 'expr_smile',
      slot: SketchSlot.expression,
      tier: 1,
      name: '가벼운 미소',
      assetPath: Assets.exprSmile,
    ),
    const SketchPart(
      id: 'expr_energetic',
      slot: SketchSlot.expression,
      tier: 2,
      name: '활기찬 표정',
      assetPath: Assets.exprEnergetic,
    ),
    const SketchPart(
      id: 'expr_proud',
      slot: SketchSlot.expression,
      tier: 3,
      name: '뿌듯한 표정',
      assetPath: Assets.exprProud,
    ),
    const SketchPart(
      id: 'expr_relaxed',
      slot: SketchSlot.expression,
      tier: 1,
      name: '여유로운 표정',
      assetPath: Assets.exprRelaxed,
    ),
    const SketchPart(
      id: 'expr_confident',
      slot: SketchSlot.expression,
      tier: 2,
      name: '자신만만한 표정',
      assetPath: Assets.exprConfident,
    ),
    const SketchPart(
      id: 'expr_thrilled',
      slot: SketchSlot.expression,
      tier: 3,
      name: '짜릿한 표정',
      assetPath: Assets.exprThrilled,
    ),

    const SketchPart(
      id: 'costume_sport_t1',
      slot: SketchSlot.costume,
      tier: 1,
      name: '베이직 러닝 웨어',
      assetPath: Assets.costumeSportT1,
      supportsTint: true,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'costume_sport_t2',
      slot: SketchSlot.costume,
      tier: 2,
      name: '프로 러너 셋업',
      assetPath: Assets.costumeSportT2,
      supportsTint: true,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'costume_sport_t3',
      slot: SketchSlot.costume,
      tier: 3,
      name: '챔피언 윈드브레이커',
      assetPath: Assets.costumeSportT3,
      supportsTint: true,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'costume_jersey_t1',
      slot: SketchSlot.costume,
      tier: 1,
      name: '에어로 사이클 저지',
      assetPath: Assets.costumeJerseyT1,
      supportsTint: true,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'costume_jersey_t2',
      slot: SketchSlot.costume,
      tier: 2,
      name: '투어링 슈트',
      assetPath: Assets.costumeJerseyT2,
      supportsTint: true,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'costume_jersey_t3',
      slot: SketchSlot.costume,
      tier: 3,
      name: '마스터 빕숏 & 저지',
      assetPath: Assets.costumeJerseyT3,
      supportsTint: true,
      activityType: ActivityType.riding,
    ),

    const SketchPart(
      id: 'prop_water_bottle',
      slot: SketchSlot.prop,
      tier: 1,
      name: '스포츠 물병',
      assetPath: Assets.propWaterBottle,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'prop_camera',
      slot: SketchSlot.prop,
      tier: 2,
      name: '미니 액션캠',
      assetPath: Assets.propCamera,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'prop_explorer_flag',
      slot: SketchSlot.prop,
      tier: 3,
      name: '탐험가의 깃발',
      assetPath: Assets.propExplorerFlag,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'prop_helmet_light',
      slot: SketchSlot.prop,
      tier: 1,
      name: '안전 헬멧 라이트',
      assetPath: Assets.propHelmetLight,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'prop_cyclocomputer',
      slot: SketchSlot.prop,
      tier: 2,
      name: '스마트 사이클링 컴퓨터',
      assetPath: Assets.propCyclocomputer,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'prop_pannier_bag',
      slot: SketchSlot.prop,
      tier: 3,
      name: '투어링 패니어 백',
      assetPath: Assets.propPannierBag,
      activityType: ActivityType.riding,
    ),

    const SketchPart(
      id: 'effect_breeze',
      slot: SketchSlot.effect,
      tier: 1,
      name: '산들바람',
      assetPath: Assets.effectBreeze,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'effect_sparkle',
      slot: SketchSlot.effect,
      tier: 2,
      name: '반짝이는 땀방울',
      assetPath: Assets.effectSparkle,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'effect_fire_boost',
      slot: SketchSlot.effect,
      tier: 3,
      name: '버스트 불꽃',
      assetPath: Assets.effectFireBoost,
      activityType: ActivityType.jogging,
    ),
    const SketchPart(
      id: 'effect_wind_lines',
      slot: SketchSlot.effect,
      tier: 1,
      name: '스피드 바람선',
      assetPath: Assets.effectWindLines,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'effect_lightning_trail',
      slot: SketchSlot.effect,
      tier: 2,
      name: '번개 잔상 트레일',
      assetPath: Assets.effectLightningTrail,
      activityType: ActivityType.riding,
    ),
    const SketchPart(
      id: 'effect_supersonic',
      slot: SketchSlot.effect,
      tier: 3,
      name: '초음속 충격파',
      assetPath: Assets.effectSupersonic,
      activityType: ActivityType.riding,
    ),
  ];

  /// 파츠 식별자 [id]와 일치하는 [SketchPart]를 검색하여 반환하며, 없는 경우 null을 반환합니다.
  static SketchPart? findById(String id) {
    try {
      return allParts.firstWhere((part) => part.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 지정된 레이어 [slot], 달성 [tier], [activityType] 조건에 부합하는 파츠를 선별하여 반환합니다.
  ///
  /// 매칭되는 후보가 2개 이상인 경우 무작위로 하나를 선정하여 반환하며, 없으면 null을 반환합니다.
  static SketchPart? getPartForSlotAndTier({
    required SketchSlot slot,
    required int tier,
    ActivityType? activityType,}
  ) {
    final candidates = allParts
        .where(
          (part) =>
              part.slot == slot &&
              part.tier == tier &&
              (activityType == null ||
                  part.activityType == null ||
                  part.activityType == activityType),
        )
        .toList();
    if (candidates.isEmpty) {
      return null;
    }
    if (candidates.length == 1) {
      return candidates.first;
    }
    return candidates[_random.nextInt(candidates.length)];
  }

  /// 캐릭터 식별자 문자열 [characterId]에 대응하는 캐릭터 베이스 [SketchPart]를 반환합니다.
  static SketchPart getCharacterPart(String? characterId) {
    return CharacterType.fromString(characterId).toSketchPart();
  }
}
