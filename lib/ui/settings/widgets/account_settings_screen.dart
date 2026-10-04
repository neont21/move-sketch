import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../view_models/account_settings_viewmodel.dart';
import 'delete_account_dialog.dart';
import 'register_password_dialog.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isSigningOut = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(accountSettingsViewModelProvider.notifier)
            .checkEmailVerification();
      }
    });

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        ref
            .read(accountSettingsViewModelProvider.notifier)
            .checkEmailVerification();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();

    super.dispose();
  }

  Future<void> _handleLink(
    BuildContext context,
    WidgetRef ref, {
    required String providerName,
    required Future<Result<bool>> Function() action,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await action();

    switch (result) {
      case Ok(value: true):
        messenger.showSnackBar(
          SnackBar(content: Text('$providerName 계정이 연동되었습니다.')),
        );
      case Ok(value: false):
        break;
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '$providerName 연동 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleUnlink(
    BuildContext context,
    WidgetRef ref, {
    required String providerName,
    required String providerId,
  }) async {
    final state = ref.read(accountSettingsViewModelProvider);

    if (!state.canUnlink(providerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 인증된 로그인 수단은 연결되어 있어야 합니다.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SystemAlertDialog(
          title: '$providerName 연동을 해제할까요?',
          description: '연동을 해제하면 $providerName 계정으로 로그인할 수 없게 됩니다.',
          confirmText: '연동 해제',
          onConfirm: () => dialogContext.pop(true),
        ),
      ),
    );

    if (confirmed != true) {
      return;
    }

    final result = await ref
        .read(accountSettingsViewModelProvider.notifier)
        .unlinkProvider(providerId);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('$providerName 연동이 해제되었습니다.')),
        );
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '$providerName 연동 해제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleCancelPendingEmail(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final Result<void> result = await ref
        .read(accountSettingsViewModelProvider.notifier)
        .unlinkProvider('password');

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          const SnackBar(content: Text('이메일 등록이 취소되었습니다.')),
        );
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '이메일 등록 취소 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleSignOut() async {
    if (_isSigningOut) {
      return;
    }

    setState(() {
      _isSigningOut = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final result = await ref.read(authViewModelProvider.notifier).signOut();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSigningOut = false;
    });

    switch (result) {
      case Ok():
        messenger.showSnackBar(const SnackBar(content: Text('로그아웃 되었습니다.')));
        if (mounted) {
          context.go(Routes.login);
        }
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '로그아웃 중 오류가 발생했습니다.';
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

    final state = ref.watch(accountSettingsViewModelProvider);

    final bool isGoogleLinked = state.linkedProviders.contains('google.com');
    final bool isAppleLinked = state.linkedProviders.contains('apple.com');
    final bool hasPassword = state.hasPassword;

    return Scaffold(
      appBar: AppBar(title: Text('계정 정보')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('로그인 수단', style: textTheme.labelLarge),
              ListTile(
                leading: Icon(
                  Icons.g_mobiledata,
                  color: isGoogleLinked
                      ? colorScheme.primary
                      : colorScheme.tertiaryContainer,
                ),
                title: Text('Google', style: textTheme.bodyLarge),
                subtitle: state.isGoogleLinked && state.googleEmail != null
                    ? Text(state.googleEmail!, style: textTheme.labelSmall)
                    : null,
                trailing: OutlinedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () {
                          if (isGoogleLinked) {
                            _handleUnlink(
                              context,
                              ref,
                              providerName: 'Google',
                              providerId: 'google.com',
                            );
                          } else {
                            _handleLink(
                              context,
                              ref,
                              providerName: 'Google',
                              action: () => ref
                                  .read(
                                    accountSettingsViewModelProvider.notifier,
                                  )
                                  .linkGoogle(),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    backgroundColor: isGoogleLinked
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text(
                    isGoogleLinked ? '연결 해제' : '연결하기',
                    style: textTheme.bodySmall?.copyWith(
                      color: isGoogleLinked
                          ? colorScheme.tertiaryContainer
                          : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.apple,
                  color: isAppleLinked
                      ? colorScheme.primary
                      : colorScheme.tertiaryContainer,
                ),
                title: Text('Apple', style: textTheme.bodyLarge),
                subtitle: state.isAppleLinked && state.appleEmail != null
                    ? Text(state.appleEmail!, style: textTheme.labelSmall)
                    : null,
                trailing: OutlinedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () {
                          if (isAppleLinked) {
                            _handleUnlink(
                              context,
                              ref,
                              providerName: 'Apple',
                              providerId: 'apple.com',
                            );
                          } else {
                            _handleLink(
                              context,
                              ref,
                              providerName: 'Apple',
                              action: () => ref
                                  .read(
                                    accountSettingsViewModelProvider.notifier,
                                  )
                                  .linkApple(),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    backgroundColor: isAppleLinked
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text(
                    isAppleLinked ? '연결 해제' : '연결하기',
                    style: textTheme.bodySmall?.copyWith(
                      color: isAppleLinked
                          ? colorScheme.tertiaryContainer
                          : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: hasPassword
                      ? colorScheme.primary
                      : colorScheme.tertiaryContainer,
                ),
                title: Text('email', style: textTheme.bodyLarge),
                subtitle: hasPassword && state.passwordEmail != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.passwordEmail!,
                            style: textTheme.labelSmall,
                          ),
                          if (!state.isEmailVerified) ...[
                            const SizedBox(height: 2),
                            Text(
                              '이메일 인증이 필요합니다',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      )
                    : null,
                trailing: state.isProcessing
                    ? null
                    : !hasPassword
                    ? OutlinedButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (dialogContext) =>
                                const RegisterPasswordDialog(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          backgroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: Text(
                          '등록하기',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : !state.isEmailVerified
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final result = await ref
                                  .read(
                                    accountSettingsViewModelProvider.notifier,
                                  )
                                  .resendVerificationEmail();

                              if (!context.mounted) {
                                return;
                              }

                              switch (result) {
                                case Ok():
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('인증 메일이 재전송되었습니다.'),
                                    ),
                                  );
                                case Error(:final error):
                                  final errorMessage = error is AppException
                                      ? error.message
                                      : '인증 메일 전송에 실패했습니다.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: colorScheme.error,
                                    ),
                                  );
                              }
                            },
                            child: Text(
                              '재전송',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                _handleCancelPendingEmail(context, ref),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              backgroundColor: colorScheme.surfaceContainer,
                              side: BorderSide(color: colorScheme.outline),
                            ),
                            child: Text(
                              '연결 취소',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      )
                    // [인증 완료 상태]: 정상 연결 해제 버튼
                    : OutlinedButton(
                        onPressed: () => _handleUnlink(
                          context,
                          ref,
                          providerName: '비밀번호',
                          providerId: 'password',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          backgroundColor: colorScheme.surfaceContainer,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: Text(
                          '연결 해제',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.tertiaryContainer,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (hasPassword && state.isEmailVerified)
                ListTile(
                  onTap: () {
                    context.go(Routes.meSettingsPassword);
                  },
                  title: Text('비밀번호 변경', style: textTheme.bodyLarge),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorScheme.tertiaryContainer,
                  ),
                ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => Dialog(
                      child: SystemAlertDialog(
                        title: '로그아웃 할까요?',
                        description: '기록은 그대로 남아 있어요.\n다시 로그인하면 이어서 볼 수 있어요.',
                        confirmText: '로그아웃',
                        onConfirm: _handleSignOut,
                      ),
                    ),
                  );
                },
                title: Text('로그아웃', style: textTheme.bodyLarge),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(child: DeleteAccountDialog()),
                  );
                },
                title: Text(
                  '계정 삭제',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
