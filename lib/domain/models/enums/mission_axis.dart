import 'sketch_slot.dart';

/// 운동 세션의 평가 지표 축과 연계된 스케치 슬롯을 정의하는 열거형입니다.
enum MissionAxis {
  /// 총 이동 거리 축.
  distance(
    label: '거리',
    unit: 'km',
    slot: SketchSlot.background,
    description: '세션에서의 총 이동 거리',
  ),

  /// 조깅 평균 페이스 축.
  pace(
    label: '페이스',
    unit: '/km',
    slot: SketchSlot.expression,
    description: '조깅 중 1km를 이동하는 데 걸린 평균 시간',
    lowerIsBetter: true,
  ),
  /// 라이딩 평균 속도 축.
  speed(
    label: '속도',
    unit: 'km/h',
    slot: SketchSlot.expression,
    description: '라이딩 중 평균 시속',
  ),

  /// 실제 활동 시간 축.
  duration(
    label: '지속 시간',
    unit: '분',
    slot: SketchSlot.costume,
    description: '쉬지 않고 움직인 순수 활동 시간',
  ),

  /// 신규 경로 이동 거리 축.
  routeExploration(
    label: '경로 탐색',
    unit: 'km',
    slot: SketchSlot.prop,
    description: '이전에 가보지 않은 새로운 도로 이동 거리',
  ),

  /// 조깅 인터벌 반복 횟수 축.
  interval(
    label: '인터벌',
    unit: '회',
    slot: SketchSlot.effect,
    description: '조깅 중 빠르게 달리기와 천천히 걷기의 반복 횟수',
  ),
  /// 라이딩 스프린트 감지 횟수 축.
  sprint(
    label: '스프린트',
    unit: '회',
    slot: SketchSlot.effect,
    description: '라이딩 중 순간 최대 속도 도달 버스트 감지 횟수',
  ),

  /// 미정의 또는 예외 처리용 기본 축.
  unknown(
    label: '알 수 없음',
    unit: '',
    slot: SketchSlot.unknown,
    description: '알 수 없는 미션',
  );

  /// UI에 표시할 축 명칭.
  final String label;
  /// 측정 단위 표기.
  final String unit;
  /// 미션 달성 시 해금되는 스케치 레이어 슬롯.
  final SketchSlot slot;
  /// 지표 설명문.
  final String description;
  /// 수치가 낮을수록 우수한 성과인지 여부.
  final bool lowerIsBetter;

  const MissionAxis({
    required this.label,
    required this.unit,
    required this.slot,
    required this.description,
    this.lowerIsBetter = false,
  });

  /// 측정값 [value]가 목표 임계치 [threshold]를 충족했는지 검증합니다.
  ///
  /// [lowerIsBetter]가 `true`이면 기준 이하, `false`이면 기준 이상일 때 달성으로 판정합니다.
  bool isAchieved({required double value, required double threshold}) {
    return lowerIsBetter ? value <= threshold : value >= threshold;
  }

  /// 두 목표 임계치 [a]와 [b]를 비교합니다.
  ///
  /// [lowerIsBetter]가 `true`이면 작은 값 우선, `false`이면 큰 값 우선으로 정렬 기준을 반환합니다.
  int compareThresholds(double a, double b) {
    return lowerIsBetter ? a.compareTo(b) : b.compareTo(a);
  }

  /// 측정값 [value]를 단위 규칙에 맞는 문자열로 포맷팅합니다.
  ///
  /// - 거리/경로 탐색: 소수점 2자리 (`0.00`)
  /// - 페이스: `분' 초''` 형식 (0 이하인 경우 `-' --''`)
  /// - 속도: 소수점 1자리 (`0.0`)
  /// - 그 외: 반올림 정수 표기
  String formatValue(double value) {
    return switch (this) {
      MissionAxis.distance ||
      MissionAxis.routeExploration => value.toStringAsFixed(2),
      MissionAxis.pace =>
        value <= 0
            ? '-\' --\'\''
            : '${value.round() ~/ 60}\' ${(value.round() % 60).toString().padLeft(2, '0')}\'\'',
      MissionAxis.speed => value.toStringAsFixed(1),
      _ => value.round().toString(),
    };
  }

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [MissionAxis]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [MissionAxis.unknown]을 반환합니다.
  static MissionAxis fromString(String? value) {
    return MissionAxis.values.firstWhere(
      (axis) => axis.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => MissionAxis.unknown,
    );
  }
}
