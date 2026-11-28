import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

/// 관리자 신고 관리 탭의 목록, 상태 필터 및 처리 중 여부를 보관하는 불변 상태 모델입니다.
@immutable
final class AdminReportState {
  /// 조회된 신고 내역 목록.
  final List<Report> reports;

  /// 현재 적용 중인 신고 처리 상태 필터.
  final ReportStatus? statusFilter;

  /// 상태 변경 등 비동기 작업 진행 중 여부.
  final bool isProcessing;

  const AdminReportState({
    this.reports = const [],
    this.statusFilter,
    this.isProcessing = false,
  });

  AdminReportState copyWith({
    List<Report>? reports,
    ReportStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isProcessing,
  }) {
    return AdminReportState(
      reports: reports ?? this.reports,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// 관리자 콘솔에서 접수된 신고 내역을 조회하고 처리 상태를 갱신하는 ViewModel입니다.
final class AdminReportViewModel extends AsyncNotifier<AdminReportState> {
  @override
  Future<AdminReportState> build() async {
    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.getReports();

    switch (result) {
      case Ok(:final value):
        return AdminReportState(reports: value);
      case Error(:final error):
        throw error;
    }
  }

  /// 신고 상태 필터([filter])를 변경하고 해당 조건으로 목록을 재조회합니다.
  Future<void> setStatusFilter(ReportStatus? filter) async {
    state = const AsyncLoading();

    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.getReports(statusFilter: filter);

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          AdminReportState(reports: value, statusFilter: filter),
        );
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
    }
  }

  /// 현재 선택된 필터([AdminReportState.statusFilter]) 기준으로 신고 목록을 다시 조회합니다.
  Future<Result<void>> refreshReports() async {
    final currentFilter = state.value?.statusFilter;

    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.getReports(
      statusFilter: currentFilter,
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          AdminReportState(reports: value, statusFilter: currentFilter),
        );
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  /// 지정된 신고([reportId])의 처리 상태([newStatus])를 갱신합니다.
  Future<Result<void>> updateStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(
        ValidationException('신고 목록이 로드되지 않아 상태를 갱신할 수 없습니다.'),
      );
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final repository = ref.read(reportRepositoryProvider);
    final result = await repository.updateReportStatus(reportId, newStatus);

    switch (result) {
      case Ok():
        final List<Report> updatedList = current.reports.map((report) {
          if (report.id == reportId) {
            return report.copyWith(status: newStatus);
          }
          return report;
        }).toList();

        state = AsyncData(
          current.copyWith(reports: updatedList, isProcessing: false),
        );
      case Error():
        state = AsyncData(current.copyWith(isProcessing: false));
    }
    return result;
  }
}

/// [AdminReportViewModel] 상태를 제공하는 자동 해제 [AsyncNotifierProvider].
final adminReportViewModelProvider =
    AsyncNotifierProvider.autoDispose<AdminReportViewModel, AdminReportState>(
      () {
        return AdminReportViewModel();
      },
    );
