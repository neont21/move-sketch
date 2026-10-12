import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../config/assets.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/admin_viewmodel.dart';

class AdminLoginView extends ConsumerWidget {
  const AdminLoginView({super.key});

  Future<void> _handleSignIn(BuildContext context, WidgetRef ref) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(adminViewModelProvider.notifier)
        .signInWithGoogle();

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '로그인 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final adminState = ref.watch(adminViewModelProvider);
    final bool isLoading =
        adminState.isLoading || (adminState.value?.isProcessing ?? false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.logoMark, width: 80, height: 80),
                  const SizedBox(height: 24),
                  Text('MoveSketch 관리자 콘솔', style: textTheme.headlineLarge),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handleSignIn(context, ref),
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
                            const Text('Google로 로그인'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '※ 등록된 관리자 계정만 접근할 수 있습니다.',
                    style: textTheme.labelSmall,
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
