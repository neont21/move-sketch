import 'package:flutter/foundation.dart';
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
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
