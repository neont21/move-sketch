import 'package:flutter/foundation.dart';

import '../enums/sprint_phase.dart';

/// 라이딩 세션 중 순간 최대 가속 스프린트 감지 상태를 추적하는 불변 모델입니다.
@immutable
class SprintTrackingState {
  /// 스프린트 구간 진입으로 판정하기 위해 증가해야 하는 기준 속도 차이. (km/h)
  static const double speedIncreaseThresholdKmh = 5.0;

  /// 스프린트로 인정받기 위한 절대 최소 기준 속도. (km/h)
  static const double minimumSprintSpeedKmh = 16.0;

  /// 스프린트 1회로 유효하게 인정받기 위해 유지해야 하는 최소 지속 시간.
  static const Duration minimumSprintDuration = Duration(seconds: 5);

  /// 스프린트 중 일시적으로 속도가 저하되었을 때 탈락을 유예하는 최대 허용 시간.
  static const Duration maximumGraceDuration = Duration(seconds: 2);

  /// 스프린트 성공 후 다음 스프린트 감지 대기까지 요구되는 쿨다운 시간.
  static const Duration cooldownDuration = Duration(seconds: 10);

  /// 성공적으로 완료된 스프린트 횟수.
  final int count;

  /// 현재 스프린트 진행 단계.
  final SprintPhase phase;

  /// 현재 단계에 진입한 시작 시점.
  final DateTime? phaseStartTime;

  /// 스프린트 시작 당시 동결된 기준 속도. (km/h)
  final double? lockedBaselineSpeedKmh;

  /// 스프린트 중 속도 저하 유예가 시작된 시점.
  final DateTime? graceStartTime;

  const SprintTrackingState({
    this.count = 0,
    this.phase = SprintPhase.ready,
    this.phaseStartTime,
    this.lockedBaselineSpeedKmh,
    this.graceStartTime,
  });

  SprintTrackingState copyWith({
    int? count,
    SprintPhase? phase,
    DateTime? Function()? phaseStartTime,
    double? Function()? lockedBaselineSpeedKmh,
    DateTime? Function()? graceStartTime,
  }) {
    return SprintTrackingState(
      count: count ?? this.count,
      phase: phase ?? this.phase,
      phaseStartTime: phaseStartTime != null
          ? phaseStartTime()
          : this.phaseStartTime,
      lockedBaselineSpeedKmh: lockedBaselineSpeedKmh != null
          ? lockedBaselineSpeedKmh()
          : this.lockedBaselineSpeedKmh,
      graceStartTime: graceStartTime != null
          ? graceStartTime()
          : this.graceStartTime,
    );
  }

  /// 현재 주행 속도와 기준 속도를 평가하여 다음 스프린트 상태로 전이합니다.
  SprintTrackingState evaluate({
    required double? currentSpeedKmh,
    required double? rollingBaselineSpeedKmh,
    required DateTime timestamp,
  }) {
    switch (phase) {
      case SprintPhase.ready:
        if (currentSpeedKmh == null || rollingBaselineSpeedKmh == null) {
          return this;
        }

        final dynamicTargetSpeed =
            rollingBaselineSpeedKmh + speedIncreaseThresholdKmh;
        final targetSprintSpeed = dynamicTargetSpeed > minimumSprintSpeedKmh
            ? dynamicTargetSpeed
            : minimumSprintSpeedKmh;

        final isSprintingSpeed = currentSpeedKmh >= targetSprintSpeed;

        if (isSprintingSpeed) {
          return copyWith(
            phase: SprintPhase.sprinting,
            phaseStartTime: () => timestamp,
            lockedBaselineSpeedKmh: () => rollingBaselineSpeedKmh,
            graceStartTime: () => null,
          );
        }

        return this;
      case SprintPhase.sprinting:
        final effectiveBaseline =
            lockedBaselineSpeedKmh ?? rollingBaselineSpeedKmh;
        if (currentSpeedKmh == null || effectiveBaseline == null) {
          return this;
        }

        final dynamicTargetSpeed =
            effectiveBaseline + speedIncreaseThresholdKmh;
        final targetSprintSpeed = dynamicTargetSpeed > minimumSprintSpeedKmh
            ? dynamicTargetSpeed
            : minimumSprintSpeedKmh;

        final isSprintingSpeed = currentSpeedKmh >= targetSprintSpeed;

        if (isSprintingSpeed) {
          final elapsedSinceSprintStart = timestamp.difference(
            phaseStartTime ?? timestamp,
          );

          if (elapsedSinceSprintStart >= minimumSprintDuration) {
            return copyWith(
              count: count + 1,
              phase: SprintPhase.cooldown,
              phaseStartTime: () => timestamp,
              lockedBaselineSpeedKmh: () => null,
              graceStartTime: () => null,
            );
          }

          return graceStartTime != null
              ? copyWith(graceStartTime: () => null)
              : this;
        } else {
          final firstDropTime = graceStartTime ?? timestamp;
          final dropDuration = timestamp.difference(firstDropTime);

          if (dropDuration <= maximumGraceDuration) {
            return graceStartTime == null
                ? copyWith(graceStartTime: () => firstDropTime)
                : this;
          }

          return copyWith(
            phase: SprintPhase.ready,
            phaseStartTime: () => null,
            lockedBaselineSpeedKmh: () => null,
            graceStartTime: () => null,
          );
        }
      case SprintPhase.cooldown:
        final elapsedSinceCooldownStart = timestamp.difference(
          phaseStartTime ?? timestamp,
        );

        if (elapsedSinceCooldownStart >= cooldownDuration) {
          return copyWith(
            phase: SprintPhase.ready,
            phaseStartTime: () => null,
            graceStartTime: () => null,
          );
        }

        return this;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SprintTrackingState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          phase == other.phase &&
          phaseStartTime == other.phaseStartTime &&
          lockedBaselineSpeedKmh == other.lockedBaselineSpeedKmh &&
          graceStartTime == other.graceStartTime;

  @override
  int get hashCode => Object.hash(
    count,
    phase,
    phaseStartTime,
    lockedBaselineSpeedKmh,
    graceStartTime,
  );
}
