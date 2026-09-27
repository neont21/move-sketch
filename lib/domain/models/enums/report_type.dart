enum ReportType {
  inappropriateProfile('부적절한 프로필'),
  harassment('욕설, 비하 또는 괴롭힘'),
  spam('스팸 또는 홍보'),
  other('기타');

  final String label;
  const ReportType(this.label);

  static ReportType fromString(String? value) {
    return ReportType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ReportType.other,
    );
  }
}
