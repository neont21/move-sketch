import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:move_sketch/domain/models/session/session_result.dart';
import 'package:move_sketch/ui/auth/view_models/auth_viewmodel.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/enums/mission_axis.dart';
import '../../../domain/models/fixed/mission_template.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/result.dart';

@immutable
class SessionStartState {
  final ActivityType activityType;
  final List<MissionTemplate> missions;
  final Map<MissionAxis, double?> baselines;
  final List<String> selectedMissionIds;
  final bool isLoading;

  const SessionStartState({
    this.activityType = ActivityType.jogging,
    this.missions = const [],
    this.baselines = const {},
    this.selectedMissionIds = const [],
    this.isLoading = false,
  });

  SessionStartState copyWith({
    ActivityType? activityType,
    List<MissionTemplate>? missions,
    Map<MissionAxis, double?>? baselines,
    List<String>? selectedMissionIds,
    bool? isLoading,
  }) {
    return SessionStartState(
      activityType: activityType ?? this.activityType,
      missions: missions ?? this.missions,
      baselines: baselines ?? this.baselines,
      selectedMissionIds: selectedMissionIds ?? this.selectedMissionIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String getMissionDescription(MissionTemplate template) {
    final baseline = baselines[template.axis];
    if (baseline == null) {
      return template.axis.description;
    }
    switch (template.axis) {
      case MissionAxis.distance:
        return '최근 평균 ${baseline.toStringAsFixed(1)}km';
      case MissionAxis.pace:
        final totalSeconds = baseline.round();
        final minutes = totalSeconds ~/ 60;
        final seconds = totalSeconds % 60;
        return '최근 평균 $minutes분 ${seconds.toString().padLeft(2, '0')}초/km';
      case MissionAxis.speed:
        return '최근 평균 ${baseline.toStringAsFixed(1)}km/h';
      case MissionAxis.duration:
        return '최근 평균 ${baseline.round()}분';
      case MissionAxis.routeExploration:
        return '최근 평균 새 도로 ${baseline.toStringAsFixed(1)}km';
      case MissionAxis.interval:
        return '최근 평균 ${baseline.toStringAsFixed(1)}회 반복';
      case MissionAxis.sprint:
        return '최근 평균 ${baseline.toStringAsFixed(1)}회 반복';
      default:
        return template.axis.description;
    }
  }
}

class SessionStartViewModel extends Notifier<SessionStartState> {
  Map<MissionAxis, double?> _calculateBaselines(
    ActivityType activityType,
    List<SessionResult> results,
  ) {
    if (results.isEmpty) {
      return const {};
    }

    final Map<MissionAxis, double?> baselines = {};

    final distances = results.map((result) => result.distanceInKm).toList();
    if (distances.isNotEmpty) {
      baselines[MissionAxis.distance] =
          distances.reduce((a, b) => a + b) / distances.length;
    }

    final durations = results
        .map((result) => result.elapsedDuration.inMinutes.toDouble())
        .toList();
    if (durations.isNotEmpty) {
      baselines[MissionAxis.duration] =
          durations.reduce((a, b) => a + b) / durations.length;
    }

    if (activityType == ActivityType.jogging) {
      final pacesInSeconds = results
          .map((result) => result.averagePaceInSeconds)
          .whereType<int>()
          .toList();
      if (pacesInSeconds.isNotEmpty) {
        baselines[MissionAxis.pace] =
            pacesInSeconds.reduce((a, b) => a + b) / pacesInSeconds.length;
      }
    }

    if (activityType == ActivityType.riding) {
      final speeds = results
          .map((result) => result.averageSpeedKmh)
          .whereType<double>()
          .toList();
      if (speeds.isNotEmpty) {
        baselines[MissionAxis.speed] =
            speeds.reduce((a, b) => a + b) / speeds.length;
      }
    }

    final routeValues = results
        .expand((result) => result.missions)
        .where((mission) => mission.axis == MissionAxis.routeExploration)
        .map((mission) => mission.currentValue)
        .toList();
    if (routeValues.isNotEmpty) {
      baselines[MissionAxis.routeExploration] =
          routeValues.reduce((a, b) => a + b) / routeValues.length;
    }

    final intervalValues = results
        .expand((result) => result.missions)
        .where((mission) => mission.axis == MissionAxis.interval)
        .map((mission) => mission.currentValue)
        .toList();
    if (intervalValues.isNotEmpty) {
      baselines[MissionAxis.interval] =
          intervalValues.reduce((a, b) => a + b) / intervalValues.length;
    }

    final sprintValues = results
        .expand((result) => result.missions)
        .where((mission) => mission.axis == MissionAxis.sprint)
        .map((mission) => mission.currentValue)
        .toList();
    if (sprintValues.isNotEmpty) {
      baselines[MissionAxis.sprint] =
          sprintValues.reduce((a, b) => a + b) / sprintValues.length;
    }
    return baselines;
  }

  Future<void> _loadBaselines(ActivityType type) async {
    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return;
    }

    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final results = await sessionResultRepository.getRecentResults(
      userId: user.uid,
      activityType: type,
      limit: 5,
    );

    if (state.activityType != type) {
      return;
    }

    switch (results) {
      case Ok(:final value):
        final baselines = _calculateBaselines(type, value);
        state = state.copyWith(baselines: baselines);
      case Error():
        break;
    }
  }

  @override
  SessionStartState build() {
    final initialMissions = MissionTemplate.getTemplatesFor(
      ActivityType.jogging,
    );
    _loadBaselines(ActivityType.jogging);

    return SessionStartState(
      activityType: ActivityType.jogging,
      missions: initialMissions,
      selectedMissionIds: const [],
    );
  }

  void setActivityType(ActivityType type) {
    if (state.activityType == type) {
      return;
    }
    state = state.copyWith(
      activityType: type,
      missions: MissionTemplate.getTemplatesFor(type),
      selectedMissionIds: const [],
    );
    _loadBaselines(type);
  }

  void toggleMission(String templateId) {
    final selected = List<String>.from(state.selectedMissionIds);
    if (selected.contains(templateId)) {
      selected.remove(templateId);
    } else {
      if (selected.length >= 2) {
        selected.removeAt(0);
      }
      selected.add(templateId);
    }
    state = state.copyWith(selectedMissionIds: selected);
  }

  Future<Result<TrackingSession>> startSession(String userId) async {
    state = state.copyWith(isLoading: true);

    final selectedMissions = state.missions
        .where((template) => state.selectedMissionIds.contains(template.id))
        .toList();

    final missions = selectedMissions
        .map(
          (template) => MissionInstance.fromTemplate(
            template: template,
            baselineValue: state.baselines[template.axis],
          ),
        )
        .toList();

    final sessionRepository = ref.read(sessionRepositoryProvider);
    final result = await sessionRepository.startSession(
      userId: userId,
      activityType: state.activityType,
      missions: missions,
    );

    state = state.copyWith(isLoading: false);
    return result;
  }
}

final sessionStartViewModelProvider =
    NotifierProvider<SessionStartViewModel, SessionStartState>(() {
      return SessionStartViewModel();
    });
