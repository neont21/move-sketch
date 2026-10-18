import 'package:flutter/foundation.dart';
import '../enums/sprint_phase.dart';

@immutable
class SprintTrackingState {
  static const double speedIncreaseThresholdKmh = 5.0;
  static const double minimumSprintSpeedKmh = 16.0;
  static const Duration minimumSprintDuration = Duration(seconds: 3);
  static const Duration cooldownDuration = Duration(seconds: 10);

  final int count;
  final SprintPhase phase;
  final DateTime? phaseStartTime;

  const SprintTrackingState({
    this.count = 0,
    this.phase = SprintPhase.ready,
    this.phaseStartTime,
  });

  SprintTrackingState copyWith({
    int? count,
    SprintPhase? phase,
    DateTime? Function()? phaseStartTime,
  }) {
    return SprintTrackingState(
      count: count ?? this.count,
      phase: phase ?? this.phase,
      phaseStartTime: phaseStartTime != null
          ? phaseStartTime()
          : this.phaseStartTime,
    );
  }

  SprintTrackingState evaluate({
    required double? currentSpeedKmh,
    required double? averageSpeedKmh,
    required DateTime timestamp,
  }) {
    if (currentSpeedKmh == null || averageSpeedKmh == null) {
      return this;
    }

    final targetSprintSpeed =
        (averageSpeedKmh + speedIncreaseThresholdKmh > minimumSprintSpeedKmh)
        ? averageSpeedKmh + speedIncreaseThresholdKmh
        : minimumSprintSpeedKmh;

    final isSprintingSpeed = currentSpeedKmh >= targetSprintSpeed;

    return switch (phase) {
      SprintPhase.ready =>
        isSprintingSpeed
            ? copyWith(
                phase: SprintPhase.sprinting,
                phaseStartTime: () => timestamp,
              )
            : this,

      SprintPhase.sprinting =>
        isSprintingSpeed
            ? (timestamp.difference(phaseStartTime ?? timestamp) >=
                      minimumSprintDuration
                  ? copyWith(
                      count: count + 1,
                      phase: SprintPhase.cooldown,
                      phaseStartTime: () => timestamp,
                    )
                  : this)
            : copyWith(phase: SprintPhase.ready, phaseStartTime: () => null),

      SprintPhase.cooldown =>
        (timestamp.difference(phaseStartTime ?? timestamp) >= cooldownDuration)
            ? copyWith(phase: SprintPhase.ready, phaseStartTime: () => null)
            : this,
    };
  }
}
