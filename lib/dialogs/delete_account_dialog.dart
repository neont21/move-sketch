import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dialog_action_buttons.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계정을 삭제할까요?',
            style: textTheme.headlineSmall?.copyWith(color: colorScheme.error),
          ),
          Text('지금까지 남긴 기록이 모두 지워지고 되돌릴 수 없어요.', style: textTheme.labelMedium),
          Text(
            '확인을 위해 아이디를 입력해 주세요',
            style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
          ),
          TextField(
            keyboardType: TextInputType.text,
            style: textTheme.bodyMedium,
            minLines: 1,
            maxLines: 1,
            decoration: InputDecoration(hintText: 'user_id'),
          ),
          DialogActionButtons(
            confirmText: '삭제',
            confirmColor: colorScheme.error,
            onConfirm: () {
              // TODO: controller를 통해 입력값이 정확할 때만 수행
              context.pop();
              context.go('/auth/login');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('계정이 삭제되었습니다.'),
                  duration: Duration(seconds: 3),
                ),
              );
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
