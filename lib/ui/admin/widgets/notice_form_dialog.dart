import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/notice.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/simple_binary_toggle.dart';
import '../view_models/admin_viewmodel.dart';

class NoticeFormDialog extends ConsumerStatefulWidget {
  final Notice? initialNotice;

  const NoticeFormDialog({super.key, this.initialNotice});

  @override
  ConsumerState<NoticeFormDialog> createState() => _NoticeFormDialogState();
}

class _NoticeFormDialogState extends ConsumerState<NoticeFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _actionUrlController;
  late final TextEditingController _actionButtonTextController;

  late bool _isImportant;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialNotice != null;

  @override
  void initState() {
    super.initState();

    final Notice? notice = widget.initialNotice;

    _titleController = TextEditingController(text: notice?.title ?? '');
    _contentController = TextEditingController(text: notice?.content ?? '');
    _actionUrlController = TextEditingController(text: notice?.actionUrl ?? '');
    _actionButtonTextController = TextEditingController(
      text: notice?.actionButtonText ?? '',
    );

    _isImportant = notice?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _actionUrlController.dispose();
    _actionButtonTextController.dispose();

    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final String? actionUrl = _actionUrlController.text.trim().isEmpty
        ? null
        : _actionUrlController.text.trim();
    final String? actionButtonText =
        _actionButtonTextController.text.trim().isEmpty
        ? null
        : _actionButtonTextController.text.trim();

    final Result<void> result;
    if (_isEditMode) {
      final Notice updatedNotice = widget.initialNotice!.copyWith(
        title: title,
        content: content,
        actionUrl: actionUrl,
        actionButtonText: actionButtonText,
        isImportant: _isImportant,
      );
      result = await ref
          .read(adminViewModelProvider.notifier)
          .updateNotice(updatedNotice);
    } else {
      final Notice newNotice = Notice.create(
        title: title,
        content: content,
        actionUrl: actionUrl,
        actionButtonText: actionButtonText,
        isImportant: _isImportant,
      );

      result = await ref
          .read(adminViewModelProvider.notifier)
          .createNotice(newNotice);
    }

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
          SnackBar(
            content: Text(_isEditMode ? '공지사항이 수정되었습니다.' : '공지사항이 등록되었습니다.'),
          ),
        );
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '공지사항 저장 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? '공지사항 수정' : '새 공지사항 등록',
                style: textTheme.headlineSmall,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  hintText: '공지사항 제목을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목은 필수 입력 항목입니다.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: '내용 *',
                  hintText: '공지사항 본문 내용을 입력하세요',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용은 필수 입력 항목입니다.';
                  }
                  return null;
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('중요 공지사항으로 등록', style: textTheme.bodyLarge),
                trailing: SimpleBinaryToggle(
                  toggle: _isImportant,
                  onChanged: (isChecked) {
                    setState(() {
                      _isImportant = isChecked;
                    });
                  },
                ),
              ),
              TextFormField(
                controller: _actionButtonTextController,
                decoration: const InputDecoration(
                  labelText: '외부 링크 버튼 문구 (선택)',
                  hintText: '예: 업데이트 하러가기',
                ),
              ),
              TextFormField(
                controller: _actionUrlController,
                decoration: const InputDecoration(
                  labelText: '외부 링크 URL (선택)',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 4),
              DialogActionButtons(
                cancelText: '취소',
                confirmText: _isSubmitting
                    ? '저장 중...'
                    : (_isEditMode ? '수정하기' : '등록하기'),
                onCancel: () => context.pop(),
                onConfirm: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
