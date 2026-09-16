enum ActivityType {
  jogging(label: '조깅', defaultUnit: 'km', speedUnit: '분/km'),
  riding(label: '라이딩', defaultUnit: 'km', speedUnit: 'km/h');

  final String label;
  final String defaultUnit;
  final String speedUnit;

  const ActivityType({
    required this.label,
    required this.defaultUnit,
    required this.speedUnit,
  });

  static ActivityType fromString(String? value) {
    return ActivityType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ActivityType.jogging,
    );
  }
}
