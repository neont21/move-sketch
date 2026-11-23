/// 고객 문의 및 버그 제보의 처리 상태를 정의하는 열거형입니다.
enum InquiryStatus {
  /// 접수 후 확인되지 않은 초기 상태.
  unconfirmed('미확인'),
  /// 관리자가 내용을 검토 중인 상태.
  reviewing('검토 중'),
  /// 수정 또는 조치 작업이 진행 중인 상태.
  inProgress('작업 중'),
  /// 처리가 완료된 상태.
  resolved('해결 완료'),
  /// 재현 불가 또는 기타 사유로 기각/보류된 상태.
  dismissed('보류/기각');

  /// UI에 표시할 상태 명칭.
  final String label;

  const InquiryStatus(this.label);

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [InquiryStatus]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [InquiryStatus.unconfirmed]를 반환합니다.
  static InquiryStatus fromString(String? value) {
    return InquiryStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => InquiryStatus.unconfirmed,
    );
  }
}
