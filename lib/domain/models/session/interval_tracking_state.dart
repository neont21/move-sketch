import 'package:flutter/foundation.dart';
import '../enums/interval_phase.dart';

/// 조깅 세션 중 인터벌 트레이닝(질주 및 회복) 구간 감지 상태를 추적하는 불변 모델입니다.
@immutable
class IntervalTrackingState {
  /// 질주 구간 진입으로 판정하기 위해 단축되어야 하는 기준 페이스 차이. (초)
  static const int paceReductionThresholdSeconds = 40;

  /// 질주 구간으로 유효하게 인정받기 위해 유지해야 하는 최소 지속 시간.
  static const Duration minimumFastDuration = Duration(seconds: 7);

  /// 질주 중 일시적으로 페이스가 저하되었을 때 탈락을 유예하는 최대 허용 시간.
  static const Duration maximumGraceDuration = Duration(seconds: 2);

  /// 회복 구간으로 유효하게 인정받기 위해 유지해야 하는 최소 지속 시간.
  static const Duration minimumRecoveryDuration = Duration(seconds: 10);

  /// 질주 상태로 인정받을 수 있는 최대 상한 페이스. (초/km, 10분/km 초과 시 무효)
  static const int maximumFastPaceSeconds = 600;

  /// 회복 구간 진입을 판정하기 위한 기준 페이스 마진. (초)
  static const int recoveryPaceOffsetSeconds = 15;

  /// 성공적으로 완료된 인터벌 반복 횟수.
  final int count;

  /// 현재 인터벌 진행 단계.
  final IntervalPhase phase;

  /// 현재 단계에 진입한 시작 시점.
  final DateTime? phaseStartTime;

  /// 질주 구간 진입 당시 동결된 기준 페이스. (초/km)
  final int? lockedBaselinePaceSeconds;

  /// 질주 중 속도 저하 유예가 시작된 시점. (정상 주행 중이면 `null`)
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

  /// 현재 측정 페이스와 기준 페이스를 평가하여 다음 인터벌 상태로 전이합니다.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalTrackingState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          phase == other.phase &&
          phaseStartTime == other.phaseStartTime &&
          lockedBaselinePaceSeconds == other.lockedBaselinePaceSeconds &&
          graceStartTime == other.graceStartTime;

  @override
  int get hashCode => Object.hash(
    count,
    phase,
    phaseStartTime,
    lockedBaselinePaceSeconds,
    graceStartTime,
  );
}
