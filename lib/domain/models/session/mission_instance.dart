import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/local/database/app_database.dart';
import '../enums/mission_axis.dart';
import '../fixed/mission_template.dart';
import '../fixed/sketch_parts.dart';

@immutable
class MissionInstance {
  final String id;
  final String sessionId;
  final String missionTemplateId;
  final MissionAxis axis;
  final double? baselineValue;
  final double currentValue;
  final int achievedTier;
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

  MissionInstance evaluateWith(double newValue, MissionTemplate template) {
    final tier = template.evaluateTier(newValue);
    final achieved = tier != null;
    final part = achieved
        ? SketchPartsCatalog.getPartForSlotAndTier(
            template.partsSlot,
            tier.tier,
          )
        : null;

    return copyWith(
      currentValue: newValue,
      achievedTier: tier?.tier ?? 0,
      partId: part?.id,
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

  String get formattedValue => axis.formatValue(currentValue);

  String get tierComment {
    return switch (achievedTier) {
      1 => '무난히 해냈어요',
      2 => '충분히 해냈어요',
      3 => '완벽히 해냈어요',
      _ => '좋은 시작이에요',
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionInstance &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
