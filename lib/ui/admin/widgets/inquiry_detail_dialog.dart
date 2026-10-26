import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../view_models/admin_inquiry_viewmodel.dart';

class InquiryDetailDialog extends ConsumerStatefulWidget {
  final Inquiry inquiry;

  const InquiryDetailDialog({super.key, required this.inquiry});

  @override
  ConsumerState<InquiryDetailDialog> createState() =>
      _InquiryDetailDialogState();
}

class _InquiryDetailDialogState extends ConsumerState<InquiryDetailDialog> {
  late InquiryStatus _selectedStatus;
  late final TextEditingController _noteController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.inquiry.status;
    _noteController = TextEditingController(
      text: widget.inquiry.adminNote ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();

    super.dispose();
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
        .read(adminInquiryViewModelProvider.notifier)
        .updateStatus(
          widget.inquiry.id,
          _selectedStatus,
          adminNote: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

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
          const SnackBar(content: Text('제보 대응 상태가 저장되었습니다.')),
        );
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '상태 갱신 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final inquiry = widget.inquiry;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제보 상세 정보', style: textTheme.headlineSmall),

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
                spacing: 4,
                children: [
                  Text(
                    '제보 일시: ${inquiry.createdAt.formattedDateDot} ${inquiry.createdAt.formattedTime}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                  Text(
                    '작성자: ${inquiry.userEmail ?? inquiry.userId ?? '비회원'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                  Text(
                    '환경: ${inquiry.deviceInfo.deviceModel} · ${inquiry.deviceInfo.osVersion} · ${inquiry.deviceInfo.appVersion}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiaryFixed,
                    ),
                  ),
                ],
              ),
            ),

            TextFormField(
              initialValue: inquiry.content,
              readOnly: true,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: '제보 내용',
                alignLabelWithHint: true,
              ),
            ),

            if (inquiry.imageUrls.isNotEmpty) ...[
              Text(
                '첨부 사진 (${inquiry.imageUrls.length}장)',
                style: textTheme.labelLarge,
              ),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: inquiry.imageUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = inquiry.imageUrls[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 84,
                          height: 84,
                          color: colorScheme.surface,
                          child: const Icon(Icons.broken_image, size: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            DropdownButtonFormField<InquiryStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: '대응 상태 *'),
              items: InquiryStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label, style: textTheme.bodyLarge,),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (newStatus) {
                      if (newStatus != null) {
                        setState(() {
                          _selectedStatus = newStatus;
                        });
                      }
                    },
            ),

            TextFormField(
              controller: _noteController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '관리자 메모 (내부 기록용)',
                hintText: '원인 파악 내용, Jira/이슈 링크, 조치 내역을 입력하세요',
                alignLabelWithHint: true,
              ),
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
