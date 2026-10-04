import 'package:flutter/material.dart';
import '../../core/widgets/labeled_text_form_field.dart';

class PasswordReauthSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final bool showPassword;
  final bool isDeleting;
  final VoidCallback onToggleVisibility;
  final VoidCallback onConfirm;

  const PasswordReauthSection({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.showPassword,
    required this.isDeleting,
    required this.onToggleVisibility,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '확인을 위해 비밀번호를 입력해 주세요.\n인증 완료 시 계정과 모든 기록이 즉시 삭제됩니다.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          LabeledTextFormField(
            hintText: '비밀번호 입력',
            controller: passwordController,
            enabled: !isDeleting,
            showPassword: showPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isDeleting) {
                onConfirm();
              }
            },
            toggleVisibility: onToggleVisibility,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해 주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isDeleting ? null : onConfirm,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isDeleting ? '삭제 중...' : '비밀번호 인증 후 삭제',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
