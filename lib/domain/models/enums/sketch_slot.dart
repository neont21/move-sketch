enum SketchSlot {
  background(label: '배경', zIndex: 0),
  character(label: '캐릭터', zIndex: 10),
  costume(label: '의상', zIndex: 20),
  expression(label: '표정', zIndex: 30),
  prop(label: '소품', zIndex: 40),
  effect(label: '효과', zIndex: 50),
  unknown(label: '알 수 없음', zIndex: 0);

  final String label;
  final int zIndex;

  const SketchSlot({required this.label, required this.zIndex});

  static SketchSlot fromString(String? value) {
    return SketchSlot.values.firstWhere(
      (slot) => slot.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SketchSlot.unknown,
    );
  }
}
