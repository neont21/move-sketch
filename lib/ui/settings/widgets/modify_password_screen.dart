import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/validators.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/labeled_text_form_field.dart';

class ModifyPasswordScreen extends ConsumerStatefulWidget {
  const ModifyPasswordScreen({super.key});

  @override
  ConsumerState<ModifyPasswordScreen> createState() =>
      _ModifyPasswordScreenState();
}

class _ModifyPasswordScreenState extends ConsumerState<ModifyPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showCheckPassword = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
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
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(authViewModelProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
        );
        context.pop();
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '비밀번호 변경 중 오류가 발생했습니다.';
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

    return Scaffold(
      appBar: AppBar(title: Text('비밀번호 변경')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledTextFormField(
                  labelText: '기존 비밀번호',
                  hintText: '기존 비밀번호',
                  controller: _currentPasswordController,
                  textInputAction: TextInputAction.next,
                  enabled: !_isSubmitting,
                  showPassword: showCurrentPassword,
                  toggleVisibility: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '기존 비밀번호를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  labelText: '새 비밀번호',
                  hintText: '새 비밀번호',
                  controller: _newPasswordController,
                  textInputAction: TextInputAction.next,
                  enabled: !_isSubmitting,
                  showPassword: _showNewPassword,
                  toggleVisibility: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    final String? validationError = Validators.validatePassword(
                      value,
                    );
                    if (validationError != null) {
                      return validationError;
                    }
                    if (value == _currentPasswordController.text) {
                      return '새 비밀번호는 기존 비밀번호와 달라야 합니다.';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  labelText: '새 비밀번호 확인',
                  hintText: '새 비밀번호 확인',
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  enabled: !_isSubmitting,
                  onFieldSubmitted: (value) {
                    if (!_isSubmitting) {
                      _handleSubmit();
                    }
                  },
                  showPassword: _showCheckPassword,
                  toggleVisibility: () {
                    setState(() {
                      _showCheckPassword = !_showCheckPassword;
                    });
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                ),
                Text(
                  '영문과 숫자를 섞어 8자 이상으로 정해 주세요.',
                  style: textTheme.labelMedium,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('비밀번호 변경'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
