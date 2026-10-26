import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../view_models/admin_report_viewmodel.dart';

class ReportDetailDialog extends ConsumerStatefulWidget {
  final Report report;

  const ReportDetailDialog({super.key, required this.report});

  @override
  ConsumerState<ReportDetailDialog> createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends ConsumerState<ReportDetailDialog> {
  late ReportStatus _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(adminReportViewModelProvider.notifier)
        .updateStatus(widget.report.id, _selectedStatus);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    switch (result) {
      case Ok():
        context.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('신고 조치 상태가 저장되었습니다.')),
        );
      case Error(:final error):
        final message = error is AppException
            ? error.message
            : '신고 상태 갱신 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final report = widget.report;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('신고 접수 상세 정보', style: textTheme.headlineSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    '접수 일시: ${report.createdAt.formattedDateDot} ${report.createdAt.formattedTime}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                  Text(
                    '신고자: ${report.reporter.nickname} (@${report.reporter.username})',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                  Text(
                    '신고 대상: ${report.targetUser.nickname} (@${report.targetUser.username})',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '신고 유형: ${report.reportType.label}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                  if (report.sketchId != null)
                    Text(
                      '대상 스케치 ID: ${report.sketchId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.tertiaryFixed,
                      ),
                    ),
                  if (report.commentId != null)
                    Text(
                      '대상 댓글 ID: ${report.commentId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.tertiaryFixed,
                      ),
                    ),
                ],
              ),
            ),
            if (report.reportType == ReportType.other ||
                (report.description != null && report.description!.trim().isNotEmpty))
              TextFormField(
                initialValue: (report.description != null &&
                    report.description!.trim().isNotEmpty)
                    ? report.description
                    : '(입력된 상세 사유가 없습니다)',
                readOnly: true,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '신고 상세 사유',
                  alignLabelWithHint: true,
                ),
              ),
            DropdownButtonFormField<ReportStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: '처리 상태 *'),
              items: ReportStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label, style: textTheme.bodyLarge,),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (newStatus) {
                      if (newStatus != null) {
                        setState(() => _selectedStatus = newStatus);
                      }
                    },
            ),
            const SizedBox(height: 4),
            DialogActionButtons(
              cancelText: '닫기',
              confirmText: _isSubmitting ? '저장 중...' : '저장하기',
              onCancel: () => context.pop(),
              onConfirm: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
