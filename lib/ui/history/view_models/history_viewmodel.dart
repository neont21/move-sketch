import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../home/view_models/home_viewmodel.dart';

@immutable
class HistoryState {
  final DateTime focusedMonth;
  final List<SessionResult> results;
  final bool isLoading;

  const HistoryState({
    required this.focusedMonth,
    this.results = const [],
    this.isLoading = false,
  });

  Set<int> get dayJogging => results
      .where((r) => r.activityType == ActivityType.jogging)
      .map((r) => r.endedAt.day)
      .toSet();

  Set<int> get dayRiding => results
      .where((r) => r.activityType == ActivityType.riding)
      .map((r) => r.endedAt.day)
      .toSet();

  HistoryState copyWith({
    DateTime? focusedMonth,
    List<SessionResult>? results,
    bool? isLoading,
  }) {
    return HistoryState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistoryViewModel extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final now = DateTime.now();
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.getResultsByMonth(
      userId: user.uid,
      year: now.year,
      month: now.month,
    );

    switch (result) {
      case Ok(:final value):
        return HistoryState(
          focusedMonth: DateTime(now.year, now.month),
          results: value,
        );
      case Error(:final error):
        throw error;
    }
  }

  Future<void> changeMonth(DateTime newMonth) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.focusedMonth.year == newMonth.year &&
        current.focusedMonth.month == newMonth.month) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        focusedMonth: DateTime(newMonth.year, newMonth.month),
        isLoading: true,
      ),
    );

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      state = AsyncData(current.copyWith(isLoading: false));
      return;
    }

    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.getResultsByMonth(
      userId: user.uid,
      year: newMonth.year,
      month: newMonth.month,
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(
            focusedMonth: DateTime(newMonth.year, newMonth.month),
            results: value,
            isLoading: false,
          ),
        );

      case Error():
        state = AsyncData(current.copyWith(isLoading: false));
    }
  }

  Future<Result<void>> deleteHistory(
    String sessionId, {
    required bool deletePostIfShared,
  }) async {
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.deleteResult(
      sessionId,
      deletePostIfShared: deletePostIfShared,
    );

    switch (result) {
      case Ok():
        ref.invalidate(homeViewModelProvider);
        state = state.whenData((current) {
          return current.copyWith(
            results: current.results
                .where((result) => result.id != sessionId)
                .toList(),
          );
        });
      case Error():
        break;
    }

    return result;
  }
}

final historyViewModelProvider =
    AsyncNotifierProvider<HistoryViewModel, HistoryState>(() {
      return HistoryViewModel();
    });
