import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/notice.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../view_models/admin_viewmodel.dart';
import 'notice_form_dialog.dart';

class NoticeManagementTab extends ConsumerWidget {
  const NoticeManagementTab({super.key});

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Notice notice,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SystemAlertDialog(
          title: '공지사항을 삭제할까요?',
          description:
              '\'${notice.title}\' 공지사항을 정말 삭제하시겠습니까?\n삭제된 공지는 복구할 수 없어요.',
          confirmText: '삭제',
          onConfirm: () => dialogContext.pop(true),
        ),
      ),
    );

    if (confirmed != true) {
      return;
    }

    final result = await ref
        .read(adminViewModelProvider.notifier)
        .deleteNotice(notice.id);

    switch (result) {
      case Ok():
        messenger.showSnackBar(const SnackBar(content: Text('공지사항이 삭제되었습니다.')));
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '공지사항 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  void _openNoticeDialog(BuildContext context, {Notice? notice}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(child: NoticeFormDialog(initialNotice: notice)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final adminState = ref.watch(adminViewModelProvider).requireValue;
    final notices = adminState.notices;
    final isProcessing = adminState.isProcessing;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '등록된 공지사항 (${notices.length}개)',
                style: textTheme.headlineSmall,
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: '새로고침',
                    icon: const Icon(Icons.refresh),
                    onPressed: isProcessing
                        ? null
                        : () => ref
                              .read(adminViewModelProvider.notifier)
                              .refreshNotices(),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('공지사항 등록'),
                    onPressed: isProcessing
                        ? null
                        : () => _openNoticeDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (notices.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Center(
                child: Text(
                  '등록된 공지사항이 없습니다.\n새로운 공지사항을 등록해 보세요.',
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
              itemCount: notices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final Notice notice = notices[index];
                return Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: notice.isImportant
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: notice.isImportant ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (notice.isImportant) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '중요',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                notice.title,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: '수정',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: isProcessing
                                  ? null
                                  : () => _openNoticeDialog(
                                      context,
                                      notice: notice,
                                    ),
                            ),
                            IconButton(
                              tooltip: '삭제',
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () => _handleDelete(context, ref, notice),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notice.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.tertiaryFixed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notice.createdAt.formattedDateDot,
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.tertiaryContainer,
                              ),
                            ),
                            if (notice.actionUrl != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notice.actionButtonText ?? '링크 연결됨',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
