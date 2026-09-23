import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class HomeState {
  final WeatherInfo? weatherInfo;
  final SessionResult? latestResult;
  final List<bool> weeklyIndicator;
  final TrackingSession? uncompletedSession;

  const HomeState({
    this.weatherInfo,
    this.latestResult,
    this.weeklyIndicator = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    this.uncompletedSession,
  });

  HomeState copyWith({
    ValueGetter<WeatherInfo?>? weatherInfo,
    ValueGetter<SessionResult?>? latestResult,
    List<bool>? weeklyIndicator,
    ValueGetter<TrackingSession?>? uncompletedSession,
  }) {
    return HomeState(
      weatherInfo: weatherInfo != null ? weatherInfo() : this.weatherInfo,
      latestResult: latestResult != null ? latestResult() : this.latestResult,
      weeklyIndicator: weeklyIndicator ?? this.weeklyIndicator,
      uncompletedSession: uncompletedSession != null
          ? uncompletedSession()
          : this.uncompletedSession,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  Future<WeatherInfo?> _fetchWeather() async {
    final locationRepository = ref.read(locationRepositoryProvider);
    final weatherRepository = ref.read(weatherRepositoryProvider);

    double latitude;
    double longitude;

    final locationResult = await locationRepository.getCurrentLocation();
    switch (locationResult) {
      case Ok(:final value):
        latitude = value.latitude;
        longitude = value.longitude;
      case Error():
        latitude = 37.5665;
        longitude = 126.9780;
    }

    final weatherResult = await weatherRepository.getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    return switch (weatherResult) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

  Future<SessionResult?> _fetchLatestResult(String userId) async {
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.getLatestResult(userId);

    return switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

  Future<List<bool>> _fetchWeeklyIndicator(String userId) async {
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.getWeeklyCompletionStatus(
      userId,
    );

    return switch (result) {
      Ok(:final value) => value,
      Error() => const [false, false, false, false, false, false, false],
    };
  }

  Future<TrackingSession?> _fetchUncompletedSession() async {
    final sessionRepository = ref.read(sessionRepositoryProvider);
    final result = await sessionRepository.getActiveSession();

    return switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

  Future<void> _loadRemoteData(String userId) async {
    unawaited(() async {
      final (latestResult, weeklyIndicator) = await (
      _fetchLatestResult(userId),
      _fetchWeeklyIndicator(userId),
      ).wait;
      state = state.whenData(
            (current) => current.copyWith(
          latestResult: () => latestResult,
          weeklyIndicator: weeklyIndicator,
        ),
      );
    }());

    unawaited(() async {
      final weatherInfo = await _fetchWeather();
      state = state.whenData(
          (current) => current.copyWith(
            weatherInfo: () => weatherInfo,
          ),
      );
    }());
  }

  @override
  Future<HomeState> build() async {
    final user = await ref.watch(authViewModelProvider.future);

    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final uncompletedSession = await _fetchUncompletedSession();

    _loadRemoteData(user.uid);

    return HomeState(uncompletedSession: uncompletedSession);
  }

  Future<void> discardActiveSession(String sessionId) async {
    final sessionRepository = ref.read(sessionRepositoryProvider);
    final result = await sessionRepository.discardSession(sessionId);

    switch (result) {
      case Ok():
        state = state.whenData(
          (current) => current.copyWith(uncompletedSession: () => null),
        );
      case Error():
        break;
    }
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  () {
    return HomeViewModel();
  },
);
