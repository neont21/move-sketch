import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../data/repositories/network/network_connectivity_repository.dart';
import '../../../data/repositories/session/offline_session_repository.dart';
import '../../../domain/use_cases/session/sync_pending_sessions_use_case.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

/// 오프라인 대기 세션의 잔여 건수, 동기화 진행 여부 및 최근 완료 건수를 보관하는 불변 상태 모델입니다.
@immutable
final class SessionSyncState {
  /// 로컬 큐에 남아 있는 동기화 대기 세션 건수.
  final int pendingCount;

  /// 현재 백그라운드 동기화가 진행 중인지 여부.
  final bool isSyncing;

  /// 가장 최근 동기화 실행에서 서버로 업로드된 세션 건수.
  final int? lastSyncedCount;

  const SessionSyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncedCount,
  });

  SessionSyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    ValueGetter<int?>? lastSyncedCount,
  }) {
    return SessionSyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedCount: lastSyncedCount != null
          ? lastSyncedCount()
          : this.lastSyncedCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionSyncState &&
          runtimeType == other.runtimeType &&
          pendingCount == other.pendingCount &&
          isSyncing == other.isSyncing &&
          lastSyncedCount == other.lastSyncedCount;

  @override
  int get hashCode => Object.hash(pendingCount, isSyncing, lastSyncedCount);
}

/// 로컬 오프라인 세션 대기열 감시 및 네트워크 복구 시 자동 백그라운드 동기화를 수행하는 ViewModel입니다.
final class SessionSyncViewModel extends Notifier<SessionSyncState> {
  NetworkConnectivityRepository get _networkConnectivityRepository =>
      ref.read(networkConnectivityRepositoryProvider);
  OfflineSessionRepository get _offlineSessionRepository =>
      ref.read(offlineSessionRepositoryProvider);
  SyncPendingSessionsUseCase get _syncPendingSessionsUseCase =>
      ref.read(syncPendingSessionsUseCaseProvider);

  StreamSubscription<int>? _pendingCountSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  SessionSyncState build() {
    ref.onDispose(() {
      _pendingCountSubscription?.cancel();
      _pendingCountSubscription = null;
      _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
    });

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const SessionSyncState(pendingCount: 0, isSyncing: false);
    }

    _listenToPendingCount(currentUser.uid);
    _listenToConnectivity(currentUser.uid);

    return const SessionSyncState();
  }

  // 로컬 DB의 동기화 대기 세션 건수 스트림을 구독해 상태를 실시간 갱신합니다.
  void _listenToPendingCount(String userId) {
    _pendingCountSubscription = _offlineSessionRepository
        .watchPendingCount(userId)
        .listen((count) {
          state = state.copyWith(pendingCount: count);
        });
  }

  // 네트워크 연결이 복구되는 시점을 감지해 오프라인 대기 세션 동기화를 자동 실행합니다.
  void _listenToConnectivity(String userId) {
    _connectivitySubscription = _networkConnectivityRepository
        .onConnectivityChanged
        .listen((isConnected) {
          if (isConnected) {
            sync(userId);
          }
        });
  }

  /// 대기 중인 오프라인 세션을 원격 서버와 동기화하고 성공한 건수를 반환합니다.
  Future<Result<int>> sync([String? targetUserId]) async {
    final userId = targetUserId ?? ref.read(currentUserProvider)?.uid;
    if (userId == null || state.isSyncing) {
      return const Result.ok(0);
    }
    state = state.copyWith(isSyncing: true);
    try {
      final syncResult = await _syncPendingSessionsUseCase.execute(userId);
      switch (syncResult) {
        case Ok(:final value):
          if (value > 0) {
            state = state.copyWith(lastSyncedCount: () => value);
          }
          return syncResult;
        case Error():
          return syncResult;
      }
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }
}

/// [SessionSyncViewModel] 상태를 제공하는 전역 [NotifierProvider].
final sessionSyncViewModelProvider =
    NotifierProvider<SessionSyncViewModel, SessionSyncState>(() {
      return SessionSyncViewModel();
    });
