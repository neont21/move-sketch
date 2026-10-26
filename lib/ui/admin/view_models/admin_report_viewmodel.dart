import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

@immutable
final class AdminReportState {
  final List<Report> reports;
  final ReportStatus? statusFilter;
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

final adminReportViewModelProvider =
    AsyncNotifierProvider.autoDispose<AdminReportViewModel, AdminReportState>(
      () {
        return AdminReportViewModel();
      },
    );
