/// 사용자 및 콘텐츠 신고 사유 분류를 정의하는 열거형입니다.
enum ReportType {
  /// 부적절한 프로필 사진 또는 닉네임.
  inappropriateProfile('부적절한 프로필'),
  /// 욕설, 모욕, 혐오 발언 등 괴롭힘.
  harassment('욕설, 비하 또는 괴롭힘'),
  /// 도배 또는 영리성 홍보.
  spam('스팸 또는 홍보'),
  /// 기타 사유.
  other('기타');

  /// UI에 표시할 신고 사유 명칭.
  final String label;

  const ReportType(this.label);

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [ReportType]으로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [ReportType.other]를 반환합니다.
  static ReportType fromString(String? value) {
    return ReportType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ReportType.other,
    );
  }
}
