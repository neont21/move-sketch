/// 실시간 운동 세션 트래킹의 생명주기 상태를 정의하는 열거형입니다.
enum SessionStatus {
  /// 세션 시작 준비 완료 상태.
  ready,
  /// 위치를 추적하며 기록 중인 상태.
  active,
  /// 정지 감지 등으로 자동 일시정지된 상태.
  pausedAuto,
  /// 사용자가 수동으로 일시정지한 상태.
  pausedManual,
  /// 세션 기록 및 저장이 완료된 상태.
  completed,
  /// 저장을 취소하고 중단된 상태.
  aborted;

  /// 준비 상태인지 여부.
  bool get isReady => this == SessionStatus.ready;
  /// 기록 중인 활성 상태인지 여부.
  bool get isActive => this == SessionStatus.active;
  /// 자동 또는 수동으로 일시정지된 상태인지 여부.
  bool get isPaused =>
      this == SessionStatus.pausedAuto || this == SessionStatus.pausedManual;
  /// 자동으로 일시정지된 상태인지 여부.
  bool get isPausedAuto => this == SessionStatus.pausedAuto;
  /// 수동으로 일시정지된 상태인지 여부.
  bool get isPausedManual => this == SessionStatus.pausedManual;
  /// 세션이 진행 중(기록 또는 일시정지)인지 여부.
  bool get isOngoing => isActive || isPaused;
  /// 세션이 종료(완료 또는 중단)되었는지 여부.
  bool get isEnded =>
      this == SessionStatus.completed || this == SessionStatus.aborted;

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [SessionStatus]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [SessionStatus.ready]를 반환합니다.
  static SessionStatus fromString(String? value) {
    return SessionStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SessionStatus.ready,
    );
  }
}
