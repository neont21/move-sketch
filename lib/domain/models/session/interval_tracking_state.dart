import 'package:flutter/foundation.dart';
import '../enums/interval_phase.dart';

@immutable
class IntervalTrackingState {
  static const int paceReductionThresholdSeconds = 40;
  static const Duration minimumFastDuration = Duration(seconds: 7);
  static const Duration maximumGraceDuration = Duration(seconds: 2);
  static const Duration minimumRecoveryDuration = Duration(seconds: 10);
  static const int maximumFastPaceSeconds = 600;
  static const int recoveryPaceOffsetSeconds = 15;

  final int count;
  final IntervalPhase phase;
  final DateTime? phaseStartTime;
  final int? lockedBaselinePaceSeconds;
  final DateTime? graceStartTime;

  const IntervalTrackingState({
    this.count = 0,
    this.phase = IntervalPhase.idle,
    this.phaseStartTime,
    this.lockedBaselinePaceSeconds,
    this.graceStartTime,
  });

  IntervalTrackingState copyWith({
    int? count,
    IntervalPhase? phase,
    DateTime? Function()? phaseStartTime,
    int? Function()? lockedBaselinePaceSeconds,
    DateTime? Function()? graceStartTime,
  }) {
    return IntervalTrackingState(
      count: count ?? this.count,
      phase: phase ?? this.phase,
      phaseStartTime: phaseStartTime != null
          ? phaseStartTime()
          : this.phaseStartTime,
      lockedBaselinePaceSeconds: lockedBaselinePaceSeconds != null
          ? lockedBaselinePaceSeconds()
          : this.lockedBaselinePaceSeconds,
      graceStartTime: graceStartTime != null
          ? graceStartTime()
          : this.graceStartTime,
    );
  }

  IntervalTrackingState evaluate({
    required int? currentPaceInSeconds,
    required int? rollingBaselinePaceInSeconds,
    required DateTime timestamp,
  }) {
    switch (phase) {
      case IntervalPhase.idle:
        if (currentPaceInSeconds == null ||
            rollingBaselinePaceInSeconds == null) {
          return this;
        }

        final targetFastPace =
            rollingBaselinePaceInSeconds - paceReductionThresholdSeconds;
        final isFastPace =
            currentPaceInSeconds <= targetFastPace &&
            currentPaceInSeconds <= maximumFastPaceSeconds;

        if (isFastPace) {
          return copyWith(
            phase: IntervalPhase.fastPhase,
            phaseStartTime: () => timestamp,
            lockedBaselinePaceSeconds: () => rollingBaselinePaceInSeconds,
            graceStartTime: () => null,
          );
        }

        return this;
      case IntervalPhase.fastPhase:
        final effectiveBaseline =
            lockedBaselinePaceSeconds ?? rollingBaselinePaceInSeconds;
        if (currentPaceInSeconds == null || effectiveBaseline == null) {
          return this;
        }

        final targetFastPace =
            effectiveBaseline - paceReductionThresholdSeconds;
        final isFastPace =
            currentPaceInSeconds <= targetFastPace &&
            currentPaceInSeconds <= maximumFastPaceSeconds;

        if (isFastPace) {
          final elapsedSincePhaseStart = timestamp.difference(
            phaseStartTime ?? timestamp,
          );

          if (elapsedSincePhaseStart >= minimumFastDuration) {
            return copyWith(
              phase: IntervalPhase.recoveryPhase,
              phaseStartTime: () => timestamp,
              lockedBaselinePaceSeconds: () => effectiveBaseline,
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
            phase: IntervalPhase.idle,
            phaseStartTime: () => null,
            lockedBaselinePaceSeconds: () => null,
            graceStartTime: () => null,
          );
        }
      case IntervalPhase.recoveryPhase:
        final effectiveBaseline =
            lockedBaselinePaceSeconds ?? rollingBaselinePaceInSeconds;
        if (currentPaceInSeconds == null || effectiveBaseline == null) {
          return this;
        }

        final targetRecoveryPace =
            effectiveBaseline - recoveryPaceOffsetSeconds;
        final isRecoveryPace = currentPaceInSeconds >= targetRecoveryPace;

        if (isRecoveryPace) {
          final elapsedSinceRecoveryStart = timestamp.difference(
            phaseStartTime ?? timestamp,
          );

          if (elapsedSinceRecoveryStart >= minimumRecoveryDuration) {
            return copyWith(
              count: count + 1,
              phase: IntervalPhase.idle,
              phaseStartTime: () => null,
              lockedBaselinePaceSeconds: () => null,
              graceStartTime: () => null,
            );
          }

          return this;
        } else {
          return this;
        }
    }
  }
}
