import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountModal extends StatelessWidget {
  const DeleteAccountModal({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정을 삭제할까요?',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            Text(
              '지금까지 남긴 기록이 모두 지워지고 되돌릴 수 없어요.',
              style: textTheme.labelMedium,
            ),
            Text(
              '확인을 위해 아이디를 입력해 주세요',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            SizedBox(
              child: TextField(
                keyboardType: TextInputType.text,
                style: textTheme.bodyMedium,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  hintText: 'user_id',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.tertiaryContainer,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
              ),
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
                        // TODO: controller를 통해 입력값이 정확할 때만 수행
                        context.pop();
                        context.go('/auth/login');
                      },
                      child: Text(
                        '삭제',
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
