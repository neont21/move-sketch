import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/labeled_text_form_field.dart';
import '../view_models/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authViewModelProvider.notifier)
        .signIn(
          username: _usernameController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '로그인 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleSocialLogin(
    Future<Result<dynamic>> Function() signInMethod,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    FocusScope.of(context).unfocus();

    final result = await signInMethod();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '소셜 로그인 중 오류가 발생했습니다.';
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

    final authState = ref.watch(authViewModelProvider);
    final bool isLoading = authState.isLoading;

    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: isKeyboardOpen ? 8 : 12,
                children: [
                  AnimatedContainer(
                    width: isKeyboardOpen ? 48 : 100,
                    height: isKeyboardOpen ? 48 : 100,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: isKeyboardOpen ? 20 : 40,
                          spreadRadius: isKeyboardOpen ? -16 : -32,
                          color: colorScheme.tertiaryContainer,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset('assets/brand/logo-mark.svg'),
                  ),
                  Text('가볍게 시작해 볼까요?', style: textTheme.displaySmall),
                  AnimatedCrossFade(
                    crossFadeState: isKeyboardOpen
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                    firstChild: Text(
                      '오늘의 조깅과 라이딩을 기록해요',
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => _handleSocialLogin(
                            ref
                                .read(authViewModelProvider.notifier)
                                .signInWithGoogle,
                          ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.tertiaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            size: textTheme.displayMedium?.fontSize,
                          ),
                          Text('Google로 계속하기'),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => _handleSocialLogin(
                            ref
                                .read(authViewModelProvider.notifier)
                                .signInWithApple,
                          ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.tertiaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apple,
                            size: textTheme.displayMedium?.fontSize,
                          ),
                          Text('Apple로 계속하기'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      spacing: 20,
                      children: [
                        Expanded(child: Divider()),
                        Text('혹은', style: textTheme.labelMedium),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  LabeledTextFormField(
                    inputType: TextInputType.emailAddress,
                    labelText: '아이디/이메일',
                    hintText: '아이디/이메일',
                    controller: _usernameController,
                    enabled: !isLoading,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '아이디 또는 이메일을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  LabeledTextFormField(
                    inputType: TextInputType.visiblePassword,
                    labelText: '비밀번호',
                    hintText: '비밀번호',
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
                      if (value == null || value.trim().isEmpty) {
                        return '비밀번호를 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      // context.go(Routes.home);
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('로그인'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('아직 계정이 없나요?', style: textTheme.labelMedium),
                      GestureDetector(
                        onTap: () {
                          context.push(Routes.signup);
                        },
                        child: Text(
                          '회원가입',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textTheme.labelLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(Routes.resetPassword);
                    },
                    child: Text('비밀번호를 잊으셨나요?', style: textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
