import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class SessionShareState {
  final SessionResult? sessionResult;
  final SketchPost? existingPost;
  final CharacterType character;
  final List<String> locationTags;
  final int locationIndex;
  final WeatherInfo? weatherInfo;
  final String caption;
  final bool isEdit;
  final bool isPublishing;

  const SessionShareState({
    this.sessionResult,
    this.existingPost,
    this.locationTags = const ['위치 확인 중', '위치 확인 중', '위치 확인 중'],
    this.locationIndex = 0,
    this.character = CharacterType.bear,
    this.weatherInfo,
    this.caption = '',
    this.isEdit = false,
    this.isPublishing = false,
  });

  SessionShareState copyWith({
    SessionResult? sessionResult,
    SketchPost? existingPost,
    CharacterType? character,
    List<String>? locationTags,
    int? locationIndex,
    WeatherInfo? weatherInfo,
    String? caption,
    bool? isEdit,
    bool? isPublishing,
  }) {
    return SessionShareState(
      sessionResult: sessionResult ?? this.sessionResult,
      existingPost: existingPost ?? this.existingPost,
      character: character ?? this.character,
      locationTags: locationTags ?? this.locationTags,
      locationIndex: locationIndex ?? this.locationIndex,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      caption: caption ?? this.caption,
      isEdit: isEdit ?? this.isEdit,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }
}

class SessionShareViewModel extends AsyncNotifier<SessionShareState> {
  final String sessionId;

  SessionShareViewModel(this.sessionId);

  @override
  Future<SessionShareState> build() async {
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final geocodingRepository = ref.read(geocodingRepositoryProvider);
    final weatherRepository = ref.read(weatherRepositoryProvider);

    final (user, result, post) = await (
      ref.read(authViewModelProvider.future),
      sessionResultRepository.getResultById(sessionId),
      sketchPostRepository.getPostById(sessionId),
    ).wait;

    final character = user?.selectedCharacter ?? CharacterType.bear;

    final sessionResult = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };

    final sketchPost = switch (post) {
      Ok(:final value) => value,
      Error() => null,
    };

    if (sessionResult == null && sketchPost == null) {
      throw const SessionException('세션 결과 정보를 불러올 수 없습니다.');
    }

    final isEdit = sketchPost != null || (sessionResult?.isShared ?? false);

    List<String> locationTags;
    int selectedIndex = 0;

    if (sketchPost != null && sketchPost.locationTags.length == 3) {
      locationTags = sketchPost.locationTags;
      selectedIndex = sketchPost.locationIndex;
    } else if (sessionResult != null &&
        sessionResult.locationTags.length == 3 &&
        !sessionResult.locationTags.any((t) => t == '알 수 없는 위치')) {
      locationTags = sessionResult.locationTags;
    } else if (sessionResult != null) {
      final startTag = await geocodingRepository.reverseGeocode(
        latitude: sessionResult.startLocation.latitude,
        longitude: sessionResult.startLocation.longitude,
      );
      final waypointTag = await geocodingRepository.reverseGeocode(
        latitude: sessionResult.waypoint.latitude,
        longitude: sessionResult.waypoint.longitude,
      );
      final isRoundTrip =
          (sessionResult.startLocation.latitude -
                      sessionResult.endLocation.latitude)
                  .abs() <
              0.0005 &&
          (sessionResult.startLocation.longitude -
                      sessionResult.endLocation.longitude)
                  .abs() <
              0.0005;
      final endTag = isRoundTrip
          ? startTag
          : await geocodingRepository.reverseGeocode(
              latitude: sessionResult.endLocation.latitude,
              longitude: sessionResult.endLocation.longitude,
            );
      locationTags = [startTag, waypointTag, endTag];
    } else {
      locationTags = const ['알 수 없는 위치', '알 수 없는 위치', '알 수 없는 위치'];
    }

    WeatherInfo? weatherInfo = sketchPost?.weather;
    if (weatherInfo == null && sessionResult != null) {
      final weatherOutcome = await weatherRepository.getCurrentWeather(
        latitude: sessionResult.endLocation.latitude,
        longitude: sessionResult.endLocation.longitude,
      );
      if (weatherOutcome case Ok(:final value)) {
        weatherInfo = value;
      }
    }

    return SessionShareState(
      sessionResult: sessionResult,
      existingPost: sketchPost,
      character: character,
      locationTags: locationTags,
      locationIndex: selectedIndex,
      weatherInfo: weatherInfo,
      caption: sketchPost?.caption ?? '',
      isEdit: isEdit,
    );
  }

  void selectTag(int index) {
    state = state.whenData((current) => current.copyWith(locationIndex: index));
  }

  void updateCaption(String text) {
    state = state.whenData((current) => current.copyWith(caption: text));
  }

  Future<Result<void>> publishPost() async {
    final current = state.value;
    if (current == null || current.isPublishing) {
      return const Result.error(SessionException('처리 중입니다.'));
    }

    state = AsyncData(current.copyWith(isPublishing: true));

    try {
      final sketchPostRepository = ref.read(sketchPostRepositoryProvider);

      if (current.isEdit) {
        final updateResult = await sketchPostRepository.updatePost(
          sketchId: sessionId,
          caption: current.caption,
          locationIndex: current.locationIndex,
          weather: current.weatherInfo,
        );

        state = AsyncData(current.copyWith(isPublishing: false));
        return switch (updateResult) {
          Ok() => const Result.ok(null),
          Error(:final error) => Result.error(error),
        };
      } else {
        final user = await ref.read(authViewModelProvider.future);
        if (user == null) {
          state = AsyncData(current.copyWith(isPublishing: false));
          return const Result.error(AuthException('사용자 정보를 찾을 수 없습니다.'));
        }

        final sessionResult = current.sessionResult;
        if (sessionResult == null) {
          state = AsyncData(current.copyWith(isPublishing: false));
          return const Result.error(SessionException('세션 결과 데이터가 없습니다.'));
        }

        final post = SketchPost(
          id: sessionResult.id,
          authorId: user.uid,
          author: user.toSummary(),
          sketchUrl: sessionResult.resultSketchImageUrl ?? '',
          caption: current.caption.trim().isEmpty
              ? null
              : current.caption.trim(),
          locationTags: current.locationTags,
          locationIndex: current.locationIndex,
          weather: current.weatherInfo,
          activityType: sessionResult.activityType,
          createdAt: DateTime.now(),
        );

        final createResult = await sketchPostRepository.createPost(post);
        switch (createResult) {
          case Ok():
            await ref
                .read(sessionResultRepositoryProvider)
                .updateShareStatus(sessionId: sessionResult.id, isShared: true);
            state = AsyncData(current.copyWith(isPublishing: false));
            return const Result.ok(null);
          case Error(:final error):
            state = AsyncData(current.copyWith(isPublishing: false));
            return Result.error(error);
        }
      }
    } catch (e) {
      state = AsyncData(current.copyWith(isPublishing: false));
      return Result.error(SessionException('피드 등록 중 오류가 발생했습니다.', cause: e));
    }
  }
}

final sessionShareViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<SessionShareViewModel, SessionShareState, String>(
      (sessionId) => SessionShareViewModel(sessionId),
    );
