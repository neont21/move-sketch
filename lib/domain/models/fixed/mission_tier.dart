import 'package:flutter/foundation.dart';

/// 미션의 달성 단계(티어)별 목표 임계치와 안내 설명을 나타내는 불변 모델입니다.
@immutable
class MissionTier {
  /// 티어 단계 번호. (1부터 시작하며 숫자가 클수록 상위 티어)
  final int tier;
  /// 해당 티어를 달성하기 위한 목표 기준 수치.
  final double threshold;
  /// 티어 목표에 대한 안내 설명 문구.
  final String description;

  const MissionTier({
    required this.tier,
    required this.threshold,
    required this.description,
  });
}