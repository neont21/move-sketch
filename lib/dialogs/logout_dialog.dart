import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dialog_action_buttons.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('로그아웃 할까요?', style: textTheme.headlineSmall),
          Text(
            '기록은 그대로 남아 있어요.\n다시 로그인하면 이어서 볼 수 있어요.',
            style: textTheme.labelMedium,
          ),
          DialogActionButtons(
            confirmText: '로그아웃',
            onConfirm: () {
              context.pop();
              context.go('/auth/login');
            },
            onCancel: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
