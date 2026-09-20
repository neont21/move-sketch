import 'package:flutter/material.dart';

class DialogActionButtons extends StatelessWidget {
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color? confirmColor;

  const DialogActionButtons({
    super.key,
    this.cancelText = '취소',
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.outline,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                cancelText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.tertiaryContainer,
                ),
              ),
            ),
          ),
        ),
        // 확인/실행 버튼
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                confirmText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
