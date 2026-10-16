import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../data/repositories/network/network_connectivity_repository.dart';
import '../../../data/repositories/session/offline_session_repository.dart';
import '../../../domain/use_cases/session/sync_pending_sessions_use_case.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
final class SessionSyncState {
  final int pendingCount;
  final bool isSyncing;
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

  void _listenToPendingCount(String userId) {
    _pendingCountSubscription = _offlineSessionRepository
        .watchPendingCount(userId)
        .listen((count) {
          state = state.copyWith(pendingCount: count);
        });
  }

  void _listenToConnectivity(String userId) {
    _connectivitySubscription = _networkConnectivityRepository
        .onConnectivityChanged
        .listen((isConnected) {
          if (isConnected) {
            sync(userId);
          }
        });
  }

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

final sessionSyncViewModelProvider =
    NotifierProvider<SessionSyncViewModel, SessionSyncState>(() {
      return SessionSyncViewModel();
    });
