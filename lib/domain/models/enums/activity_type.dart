/// 운동 세션의 활동 종목과 종목별 측정 단위를 정의하는 열거형입니다.
enum ActivityType {
  /// 조깅 활동. (거리 단위: km, 속도 단위: 분/km)
  jogging(label: '조깅', defaultUnit: 'km', speedUnit: '분/km'),
  /// 라이딩 활동. (거리 단위: km, 속도 단위: km/h)
  riding(label: '라이딩', defaultUnit: 'km', speedUnit: 'km/h');

  /// UI에 표시할 활동 명칭.
  final String label;
  /// 이동 거리 기본 측정 단위.
  final String defaultUnit;
  /// 속도 또는 페이스 측정 단위.
  final String speedUnit;

  const ActivityType({
    required this.label,
    required this.defaultUnit,
    required this.speedUnit,
  });

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [ActivityType]으로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [ActivityType.jogging]을 반환합니다.
  static ActivityType fromString(String? value) {
    return ActivityType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ActivityType.jogging,
    );
  }
}
