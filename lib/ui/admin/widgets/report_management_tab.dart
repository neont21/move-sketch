import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/error_retry_view.dart';
import '../view_models/admin_report_viewmodel.dart';
import 'report_detail_dialog.dart';

class ReportManagementTab extends ConsumerWidget {
  const ReportManagementTab({super.key});

  Color _getStatusColor(ReportStatus status, ColorScheme colorScheme) {
    return switch (status) {
      ReportStatus.unconfirmed => colorScheme.error,
      ReportStatus.reviewing => Colors.orange,
      ReportStatus.actionTaken => Colors.teal,
      ReportStatus.noAction => colorScheme.tertiaryContainer,
    };
  }

  void _openDetailDialog(BuildContext context, Report report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ReportDetailDialog(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final reportState = ref.watch(adminReportViewModelProvider);

    return reportState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ErrorRetryView.fromError(
          error: error,
          defaultMessage: '신고 내역을 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(adminReportViewModelProvider),
        ),
      ),
      data: (reportState) {
        final reports = reportState.reports;
        final isProcessing = reportState.isProcessing;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '신고 내역 관리 (${reports.length}건)',
                    style: textTheme.headlineSmall,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ReportStatus?>(
                            value: reportState.statusFilter,
                            hint: const Text('전체 보기'),
                            items: [
                              DropdownMenuItem<ReportStatus?>(
                                value: null,
                                child: Text(
                                  '전체 상태',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              ...ReportStatus.values.map(
                                (status) => DropdownMenuItem<ReportStatus?>(
                                  value: status,
                                  child: Text(
                                    status.label,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: isProcessing
                                ? null
                                : (filter) => ref
                                      .read(
                                        adminReportViewModelProvider.notifier,
                                      )
                                      .setStatusFilter(filter),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '새로고침',
                        icon: const Icon(Icons.refresh),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final result = await ref
                                    .read(adminReportViewModelProvider.notifier)
                                    .refreshReports();
                                if (!context.mounted) return;
                                switch (result) {
                                  case Ok():
                                    break;
                                  case Error(:final error):
                                    final String message = error is AppException
                                        ? error.message
                                        : '신고 목록 새로고침 중 오류가 발생했습니다.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: colorScheme.error,
                                      ),
                                    );
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (reports.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: Text(
                      '조건에 해당하는 신고 내역이 없습니다.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.tertiaryContainer,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final statusColor = _getStatusColor(
                      report.status,
                      colorScheme,
                    );

                    return Card(
                      elevation: 0,
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openDetailDialog(context, report),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: statusColor.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      report.status.label,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    report.reportType.label,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.tertiary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${report.createdAt.formattedDateDot} ${report.createdAt.formattedTime}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.tertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '대상: ${report.targetUser.nickname} (@${report.targetUser.username}) · 신고자: ${report.reporter.nickname}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (report.reportType == ReportType.other ||
                                  (report.description != null &&
                                      report.description!.trim().isNotEmpty))
                                Text(
                                  (report.description != null &&
                                          report.description!.trim().isNotEmpty)
                                      ? '사유: ${report.description}'
                                      : '사유: (입력된 상세 사유 없음)',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiaryFixed,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
