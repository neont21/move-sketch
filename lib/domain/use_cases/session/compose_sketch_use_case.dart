import '../../models/enums/character_type.dart';
import '../../models/enums/sketch_slot.dart';
import '../../models/fixed/mission_template.dart';
import '../../models/fixed/sketch_composition.dart';
import '../../models/fixed/sketch_part.dart';
import '../../models/fixed/sketch_parts_catalog.dart';
import '../../models/session/mission_instance.dart';

/// 달성된 미션 티어와 선택한 캐릭터를 조합하여 최종 [SketchComposition]을 생성하는 유즈케이스 클래스입니다.
final class ComposeSketchUseCase {
  const ComposeSketchUseCase();

  /// 미션 결과 목록([missions])과 캐릭터 종류([character])를 기반으로 레이어별 파츠와 틴트 색상을 조합합니다.
  ///
  /// 각 미션에 이미 할당된 `partId`를 우선 사용하되, 누락된 경우 템플릿과 달성 티어로 카탈로그에서 파츠를 보충합니다.
  SketchComposition execute({
    required List<MissionInstance> missions,
    required CharacterType character,
  }) {
    final characterPart = character.toSketchPart();
    final parts = <SketchSlot, SketchPart>{
      SketchSlot.character: characterPart,
      SketchSlot.background: SketchPartsCatalog.defaultBackground,
      SketchSlot.expression: SketchPartsCatalog.defaultExpression,
    };
    final tintColors = <SketchSlot, int>{};

    for (final mission in missions) {
      SketchPart? part;

      if (mission.partId != null && mission.partId!.isNotEmpty) {
        part = SketchPartsCatalog.findById(mission.partId!);
      }

      if (part == null && mission.achievedTier > 0) {
        final template = MissionTemplate.defaultTemplates
            .where((template) => template.id == mission.missionTemplateId)
            .firstOrNull;
        if (template != null) {
          part = SketchPartsCatalog.getPartForSlotAndTier(
            slot: template.partsSlot,
            tier: mission.achievedTier,
            activityType: template.activityType,
          );
        }
      }

      if (part != null) {
        parts[part.slot] = part;

        if (part.supportsTint) {
          tintColors[part.slot] = SketchPartsCatalog.getRandomCostumeTint();
        }
      }
    }

    return SketchComposition(parts: parts, tintColors: tintColors);
  }
}
