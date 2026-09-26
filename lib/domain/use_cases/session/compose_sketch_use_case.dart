import '../../models/enums/character_type.dart';
import '../../models/enums/sketch_slot.dart';
import '../../models/fixed/mission_template.dart';
import '../../models/fixed/sketch_parts.dart';
import '../../models/session/mission_instance.dart';

class ComposeSketchUseCase {
  const ComposeSketchUseCase();

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
            .where((t) => t.id == mission.missionTemplateId)
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
