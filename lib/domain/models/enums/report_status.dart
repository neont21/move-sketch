/// 사용자 신고 내역의 관리자 처리 단계를 정의하는 열거형입니다.
enum ReportStatus {
  /// 접수 후 미확인 상태.
  unconfirmed('미확인'),
  /// 관리자 검토 중인 상태.
  reviewing('검토 중'),
  /// 제재 또는 조치가 완료된 상태.
  actionTaken('조치 완료'),
  /// 위반 사항이 없어 종결된 상태.
  noAction('이상 없음');

  /// UI에 표시할 상태 명칭.
  final String label;

  const ReportStatus(this.label);

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [ReportStatus]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [ReportStatus.unconfirmed]를 반환합니다.
  static ReportStatus fromString(String? value) {
    return ReportStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ReportStatus.unconfirmed,
    );
  }
}
