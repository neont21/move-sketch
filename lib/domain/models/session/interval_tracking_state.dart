import 'package:flutter/foundation.dart';
import '../enums/interval_phase.dart';

@immutable
class IntervalTrackingState {
  static const int paceReductionThresholdSeconds = 45;
  static const Duration minimumFastDuration = Duration(seconds: 7);
  static const Duration minimumRecoveryDuration = Duration(seconds: 10);
  static const int maximumFastPaceSeconds = 600;
  static const int recoveryPaceOffsetSeconds = 15;

  final int count;
  final IntervalPhase phase;
  final DateTime? phaseStartTime;

  const IntervalTrackingState({
    this.count = 0,
    this.phase = IntervalPhase.idle,
    this.phaseStartTime,
  });

  IntervalTrackingState copyWith({
    int? count,
    IntervalPhase? phase,
    DateTime? Function()? phaseStartTime,
  }) {
    return IntervalTrackingState(
      count: count ?? this.count,
      phase: phase ?? this.phase,
      phaseStartTime: phaseStartTime != null
          ? phaseStartTime()
          : this.phaseStartTime,
    );
  }

  IntervalTrackingState evaluate({
    required int? currentPaceInSeconds,
    required int? averagePaceInSeconds,
    required DateTime timestamp,
  }) {
    if (currentPaceInSeconds == null || averagePaceInSeconds == null) {
      return this;
    }

    final targetFastPace = averagePaceInSeconds - paceReductionThresholdSeconds;
    final isFastPace =
        currentPaceInSeconds <= targetFastPace &&
        currentPaceInSeconds <= maximumFastPaceSeconds;

    final targetRecoveryPace = averagePaceInSeconds - recoveryPaceOffsetSeconds;
    final isRecoveryPace = currentPaceInSeconds >= targetRecoveryPace;

    return switch (phase) {
      IntervalPhase.idle =>
        isFastPace
            ? copyWith(
                phase: IntervalPhase.fastPhase,
                phaseStartTime: () => timestamp,
              )
            : this,

      IntervalPhase.fastPhase =>
        isFastPace
            ? (timestamp.difference(phaseStartTime ?? timestamp) >=
                      minimumFastDuration
                  ? copyWith(
                      phase: IntervalPhase.recoveryPhase,
                      phaseStartTime: () => timestamp,
                    )
                  : this)
            : copyWith(phase: IntervalPhase.idle, phaseStartTime: () => null),

      IntervalPhase.recoveryPhase =>
        isRecoveryPace
            ? (timestamp.difference(phaseStartTime ?? timestamp) >=
                      minimumRecoveryDuration
                  ? copyWith(
                      count: count + 1,
                      phase: IntervalPhase.idle,
                      phaseStartTime: () => null,
                    )
                  : this)
            : (isFastPace
                  ? copyWith(
                      phase: IntervalPhase.fastPhase,
                      phaseStartTime: () => timestamp,
                    )
                  : this),
    };
  }
}
