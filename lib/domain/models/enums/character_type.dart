import '../../../config/assets.dart';
import '../fixed/sketch_parts.dart';
import 'sketch_slot.dart';

enum CharacterType {
  bear(id: 'bear', label: '곰'),
  panda(id: 'panda', label: '판다'),
  cat(id: 'cat', label: '고양이'),
  dog(id: 'dog', label: '강아지');

  final String id;
  final String label;

  const CharacterType({required this.id, required this.label});

  String get assetPath => Assets.character(id);
  String get defaultImagePath => Assets.defaultCharacter(id);

  SketchPart toSketchPart() {
    return SketchPart(
      id: 'char_$id',
      slot: SketchSlot.character,
      name: label,
      assetPath: assetPath,
    );
  }

  static CharacterType fromString(String? value) {
    return CharacterType.values.firstWhere(
          (c) => c.id == value?.toLowerCase(),
      orElse: () => CharacterType.bear,
    );
  }
}