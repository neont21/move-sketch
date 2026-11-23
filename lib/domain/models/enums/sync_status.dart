/// 오프라인 세션 데이터의 원격 서버 동기화 상태를 정의하는 열거형입니다.
enum SyncStatus {
  /// 로컬에만 저장된 대기 상태.
  localOnly,
  /// 서버로 동기화 중인 상태.
  syncing,
  /// 서버 동기화가 완료된 상태.
  synced,
  /// 동기화에 실패하여 재시도가 필요한 상태.
  syncFailed;

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [SyncStatus]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [SyncStatus.localOnly]를 반환합니다.
  static SyncStatus fromString(String? value) {
    return SyncStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SyncStatus.localOnly,
    );
  }
}
