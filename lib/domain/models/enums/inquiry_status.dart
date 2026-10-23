enum InquiryStatus {
  unconfirmed('미확인'),
  reviewing('검토 중'),
  inProgress('작업 중'),
  resolved('해결 완료'),
  dismissed('보류/기각');

  final String label;

  const InquiryStatus(this.label);

  static InquiryStatus fromString(String? value) {
    return InquiryStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => InquiryStatus.unconfirmed,
    );
  }
}
