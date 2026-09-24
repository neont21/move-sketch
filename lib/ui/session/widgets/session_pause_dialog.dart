import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../view_models/session_tracking_viewmodel.dart';

class SessionPauseDialog extends ConsumerWidget {
  final SessionTrackingState trackingState;

  const SessionPauseDialog({super.key, required this.trackingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '여기까지 ${trackingState.distanceInKm.toStringAsFixed(2)}km 왔어요',
            style: textTheme.headlineSmall,
          ),
          Text('잠시 쉬었다 가도 괜찮아요.', style: textTheme.labelMedium),
          Divider(),
          if (trackingState.missions.isNotEmpty) ...[
            Text(
              '지금 종료하면',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            ...trackingState.missions.map(
              (mission) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${mission.axis.label} · ${mission.tierComment}',
                    style: textTheme.labelMedium,
                  ),
                  Text(
                    '${mission.formattedValue}${mission.axis.unit}',
                    style: textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          DialogActionButtons(
            confirmText: '계속하기',
            onConfirm: () {
              context.pop();
            },
            cancelText: '여기서 종료',
            onCancel: () {
              context.go(Routes.sessionResult(trackingState.session.id));
            },
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => Dialog(
                  child: SystemAlertDialog(
                    title: '정말 기록을 남기지 않나요?',
                    description: '기록을 남기지 않고 종료하면 되돌릴 수 없어요.',
                    confirmText: '그래도 종료',
                    onConfirm: () async {
                      final messenger = ScaffoldMessenger.of(context);

                      await ref
                          .read(sessionTrackingViewModelProvider.notifier)
                          .discardSession();

                      if (!dialogContext.mounted) {
                        return;
                      }
                      dialogContext.pop();

                      if (!context.mounted) {
                        return;
                      }
                      context.go(Routes.home);

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('세션 기록을 저장하지 않고 종료했습니다.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                '기록을 남기지 않고 종료하기',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
