import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../view_models/home_viewmodel.dart';

class SessionResumeDialog extends ConsumerWidget {
  final TrackingSession session;

  const SessionResumeDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final minutes = session.elapsedDuration.inMinutes;
    final seconds = session.elapsedDuration.inSeconds % 60;
    final distanceKm = (session.distanceInMeters / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비정상 종료된 세션이 있어요.', style: textTheme.headlineSmall),
          Divider(),
          Text(
            '중단된 ${session.activityType.label} 기록',
            style: textTheme.labelMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('소요 시간', style: textTheme.bodyLarge),
              Text('$minutes분 $seconds초', style: textTheme.bodyMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이동 거리', style: textTheme.bodyLarge),
              Text('${distanceKm}km', style: textTheme.bodyMedium),
            ],
          ),
          if (session.missions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('진행 중이던 미션', style: textTheme.labelMedium),
            for (final mission in session.missions)
              _MissionItemRow(mission: mission),
          ],
          SizedBox(height: 8),
          DialogActionButtons(
            confirmText: '이어하기',
            onConfirm: () {
              context.go(Routes.sessionTracking);
            },
            cancelText: '이대로 저장',
            onCancel: () {
              context.go(Routes.sessionResult(session.id));
            },
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => Dialog(
                  child: SystemAlertDialog(
                    title: '정말 기록을 남기지 않나요?',
                    description: '기록을 남기지 않고 폐기하면 되돌릴 수 없어요.',
                    confirmText: '그래도 폐기',
                    onConfirm: () {
                      dialogContext.pop();
                      context.pop();
                      ref
                          .read(homeViewModelProvider.notifier)
                          .discardActiveSession(session.id);
                    },
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                '기록을 남기지 않고 폐기하기',
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

class _MissionItemRow extends StatelessWidget {
  final MissionInstance mission;
  const _MissionItemRow({required this.mission});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(mission.axis.label, style: textTheme.bodyLarge),
        Text(
          '${mission.currentValue.toStringAsFixed(1)} ${mission.axis.unit}',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
