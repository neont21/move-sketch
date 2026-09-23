import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dependencies.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/auth_viewmodel.dart';

class SignupCompleteScreen extends ConsumerStatefulWidget {
  final String? email;
  const SignupCompleteScreen({super.key, this.email});

  @override
  ConsumerState<SignupCompleteScreen> createState() =>
      _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends ConsumerState<SignupCompleteScreen> {
  bool _isResending = false;

  Future<void> _handleResendEmail() async {
    if (_isResending) {
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    setState(() {
      _isResending = true;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .resendVerificationEmail();

    if (!mounted) {
      return;
    }

    setState(() {
      _isResending = false;
    });

    switch (result) {
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 메일을 다시 보냈습니다. 받은 메일함을 확인해 주세요.')),
        );
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '메일 재발송 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleGoToLogin() async {
    await ref.read(authViewModelProvider.notifier).signOut();

    if (!mounted) {
      return;
    }

    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String displayEmail =
        widget.email ??
        (GoRouterState.of(context).extra as String?) ??
        'user@example.com';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await ref.read(authViewModelProvider.notifier).signOut();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 20,
              children: [
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                Text('계정이 만들어졌어요', style: textTheme.displaySmall),
                Text(
                  '방금 보낸 메일에서 인증 링크를 눌러 주시면\n로그인하실 수 있어요.',
                  style: textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(displayEmail, style: textTheme.labelLarge),
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _handleGoToLogin,
                    child: const Text('로그인 하러 가기'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _handleResendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainer,
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('인증 메일 다시 보내기', style: textTheme.labelLarge),
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
