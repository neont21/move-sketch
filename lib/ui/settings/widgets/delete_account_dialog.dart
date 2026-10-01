import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/labeled_text_form_field.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;

  bool _showPassword = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }

  void _handleDelete() async {
    FocusScope.of(context).unfocus();

    if (_isDeleting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(authViewModelProvider.notifier)
        .deleteAccount(
          currentPassword: _passwordController.text,
          username: user.username,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isDeleting = false;
    });

    switch (result) {
      case Ok():
        context.pop();
        context.go(Routes.login);
        messenger.showSnackBar(const SnackBar(content: Text('계정이 삭제되었습니다.')));
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '계정 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정을 삭제할까요?',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            Text(
              '지금까지 남긴 기록이 모두 지워지고 되돌릴 수 없어요.',
              style: textTheme.labelMedium,
            ),
            Text(
              '확인을 위해 비밀번호를 입력해 주세요',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            LabeledTextFormField(
              hintText: '비밀번호 입력',
              controller: _passwordController,
              enabled: _isDeleting,
              showPassword: _showPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                if (!_isDeleting) {
                  _handleDelete();
                }
              },
              toggleVisibility: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해 주세요.';
                }
                return null;
              },
            ),
            DialogActionButtons(
              confirmText: _isDeleting ? '삭제 중...' : '삭제',
              confirmColor: colorScheme.error,
              onConfirm: _isDeleting ? () {} : _handleDelete,
              onCancel: () {
                if (!_isDeleting) {
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
