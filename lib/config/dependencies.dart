import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/friendship/friendship_repository.dart';
import '../data/repositories/friendship/friendship_repository_remote.dart';
import '../data/repositories/location/location_repository.dart';
import '../data/repositories/location/location_repository_local.dart';
import '../data/repositories/notification/notification_repository.dart';
import '../data/repositories/notification/notification_repository_remote.dart';
import '../data/repositories/session/session_repository.dart';
import '../data/repositories/session/session_repository_local.dart';
import '../data/repositories/session_result/session_result_repository.dart';
import '../data/repositories/session_result/session_result_repository_remote.dart';
import '../data/repositories/sketch_post/sketch_post_repository.dart';
import '../data/repositories/sketch_post/sketch_post_repository_remote.dart';
import '../data/repositories/user/user_repository.dart';
import '../data/repositories/user/user_repository_remote.dart';
import '../data/repositories/weather/weather_repository.dart';
import '../data/repositories/weather/weather_repository_remote.dart';

import '../data/services/hardware/location_service.dart';
import '../data/services/local/database/app_database.dart';
import '../data/services/local/session_service.dart';
import '../data/services/remote/auth_service.dart';
import '../data/services/remote/firestore/friendship_service.dart';
import '../data/services/remote/firestore/notification_service.dart';
import '../data/services/remote/firestore/session_result_service.dart';
import '../data/services/remote/firestore/sketch_post_service.dart';
import '../data/services/remote/firestore/user_service.dart';
import '../data/services/remote/storage_service.dart';
import '../data/services/remote/weather_service.dart';

import '../domain/use_cases/session/complete_session_use_case.dart';

/// 외부 REST API 통신을 위한 Provider
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);

  return client;
});

/// 로컬 DB Provider: 오프라인 세션 트래킹 데이터 저장
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);

  return database;
});


/// SessionService Provider: 로컬 운동 세션 및 GPS 좌표 입출력
final sessionServiceProvider = Provider<SessionService>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return SessionService(db.sessionDao);
});

/// AuthService Provider: Firebase Authentication 기반 계정 관리
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// UserService Provider: Firestore 기반 사용자 프로필, 계정 검색 관리
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// StorageService Provider: Firebase Storage 기반 이미지 URL 관리
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// FriendshipService Provider: Firestore 기반 친구 요청, 목록, 차단 관리
final friendshipServiceProvider = Provider<FriendshipService>((ref) {
  return FriendshipService();
});

/// SessionResultService Provider: Firestore 기반 세션 완료 후 기록 관리
final sessionResultServiceProvider = Provider<SessionResultService>((ref) {
  return SessionResultService();
});

/// WeatherService Provider: OpenWeatherMap 기반 현재 위치 날씨 정보 조회
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(client: ref.watch(httpClientProvider));
});

/// LocationService Provider: 위치 권한 및 GPS 좌표 수집
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// SketchPostService Provider: Firestore 기반 스케치와 응원 및 댓글 관리
final sketchPostServiceProvider = Provider<SketchPostService>((ref) {
  return SketchPostService();
});

/// NotificationService Provider: Firestore 기반 알림 소셜 활동 알림 관리
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});


/// AuthRepository Provider: 계정 인증 및 세션 관리 저장소
/// 아이디 기반 로그인 및 자동 사용자 정보 매핑 제공
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryRemote(
    authService: ref.watch(authServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

/// UserRepository Provider: 사용자 프로필 및 계정 설정 저장소
/// 프로필 수정, 이미지 업로드, 캐릭터 변경, 알림 설정 및 사용자 검색 총괄
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryRemote(
    authService: ref.watch(authServiceProvider),
    userService: ref.watch(userServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    friendshipService: ref.watch(friendshipServiceProvider),
  );
});

/// SessionRepository Provider: 실시간 운동 세션 추적 저장소
/// 네트워크가 불안정한 야외 운동 환경을 위해 로컬 DB를 단일 진실 공급원으로 사용
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryLocal(
    sessionService: ref.watch(sessionServiceProvider),
  );
});

/// SessionResultRepository Provider: 완료된 운동 세션 결과물 저장소
/// 세션 통계 데이터와 이미지를 원격 저장소에 보관하고 개인 캘린더 기록 제공
final sessionResultRepositoryProvider = Provider<SessionResultRepository>((ref) {
  return SessionResultRepositoryRemote(
    sessionResultService: ref.watch(sessionResultServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    sketchPostService: ref.watch(sketchPostServiceProvider),
  );
});

/// WeatherRepository Provider: 기상 상태 및 운동 적합도 저장소
/// 위도/경도를 기반으로 날씨 정보를 조회하고 앱 도메인 모델로 변환
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryRemote(
    weatherService: ref.watch(weatherServiceProvider),
  );
});

/// LocationRepository Provider: 기기 위치 센서 및 GPS 좌표 관리 저장소
/// 위치 권한 검증 및 1회성 현재 좌표 조회, 실시간 조깅 경로 추적 스트림 제공
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryLocal(
    locationService: ref.watch(locationServiceProvider),
  );
});

/// SketchPostRepository Provider: 피드 스케치 공유 및 소셜 인터랙션 저장소
/// 공개 스케치 피드 무한 스크롤, 스케치 응원 카운팅, 댓글 관리 기능 제공
final sketchPostRepositoryProvider = Provider<SketchPostRepository>((ref) {
  return SketchPostRepositoryRemote(
    sketchPostService: ref.watch(sketchPostServiceProvider),
    friendshipService: ref.watch(friendshipServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

/// FriendshipRepository Provider: 친구 관계망 및 차단 관리 저장소
/// 친구 목록 조회, 친구 요청 신청/수락/거절 및 유저 차단 정책 제어
final friendshipRepositoryProvider = Provider<FriendshipRepository>((ref) {
  return FriendshipRepositoryRemote(
    friendshipService: ref.watch(friendshipServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

/// NotificationRepository Provider: 앱 내 알림 목록 및 읽음 상태 저장소
/// 스케치 응원, 새 댓글, 친구 요청 등 소셜 활동 알림을 페이징 조회하고 읽음 및 삭제 처리
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryRemote(
    notificationService: ref.watch(notificationServiceProvider),
  );
});

/// CompleteSessionUseCase Provider: 운동 세션 완료 절차 조율하는 복합 UseCase
/// 세션 완료 처리 후 원격 저장 성공 시 로컬 임시 세션 데이터 삭제
final completeSessionUseCaseProvider = Provider<CompleteSessionUseCase>((ref) {
  return CompleteSessionUseCase(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    sessionResultRepository: ref.watch(sessionResultRepositoryProvider),
  );
});