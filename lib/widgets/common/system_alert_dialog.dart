import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dialog_action_buttons.dart';

class SystemAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final VoidCallback onConfirm;
  const SystemAlertDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.onConfirm,
  });

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
          Text(title, style: textTheme.headlineSmall),
          Text(
            description,
            style: textTheme.labelMedium,
          ),
          DialogActionButtons(
            confirmText: confirmText,
            onConfirm: onConfirm,
            onCancel: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
