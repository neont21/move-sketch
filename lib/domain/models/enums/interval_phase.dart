enum IntervalPhase {
  idle(label: '일반 주행'),
  fastPhase(label: '질주 중'),
  recoveryPhase(label: '회복 중');

  final String label;

  const IntervalPhase({required this.label});

  bool get isIdle => this == IntervalPhase.idle;
  bool get isFastPhase => this == IntervalPhase.fastPhase;
  bool get isRecoveryPhase => this == IntervalPhase.recoveryPhase;

  static IntervalPhase fromString(String? value) {
    return IntervalPhase.values.firstWhere(
          (phase) => phase.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => IntervalPhase.idle,
    );
  }
}
