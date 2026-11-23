import '../../../config/assets.dart';
import '../fixed/sketch_part.dart';
import 'sketch_slot.dart';

/// 캐릭터의 종류와 에셋 경로 및 스케치 파츠 변환을 정의하는 열거형입니다.
enum CharacterType {
  /// 곰 캐릭터.
  bear(id: 'bear', label: '곰'),
  /// 판다 캐릭터.
  panda(id: 'panda', label: '판다'),
  /// 고양이 캐릭터.
  cat(id: 'cat', label: '고양이'),
  /// 강아지 캐릭터.
  dog(id: 'dog', label: '강아지');

  /// 캐릭터 식별자.
  final String id;
  /// UI에 표시할 캐릭터 명칭.
  final String label;

  const CharacterType({required this.id, required this.label});

  /// 캐릭터 그래픽 에셋 경로.
  String get assetPath => Assets.character(id);
  /// 온보딩 및 프로필 선택에 사용하는 기본 정적 이미지 경로.
  String get defaultImagePath => Assets.defaultCharacter(id);

  /// 캐릭터를 스케치 합성 레이어의 [SketchPart] 객체로 변환합니다.
  SketchPart toSketchPart() {
    return SketchPart(
      id: 'char_$id',
      slot: SketchSlot.character,
      name: label,
      assetPath: assetPath,
    );
  }

  /// 문자열 [value]와 식별자([id])를 매칭하여 [CharacterType]을 반환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [CharacterType.bear]를 반환합니다.
  static CharacterType fromString(String? value) {
    return CharacterType.values.firstWhere(
          (character) => character.id == value?.toLowerCase(),
      orElse: () => CharacterType.bear,
    );
  }
}