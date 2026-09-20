import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/dialog_action_buttons.dart';

enum ReportReason {
  inappropriateProfile('부적절한 프로필'),
  harassment('욕설, 비하 또는 괴롭힘'),
  spam('스팸 또는 홍보'),
  other('기타');

  final String label;

  const ReportReason(this.label);
}

class ReportDialog extends StatefulWidget {
  final String userId;
  final String targetUserId;
  final String? sketchId;
  final String? commentId;

  const ReportDialog({
    super.key,
    required this.userId,
    required this.targetUserId,
    this.sketchId,
    this.commentId,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;

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
          RadioGroup<ReportReason>(
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            child: Column(
              children: ReportReason.values.map((reason) {
                return RadioListTile<ReportReason>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colorScheme.primary,
                  title: Text(reason.label, style: textTheme.bodyMedium),
                  value: reason,
                );
              }).toList(),
            ),
          ),
          if (_selectedReason == ReportReason.other)
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
            onConfirm: () {
              context.pop();
              // TODO implement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('신고가 접수되었습니다.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
