import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependencies.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/validators.dart';
import '../../core/widgets/labeled_text_form_field.dart';
import '../view_models/account_settings_viewmodel.dart';

class RegisterPasswordDialog extends ConsumerStatefulWidget {
  const RegisterPasswordDialog({super.key});

  @override
  ConsumerState<RegisterPasswordDialog> createState() =>
      _RegisterPasswordDialogState();
}

class _RegisterPasswordDialogState
    extends ConsumerState<RegisterPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(accountSettingsViewModelProvider.notifier)
        .linkEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        await ref
            .read(authRepositoryProvider)
            .resendVerificationEmail()
            .catchError((_) => const Result.ok(null));

        if (!mounted) {
          return;
        }

        setState(() {
          _isSubmitting = false;
        });

        context.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 등록되었습니다. 발송된 메일함에서 인증 링크를 확인해 주세요.'),
          ),
        );
      case Error(:final error):
        setState(() {
          _isSubmitting = false;
        });
        final String errorMessage = error is AppException
            ? error.message
            : '비밀번호 등록 중 오류가 발생했습니다.';
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

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('비밀번호 등록', style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '이메일과 함께 로그인에 사용할 비밀번호를 입력해 주세요.',
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: 20),
                LabeledTextFormField(
                  controller: _emailController,
                  labelText: '이메일',
                  hintText: 'example@email.com',
                  inputType: TextInputType.emailAddress,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                LabeledTextFormField(
                  controller: _passwordController,
                  labelText: '새 비밀번호',
                  hintText: '8자 이상 입력해 주세요',
                  showPassword: _showPassword,
                  inputType: TextInputType.visiblePassword,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.validatePassword,
                  toggleVisibility: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
                LabeledTextFormField(
                  controller: _confirmPasswordController,
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 한 번 더 입력해 주세요',
                  showPassword: _showConfirmPassword,
                  inputType: TextInputType.visiblePassword,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  toggleVisibility: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => context.pop(),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('등록'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
