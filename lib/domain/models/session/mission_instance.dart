import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/local/database/app_database.dart';
import '../enums/mission_axis.dart';
import '../fixed/mission_template.dart';
import '../fixed/sketch_parts_catalog.dart';

/// 특정 운동 세션에 바인딩되어 실시간으로 진척도를 추적하는 개별 미션 실행 인스턴스를 나타내는 불변 모델입니다.
@immutable
class MissionInstance {
  /// 미션 인스턴스 고유 식별자.
  final String id;

  /// 미션이 귀속된 운동 세션의 고유 식별자.
  final String sessionId;

  /// 기반이 되는 [MissionTemplate]의 고유 식별자.
  final String missionTemplateId;

  /// 미션 성과 평가 축.
  final MissionAxis axis;

  /// 상대적 평가에 사용되는 세션 시작 기준값.
  final double? baselineValue;

  /// 현재 세션에서 누적 기록된 측정값.
  final double currentValue;

  /// 현재 측정값 기준으로 달성된 최고 티어 단계.
  final int achievedTier;

  /// 달성한 티어에 따라 보상으로 해금된 스케치 파츠 식별자.
  final String? partId;

  const MissionInstance({
    required this.id,
    required this.sessionId,
    required this.missionTemplateId,
    required this.axis,
    this.baselineValue,
    this.currentValue = 0.0,
    this.achievedTier = 0,
    this.partId,
  });

  /// 현재 측정값을 축별 단위 서식에 맞게 포맷팅한 문자열.
  String get formattedValue => axis.formatValue(currentValue);

  /// 달성한 티어 단계에 부합하는 피드백 안내 문구.
  String get tierComment {
    return switch (achievedTier) {
      1 => '무난히 해냈어요',
      2 => '충분히 해냈어요',
      3 => '완벽히 해냈어요',
      _ => '좋은 시작이에요',
    };
  }

  /// 미션 템플릿([template])을 기반으로 초기화된 신규 [MissionInstance]를 생성합니다.
  factory MissionInstance.fromTemplate({
    required MissionTemplate template,
    String? id,
    String sessionId = '',
    double? baselineValue,
  }) {
    return MissionInstance(
      id: id ?? const Uuid().v7(),
      sessionId: sessionId,
      missionTemplateId: template.id,
      axis: template.axis,
      baselineValue: baselineValue,
      currentValue: 0.0,
      achievedTier: 0,
    );
  }

  /// 갱신된 측정값([newValue])을 전달받아 달성 티어와 보상 파츠를 재평가한 새 인스턴스를 반환합니다.
  MissionInstance evaluateWith(double newValue, MissionTemplate template) {
    final tier = template.evaluateTier(newValue);
    final newTierNumber = tier?.tier ?? 0;
    final String? newPartId;

    if (newTierNumber == 0) {
      newPartId = null;
    } else if (newTierNumber == achievedTier && partId != null) {
      newPartId = partId;
    } else {
      final part = SketchPartsCatalog.getPartForSlotAndTier(
        slot: template.partsSlot,
        tier: newTierNumber,
        activityType: template.activityType,
      );
      newPartId = part?.id;
    }
    return copyWith(
      currentValue: newValue,
      achievedTier: newTierNumber,
      partId: newPartId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'missionTemplateId': missionTemplateId,
      'axis': axis.name,
      'baselineValue': baselineValue,
      'currentValue': currentValue,
      'achievedTier': achievedTier,
      'partId': partId,
    };
  }

  factory MissionInstance.fromMap(Map<String, dynamic> map) {
    return MissionInstance(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      missionTemplateId: map['missionTemplateId'] as String,
      axis: MissionAxis.fromString(map['axis'] as String?),
      baselineValue: (map['baselineValue'] as num?)?.toDouble(),
      currentValue: (map['currentValue'] as num?)?.toDouble() ?? 0.0,
      achievedTier: (map['achievedTier'] as num?)?.toInt() ?? 0,
      partId: map['partId'] as String?,
    );
  }

  /// Drift 로컬 데이터베이스의 [MissionInstancesTableData] 엔티티로부터 [MissionInstance]를 생성합니다.
  factory MissionInstance.fromEntity(MissionInstancesTableData entity) {
    return MissionInstance(
      id: entity.id,
      sessionId: entity.sessionId,
      missionTemplateId: entity.missionTemplateId,
      axis: entity.axis,
      baselineValue: entity.baselineValue,
      currentValue: entity.currentValue,
      achievedTier: entity.achievedTier,
      partId: entity.partId,
    );
  }

  MissionInstance copyWith({
    String? id,
    String? sessionId,
    String? missionTemplateId,
    MissionAxis? axis,
    double? baselineValue,
    double? currentValue,
    int? achievedTier,
    String? partId,
  }) {
    return MissionInstance(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      missionTemplateId: missionTemplateId ?? this.missionTemplateId,
      axis: axis ?? this.axis,
      baselineValue: baselineValue ?? this.baselineValue,
      currentValue: currentValue ?? this.currentValue,
      achievedTier: achievedTier ?? this.achievedTier,
      partId: partId ?? this.partId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionInstance &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          missionTemplateId == other.missionTemplateId &&
          axis == other.axis &&
          baselineValue == other.baselineValue &&
          currentValue == other.currentValue &&
          achievedTier == other.achievedTier &&
          partId == other.partId;

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    missionTemplateId,
    axis,
    baselineValue,
    currentValue,
    achievedTier,
    partId,
  );
}
