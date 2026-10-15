import 'package:flutter/foundation.dart';
import '../enums/sync_status.dart';
import 'session_result.dart';

@immutable
class PendingSessionTask {
  final SessionResult sessionResult;
  final Uint8List sketchBytes;
  final SyncStatus syncStatus;
  final int retryCount;

  final DateTime createdAt;
  final DateTime? lastAttemptedAt;
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

  String get sessionId => sessionResult.id;
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
          sessionId == other.sessionId;

  @override
  int get hashCode => sessionId.hashCode;
}
