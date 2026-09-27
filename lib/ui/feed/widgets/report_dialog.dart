import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/social/report.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/dialog_action_buttons.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final UserSummary targetUser;
  final UserSummary reporter;
  final String? sketchId;
  final String? commentId;

  const ReportDialog({
    super.key,
    required this.targetUser,
    required this.reporter,
    this.sketchId,
    this.commentId,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  late final TextEditingController _descriptionController;
  ReportType? _reportType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_reportType == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final report = Report.create(
      targetUser: widget.targetUser,
      reporter: widget.reporter,
      reportType: _reportType!,
      sketchId: widget.sketchId,
      commentId: widget.commentId,
      description: _reportType == ReportType.other ? _descriptionController.text : null,
    );

    final result = await ref.read(reportRepositoryProvider).submitReport(report);

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(
        switch (result) {
          Ok() => '신고가 접수되었습니다.',
          Error(:final error) => error is AppException
              ? error.message
              : '신고 접수 중 오류가 발생했습니다.',
        }
      ))
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('신고 사유를 선택해 주세요', style: textTheme.headlineSmall),
          RadioGroup<ReportType>(
            groupValue: _reportType,
            onChanged: (value) {
              setState(() {
                _reportType = value;
              });
            },
            child: Column(
              children: ReportType.values.map((reason) {
                return RadioListTile<ReportType>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colorScheme.primary,
                  title: Text(reason.label, style: textTheme.bodyMedium),
                  value: reason,
                );
              }).toList(),
            ),
          ),
          if (_reportType == ReportType.other)
            TextField(
              maxLength: 60,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '신고 사유를 간략히 적어주세요.',
                hintStyle: textTheme.labelMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 16),
          DialogActionButtons(
            confirmText: '신고하기',
            onCancel: () {
              context.pop();
            },
            onConfirm: _submit,
          ),
        ],
      ),
    );
  }
}
