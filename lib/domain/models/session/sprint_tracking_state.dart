import 'package:flutter/foundation.dart';
import '../enums/sprint_phase.dart';

@immutable
class SprintTrackingState {
  static const double speedIncreaseThresholdKmh = 5.0;
  static const double minimumSprintSpeedKmh = 16.0;
  static const Duration minimumSprintDuration = Duration(seconds: 5);
  static const Duration maximumGraceDuration = Duration(seconds: 2);
  static const Duration cooldownDuration = Duration(seconds: 10);

  final int count;
  final SprintPhase phase;
  final DateTime? phaseStartTime;
  final double? lockedBaselineSpeedKmh;
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
}
