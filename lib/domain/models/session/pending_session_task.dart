import 'package:flutter/foundation.dart';

import '../enums/sync_status.dart';
import 'session_result.dart';

/// 오프라인 또는 네트워크 단절 환경에서 생성되어 서버 동기화를 대기하는 세션 업로드 작업을 나타내는 불변 모델입니다.
@immutable
class PendingSessionTask {
  /// 서버로 전송할 완성된 운동 세션 결과 모델.
  final SessionResult sessionResult;

  /// 서버 스토리지 업로드를 대기하는 완성 스케치 이미지 바이너리 데이터.
  final Uint8List sketchBytes;

  /// 현재 원격 서버 동기화 처리 상태.
  final SyncStatus syncStatus;

  /// 동기화 실패 후 재시도한 누적 횟수.
  final int retryCount;

  /// 오프라인 대기 작업이 최초 생성된 일시.
  final DateTime createdAt;

  /// 가장 최근에 동기화를 시도한 일시.
  final DateTime? lastAttemptedAt;

  /// 최근 동기화 시도 실패 시 발생한 오류 원인 메시지.
  final String? errorMessage;

  const PendingSessionTask({
    required this.sessionResult,
    required this.sketchBytes,
    required this.syncStatus,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptedAt,
    this.errorMessage,
  });

  /// 연계된 세션의 고유 식별자.
  String get sessionId => sessionResult.id;

  /// 세션을 소유한 사용자의 고유 식별자.
  String get userId => sessionResult.userId;

  PendingSessionTask copyWith({
    SessionResult? sessionResult,
    Uint8List? sketchBytes,
    SyncStatus? syncStatus,
    int? retryCount,
    DateTime? createdAt,
    ValueGetter<DateTime?>? lastAttemptedAt,
    ValueGetter<String?>? errorMessage,
  }) {
    return PendingSessionTask(
      sessionResult: sessionResult ?? this.sessionResult,
      sketchBytes: sketchBytes ?? this.sketchBytes,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: lastAttemptedAt != null
          ? lastAttemptedAt()
          : this.lastAttemptedAt,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSessionTask &&
          runtimeType == other.runtimeType &&
          sessionResult == other.sessionResult &&
          listEquals(sketchBytes, other.sketchBytes) &&
          syncStatus == other.syncStatus &&
          retryCount == other.retryCount &&
          createdAt == other.createdAt &&
          lastAttemptedAt == other.lastAttemptedAt &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    sessionResult,
    Object.hashAll(sketchBytes),
    syncStatus,
    retryCount,
    createdAt,
    lastAttemptedAt,
    errorMessage,
  );
}
