/// 라이딩 세션 중 스프린트 감지 상태를 정의하는 열거형입니다.
enum SprintPhase {
  /// 일반 주행 상태.
  ready(label: '주행 중'),
  /// 순간 최대 가속 스프린트 진행 상태.
  sprinting(label: '스프린트 중'),
  /// 스프린트 종료 후 쿨다운 상태.
  cooldown(label: '쿨다운');

  /// UI에 표시할 상태 명칭.
  final String label;

  const SprintPhase({required this.label});

  /// 감지 대기 상태인지 여부를 반환합니다.
  bool get isReady => this == SprintPhase.ready;
  /// 스프린트 중인지 여부를 반환합니다.
  bool get isSprinting => this == SprintPhase.sprinting;
  /// 쿨다운 중인지 여부를 반환합니다.
  bool get isCooldown => this == SprintPhase.cooldown;

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [SprintPhase]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [SprintPhase.ready]를 반환합니다.
  static SprintPhase fromString(String? value) {
    return SprintPhase.values.firstWhere(
          (phase) => phase.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SprintPhase.ready,
    );
  }
}
