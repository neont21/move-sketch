import 'sketch_slot.dart';

enum MissionAxis {
  distance(
    label: '거리',
    unit: 'km',
    slot: SketchSlot.background,
    description: '세션에서의 총 이동 거리',
  ),

  pace(
    label: '페이스',
    unit: '/km',
    slot: SketchSlot.expression,
    description: '조깅 중 1km를 이동하는 데 걸린 평균 시간',
      lowerIsBetter: true
  ),
  speed(
    label: '속도',
    unit: 'km/h',
    slot: SketchSlot.expression,
    description: '라이딩 중 평균 시속',
  ),

  duration(
    label: '지속 시간',
    unit: '분',
    slot: SketchSlot.costume,
    description: '쉬지 않고 움직인 순수 활동 시간',
  ),

  routeExploration(
    label: '경로 탐색',
    unit: 'km',
    slot: SketchSlot.prop,
    description: '이전에 가보지 않은 새로운 도로 이동 거리',
  ),

  interval(
    label: '인터벌',
    unit: '회',
    slot: SketchSlot.effect,
    description: '조깅 중 빠르게 달리기와 천천히 걷기의 반복 횟수',
  ),
  sprint(
    label: '스프린트',
    unit: '회',
    slot: SketchSlot.effect,
    description: '라이딩 중 순간 최대 속도 도달 버스트 감지 횟수',
  ),

  unknown(
    label: '알 수 없음',
    unit: '',
    slot: SketchSlot.unknown,
    description: '알 수 없는 미션',
  );

  final String label;
  final String unit;
  final SketchSlot slot;
  final String description;
  final bool lowerIsBetter;

  const MissionAxis({
    required this.label,
    required this.unit,
    required this.slot,
    required this.description,
    this.lowerIsBetter=false,
  });

  bool isAchieved({required double value, required double threshold}) {
    return lowerIsBetter ? value <= threshold : value >= threshold;
  }

  int compareThresholds(double a, double b) {
    return lowerIsBetter ? a.compareTo(b) : b.compareTo(a);
  }

  static MissionAxis fromString(String? value) {
    return MissionAxis.values.firstWhere(
      (axis) => axis.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => MissionAxis.unknown,
    );
  }
}
