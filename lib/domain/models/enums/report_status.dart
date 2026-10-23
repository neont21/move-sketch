enum ReportStatus {
  unconfirmed('미확인'),
  reviewing('검토 중'),
  actionTaken('조치 완료'),
  noAction('이상 없음');

  final String label;

  const ReportStatus(this.label);

  static ReportStatus fromString(String? value) {
    return ReportStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ReportStatus.unconfirmed,
    );
  }
}
