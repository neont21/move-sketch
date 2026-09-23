import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/labeled_text_form_field.dart';
import '../view_models/auth_notifier.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordCheckController;

  bool _showPassword = false;
  bool _showCheckPassword = false;
  bool _agree = false;

  @override
  void initState() {
    super.initState();

    _nicknameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordCheckController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();

    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_agree) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이용약관에 동의해 주세요.')));
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          username: _usernameController.text.trim().toLowerCase(),
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        final email = _emailController.text.trim();

        context.go(Routes.signupComplete, extra: email);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '회원가입 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
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

    final authState = ref.watch(authNotifierProvider);
    final bool isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('계정 만들기')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
                LabeledTextFormField(
                  labelText: '닉네임',
                  hintText: '친구에게 보일 이름을 10자 이내로 입력해 주세요',
                  controller: _nicknameController,
                  enabled: !isLoading,
                  maxLength: 10,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해 주세요.';
                    }
                    if (value.trim().length > 10) {
                      return '10자 이내로 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  labelText: '아이디',
                  hintText: '로그인에 사용할 아이디 (변경 불가)',
                  controller: _usernameController,
                  enabled: !isLoading,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '아이디를 입력해 주세요.';
                    }
                    final username = value.trim();
                    if (username.length < 3 || username.length > 20) {
                      return '3자 이상 20자 이하로 입력해 주세요.';
                    }
                    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                    if (!usernameRegex.hasMatch(username)) {
                      return '영문, 숫자, 밑줄(_)만 사용할 수 있습니다.';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  inputType: TextInputType.emailAddress,
                  labelText: '이메일',
                  hintText: '계정 인증에 사용할 이메일을 입력해 주세요',
                  controller: _emailController,
                  enabled: !isLoading,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해 주세요.';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return '올바른 이메일 형식을 입력해 주세요';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  inputType: TextInputType.visiblePassword,
                  labelText: '비밀번호',
                  hintText: '영문과 숫자를 섞어 8자 이상 입력해 주세요',
                  controller: _passwordController,
                  enabled: !isLoading,
                  showPassword: _showPassword,
                  toggleVisibility: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해 주세요';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                LabeledTextFormField(
                  inputType: TextInputType.visiblePassword,
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 입력해 주세요',
                  controller: _passwordCheckController,
                  enabled: !isLoading,
                  showPassword: _showCheckPassword,
                  toggleVisibility: () {
                    setState(() {
                      _showCheckPassword = !_showCheckPassword;
                    });
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해 주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (newValue) {
                        setState(() {
                          _agree = newValue ?? !_agree;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(Routes.tos);
                      },
                      child: Text(
                        '이용약관',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text('과 ', style: textTheme.labelMedium),
                    GestureDetector(
                      onTap: () {
                        context.push(Routes.privacy);
                      },
                      child: Text(
                        '개인정보 처리 방침',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _agree = !_agree),
                      child: Text('에 동의해요 (필수)', style: textTheme.labelMedium),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (_agree && !isLoading) ? _handleSignup : null,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('가입하기'),
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
