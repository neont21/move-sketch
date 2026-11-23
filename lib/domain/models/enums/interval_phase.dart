/// 조깅 세션 중 인터벌 트레이닝 구간 상태를 정의하는 열거형입니다.
enum IntervalPhase {
  /// 일반 주행 상태.
  idle(label: '일반 주행'),
  /// 고강도 질주 구간.
  fastPhase(label: '질주 중'),
  /// 저강도 회복 구간.
  recoveryPhase(label: '회복 중');

  /// UI에 표시할 구간 명칭.
  final String label;

  const IntervalPhase({required this.label});

  /// 일반 주행 상태인지 여부.
  bool get isIdle => this == IntervalPhase.idle;
  /// 고강도 질주 구간인지 여부.
  bool get isFastPhase => this == IntervalPhase.fastPhase;
  /// 회복 구간인지 여부.
  bool get isRecoveryPhase => this == IntervalPhase.recoveryPhase;

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [IntervalPhase]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [IntervalPhase.idle]을 반환합니다.
  static IntervalPhase fromString(String? value) {
    return IntervalPhase.values.firstWhere(
          (phase) => phase.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => IntervalPhase.idle,
    );
  }
}
