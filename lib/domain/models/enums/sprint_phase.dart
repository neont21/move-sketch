enum SprintPhase {
  ready(label: '주행 중'),
  sprinting(label: '스프린트 중'),
  cooldown(label: '쿨다운');

  final String label;

  const SprintPhase({required this.label});

  bool get isReady => this == SprintPhase.ready;
  bool get isSprinting => this == SprintPhase.sprinting;
  bool get isCooldown => this == SprintPhase.cooldown;

  static SprintPhase fromString(String? value) {
    return SprintPhase.values.firstWhere(
          (phase) => phase.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SprintPhase.ready,
    );
  }
}
