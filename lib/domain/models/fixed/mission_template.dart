import 'package:flutter/foundation.dart';
import '../enums/activity_type.dart';
import '../enums/mission_axis.dart';
import '../enums/sketch_slot.dart';
import 'mission_tier.dart';

/// 운동 종목별 미션 평가 축, 연계 스케치 파츠 슬롯 및 단계별 티어 목록을 정의하는 불변 템플릿 모델입니다.
@immutable
class MissionTemplate {
  /// 미션 템플릿의 고유 식별자.
  final String id;
  /// 미션 성과를 측정하는 평가 축.
  final MissionAxis axis;
  /// 미션이 적용되는 운동 종목.
  final ActivityType activityType;
  /// UI에 표시할 미션 제목.
  final String title;
  /// 측정 단위 표기.
  final String unit;
  /// 미션 달성 시 보상으로 해금되는 캐릭터 스케치 레이어 슬롯.
  final SketchSlot partsSlot;
  /// 단계별 달성 기준을 정의하는 티어 목록.
  final List<MissionTier> tiers;

  const MissionTemplate({
    required this.id,
    required this.axis,
    required this.activityType,
    required this.title,
    required this.unit,
    required this.partsSlot,
    required this.tiers,
  });

  /// 사용자가 기록한 측정값 [value]에 대해 충족된 최고 등급의 [MissionTier]를 평가하여 반환합니다.
  ///
  /// 티어 목록을 난이도 순서로 정렬하여 가장 높은 기준치를 충족한 티어를 우선 반환하며,
  /// 최하위 티어 기준에도 도달하지 못한 경우 `null`을 반환합니다.
  MissionTier? evaluateTier(double value) {
    final sortedTiers = List<MissionTier>.from(tiers)
      ..sort((a, b) => axis.compareThresholds(a.threshold, b.threshold));

    for (final tier in sortedTiers) {
      if (axis.isAchieved(value: value, threshold: tier.threshold)) {
        return tier;
      }
    }
    return null;
  }

  /// 조깅 및 라이딩 종목에 기본 제공되는 사전 정의 미션 템플릿 목록.
  static final List<MissionTemplate> defaultTemplates = [
    MissionTemplate(
      id: 'jogging_distance',
      axis: MissionAxis.distance,
      activityType: ActivityType.jogging,
      title: '거리',
      unit: 'km',
      partsSlot: SketchSlot.background,
      tiers: const [
        MissionTier(tier: 1, threshold: 1.5, description: '8분 페이스 기준 약 12분'),
        MissionTier(tier: 2, threshold: 3.0, description: '8분 페이스 기준 약 24분'),
        MissionTier(tier: 3, threshold: 5.0, description: '8분 페이스 기준 약 40분'),
      ],
    ),
    MissionTemplate(
      id: 'jogging_pace',
      axis: MissionAxis.pace,
      activityType: ActivityType.jogging,
      title: '페이스',
      unit: '/km',
      partsSlot: SketchSlot.expression,
      tiers: const [
        MissionTier(tier: 1, threshold: 520.0, description: '기분 좋은 가벼운 조깅'),
        MissionTier(tier: 2, threshold: 470.0, description: '활력 넘치는 리듬 페이스'),
        MissionTier(tier: 3, threshold: 420.0, description: '시원한 질주 페이스'),
      ],
    ),
    MissionTemplate(
      id: 'jogging_duration',
      axis: MissionAxis.duration,
      activityType: ActivityType.jogging,
      title: '지속 시간',
      unit: '분',
      partsSlot: SketchSlot.costume,
      tiers: const [
        MissionTier(tier: 1, threshold: 10.0, description: '10분 이상 활동'),
        MissionTier(tier: 2, threshold: 20.0, description: '20분 이상 활동'),
        MissionTier(tier: 3, threshold: 40.0, description: '40분 이상 활동'),
      ],
    ),
    MissionTemplate(
      id: 'jogging_route',
      axis: MissionAxis.routeExploration,
      activityType: ActivityType.jogging,
      title: '경로 탐색',
      unit: 'km',
      partsSlot: SketchSlot.prop,
      tiers: const [
        MissionTier(tier: 1, threshold: 0.5, description: '새로운 길 500m 탐색'),
        MissionTier(tier: 2, threshold: 1.0, description: '새로운 길 1km 탐색'),
        MissionTier(tier: 3, threshold: 2.0, description: '새로운 길 2km 탐색'),
      ],
    ),
    MissionTemplate(
      id: 'jogging_interval',
      axis: MissionAxis.interval,
      activityType: ActivityType.jogging,
      title: '인터벌',
      unit: '회',
      partsSlot: SketchSlot.effect,
      tiers: const [
        MissionTier(tier: 1, threshold: 1.0, description: '인터벌 1회 성공'),
        MissionTier(tier: 2, threshold: 3.0, description: '인터벌 3회 성공'),
        MissionTier(tier: 3, threshold: 5.0, description: '인터벌 5회 성공'),
      ],
    ),

    MissionTemplate(
      id: 'riding_distance',
      axis: MissionAxis.distance,
      activityType: ActivityType.riding,
      title: '거리',
      unit: 'km',
      partsSlot: SketchSlot.background,
      tiers: const [
        MissionTier(tier: 1, threshold: 3.0, description: '평속 12km/h 기준 약 15분'),
        MissionTier(tier: 2, threshold: 7.0, description: '평속 12km/h 기준 약 35분'),
        MissionTier(tier: 3, threshold: 12.0, description: '평속 12km/h 기준 약 60분'),
      ],
    ),
    MissionTemplate(
      id: 'riding_speed',
      axis: MissionAxis.speed,
      activityType: ActivityType.riding,
      title: '속도',
      unit: 'km/h',
      partsSlot: SketchSlot.expression,
      tiers: const [
        MissionTier(tier: 1, threshold: 11.0, description: '평균 11km/h 순항'),
        MissionTier(tier: 2, threshold: 15.0, description: '평균 15km/h 쾌속'),
        MissionTier(tier: 3, threshold: 19.0, description: '평균 19km/h 질주'),
      ],
    ),
    MissionTemplate(
      id: 'riding_duration',
      axis: MissionAxis.duration,
      activityType: ActivityType.riding,
      title: '지속 시간',
      unit: '분',
      partsSlot: SketchSlot.costume,
      tiers: const [
        MissionTier(tier: 1, threshold: 20.0, description: '20분 이상 라이딩'),
        MissionTier(tier: 2, threshold: 30.0, description: '30분 이상 라이딩'),
        MissionTier(tier: 3, threshold: 40.0, description: '40분 이상 라이딩'),
      ],
    ),
    MissionTemplate(
      id: 'riding_route',
      axis: MissionAxis.routeExploration,
      activityType: ActivityType.riding,
      title: '경로 탐색',
      unit: 'km',
      partsSlot: SketchSlot.prop,
      tiers: const [
        MissionTier(tier: 1, threshold: 1.0, description: '새로운 길 1km 탐색'),
        MissionTier(tier: 2, threshold: 3.0, description: '새로운 길 3km 탐색'),
        MissionTier(tier: 3, threshold: 6.0, description: '새로운 길 6km 탐색'),
      ],
    ),
    MissionTemplate(
      id: 'riding_sprint',
      axis: MissionAxis.sprint,
      activityType: ActivityType.riding,
      title: '스프린트',
      unit: '회',
      partsSlot: SketchSlot.effect,
      tiers: const [
        MissionTier(tier: 1, threshold: 1.0, description: '스프린트 1회 달성'),
        MissionTier(tier: 2, threshold: 2.0, description: '스프린트 2회 달성'),
        MissionTier(tier: 3, threshold: 4.0, description: '스프린트 4회 달성'),
      ],
    ),
  ];

  /// 지정된 활동 종목([activity])에 해당하는 미션 템플릿 목록을 필터링하여 반환합니다.
  static List<MissionTemplate> getTemplatesFor(ActivityType activity) {
    return defaultTemplates
        .where((template) => template.activityType == activity)
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
