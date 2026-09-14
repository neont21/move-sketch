import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/system_alert_dialog.dart';

class SettingAccountPage extends StatefulWidget {
  const SettingAccountPage({super.key});

  @override
  State<SettingAccountPage> createState() => _SettingAccountPageState();
}

class _SettingAccountPageState extends State<SettingAccountPage> {
  bool _google = true;
  bool _apple = true;
  bool _email = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                subtitle: _google
                    ? Text('user@gmail.com', style: textTheme.labelSmall)
                    : null,
                trailing: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _google = !_google;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    backgroundColor: _google
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: _google
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
              ListTile(
                leading: Icon(
                  Icons.apple,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('Apple', style: textTheme.bodyLarge),
                subtitle: _apple
                    ? Text(
                        'qwer123@privaterelay.apple.com',
                        style: textTheme.labelSmall,
                      )
                    : null,
                trailing: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _apple = !_apple;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    backgroundColor: _apple
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: _apple
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
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('email', style: textTheme.bodyLarge),
                subtitle: _email
                    ? Text('user@example.com', style: textTheme.labelSmall)
                    : null,
                trailing: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _email = !_email;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    backgroundColor: _email
                        ? colorScheme.surfaceContainer
                        : colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: _email
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
              _email
                  ? ListTile(
                      onTap: () {
                        context.go('/me/settings/account/password');
                      },
                      title: Text('비밀번호 변경', style: textTheme.bodyLarge),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.tertiaryContainer,
                      ),
                    )
                  : const SizedBox.shrink(),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: SystemAlertDialog(
                        title: '로그아웃 할까요?',
                        description: '기록은 그대로 남아 있어요.\n다시 로그인하면 이어서 볼 수 있어요.',
                        confirmText: '로그아웃',
                        onConfirm: () {
                          context.pop();
                          context.go('/auth/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('로그아웃 되었습니다.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
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
