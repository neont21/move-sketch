import 'package:flutter/foundation.dart';
import '../enums/activity_type.dart';
import '../enums/mission_axis.dart';
import '../enums/sketch_slot.dart';

@immutable
class MissionTier {
  final int tier;
  final double threshold;
  final String description;

  const MissionTier({
    required this.tier,
    required this.threshold,
    required this.description,
  });
}

@immutable
class MissionTemplate {
  final String id;
  final MissionAxis axis;
  final ActivityType activityType;
  final String title;
  final String unit;
  final SketchSlot partsSlot;
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

  static final List<MissionTemplate> defaultTemplates = [
    MissionTemplate(
      id: 'jogging_distance',
      axis: MissionAxis.distance,
      activityType: ActivityType.jogging,
      title: '거리',
      unit: 'km',
      partsSlot: SketchSlot.background,
      tiers: const [
        MissionTier(tier: 1, threshold: 2.0, description: '2km 이상 달리기'),
        MissionTier(tier: 2, threshold: 4.0, description: '4km 이상 달리기'),
        MissionTier(tier: 3, threshold: 7.0, description: '7km 이상 달리기'),
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
        MissionTier(tier: 1, threshold: 480.0, description: '기분 좋은 가벼운 조깅'),
        MissionTier(tier: 2, threshold: 420.0, description: '활력 넘치는 리듬 페이스'),
        MissionTier(tier: 3, threshold: 360.0, description: '엄청난 속도'),
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
        MissionTier(tier: 1, threshold: 5.0, description: '5km 이상 라이딩'),
        MissionTier(tier: 2, threshold: 10.0, description: '10km 이상 라이딩'),
        MissionTier(tier: 3, threshold: 20.0, description: '20km 이상 라이딩'),
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
        MissionTier(tier: 1, threshold: 15.0, description: '평균 15km/h 순항'),
        MissionTier(tier: 2, threshold: 20.0, description: '평균 20km/h 쾌속'),
        MissionTier(tier: 3, threshold: 26.0, description: '평균 26km/h 질주'),
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

  static List<MissionTemplate> getTemplatesFor(ActivityType activity) {
    return defaultTemplates
        .where(
          (t) =>
              t.activityType == activity &&
              t.axis != MissionAxis.routeExploration,
        )
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
