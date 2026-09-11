import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogoutModal extends StatelessWidget {
  const LogoutModal({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Padding(
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
            Row(
              spacing: 20,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.outline,
                      ),
                      child: Text(
                        '취소',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.tertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        context.go('/auth/login');
                      },
                      child: Text(
                        '로그아웃',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
