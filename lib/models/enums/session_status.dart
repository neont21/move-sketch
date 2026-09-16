enum SessionStatus {
  ready,
  active,
  pausedAuto,
  pausedManual,
  completed,
  aborted;

  bool get isReady => this == SessionStatus.ready;
  bool get isActive => this == SessionStatus.active;
  bool get isPaused =>
      this == SessionStatus.pausedAuto || this == SessionStatus.pausedManual;
  bool get isOngoing => isActive || isPaused;
  bool get isEnded =>
      this == SessionStatus.completed || this == SessionStatus.aborted;

  static SessionStatus fromString(String? value) {
    return SessionStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SessionStatus.ready,
    );
  }
}
