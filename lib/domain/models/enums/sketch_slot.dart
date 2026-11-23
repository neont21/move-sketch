/// 스케치 그래픽 합성 캔버스의 레이어 슬롯과 렌더링 순서(Z-Index)를 정의하는 열거형입니다.
enum SketchSlot {
  /// 배경 레이어.
  background(label: '배경', zIndex: 0),
  /// 캐릭터 몸체 레이어.
  character(label: '캐릭터', zIndex: 10),
  /// 의상 레이어.
  costume(label: '의상', zIndex: 20),
  /// 표정 레이어.
  expression(label: '표정', zIndex: 30),
  /// 소품 레이어.
  prop(label: '소품', zIndex: 40),
  /// 시각 효과 레이어.
  effect(label: '효과', zIndex: 50),
  /// 미정의 레이어.
  unknown(label: '알 수 없음', zIndex: 0);

  /// UI에 표시할 슬롯 명칭.
  final String label;
  /// 레이어 렌더링 순서를 결정하는 Z-Index 값.
  final int zIndex;

  const SketchSlot({required this.label, required this.zIndex});

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [SketchSlot]으로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [SketchSlot.unknown]을 반환합니다.
  static SketchSlot fromString(String? value) {
    return SketchSlot.values.firstWhere(
      (slot) => slot.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SketchSlot.unknown,
    );
  }
}
