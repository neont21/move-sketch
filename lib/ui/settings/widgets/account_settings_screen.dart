import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/system_alert_dialog.dart';
import 'delete_account_dialog.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isSigningOut = false;

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

  void _showComingSoonSnackBar(String providerName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$providerName 연동 기능은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final User? currentUser = ref.watch(currentUserProvider);
    final String? email = currentUser?.email;
    final bool hasEmail = email != null && email.isNotEmpty;

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
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('Google', style: textTheme.bodyLarge),
                trailing: OutlinedButton(
                  onPressed: () => _showComingSoonSnackBar('Google'),
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
                    '연결하기',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.apple,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('Apple', style: textTheme.bodyLarge),
                trailing: OutlinedButton(
                  onPressed: () => _showComingSoonSnackBar('Apple'),
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
                    '연결하기',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('email', style: textTheme.bodyLarge),
                subtitle: hasEmail
                    ? Text(email, style: textTheme.labelSmall)
                    : null,
                trailing: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('최소 하나의 로그인 수단은 연결되어 있어야 합니다.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    backgroundColor: hasEmail
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: hasEmail
                      ? Text(
                          '연결 해제',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.tertiaryContainer,
                          ),
                        )
                      : Text(
                          '연결하기',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (hasEmail)
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
