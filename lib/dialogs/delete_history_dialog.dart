import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dialog_action_buttons.dart';

class DeleteHistoryDialog extends StatefulWidget {
  final String sessionId;
  const DeleteHistoryDialog({super.key, required this.sessionId});

  @override
  State<DeleteHistoryDialog> createState() => _DeleteHistoryDialogState();
}

class _DeleteHistoryDialogState extends State<DeleteHistoryDialog> {
  bool _agree = false;

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
          Text('기록을 삭제하시겠습니까?', style: textTheme.headlineSmall),
          Text('삭제한 기록은 되돌릴 수 없어요.', style: textTheme.labelMedium),
          Row(
            children: [
              Checkbox(
                value: _agree,
                onChanged: (newValue) {
                  setState(() {
                    _agree = newValue ?? !_agree;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agree = !_agree;
                  });
                },
                child: Text(
                  '피드에 올린 스케치도 함께 지우고 싶어요.',
                  style: textTheme.labelMedium
                ),
              ),
            ],
          ),
          DialogActionButtons(
            confirmText: '삭제하기',
            onConfirm: () {
              context.pop();
              // TODO sessionId 에 대한 삭제 작업
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('기록이 삭제되었습니다.'),
                  duration: const Duration(seconds: 3),
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
