import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/result.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../view_models/history_viewmodel.dart';

class DeleteHistoryDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final bool isShared;

  const DeleteHistoryDialog({
    super.key,
    required this.sessionId,
    this.isShared = false,
  });

  @override
  ConsumerState<DeleteHistoryDialog> createState() =>
      _DeleteHistoryDialogState();
}

class _DeleteHistoryDialogState extends ConsumerState<DeleteHistoryDialog> {
  bool _cascade = false;

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
          if (widget.isShared) ...[
            Row(
              children: [
                Checkbox(
                  value: _cascade,
                  onChanged: (newValue) {
                    setState(() {
                      _cascade = newValue ?? !_cascade;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _cascade = !_cascade;
                    });
                  },
                  child: Text(
                    '피드에 올린 스케치도 함께 지우고 싶어요.',
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ],
          DialogActionButtons(
            confirmText: '삭제하기',
            onConfirm: () async {
              final messenger = ScaffoldMessenger.of(context);
              context.pop();
              final result = await ref
                  .read(historyViewModelProvider.notifier)
                  .deleteHistory(
                    widget.sessionId,
                    deletePostIfShared: _cascade,
                  );
              switch (result) {
                case Ok():
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('기록이 삭제되었습니다.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                case Error():
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('기록 삭제에 실패했습니다.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
              }
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
