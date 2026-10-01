import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:move_sketch/ui/auth/view_models/auth_viewmodel.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/notification_settings.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/simple_binary_toggle.dart';
import 'reminder_time_picker.dart';
import 'reminder_weekday_selector.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final List<int> _availableHours = List.generate(24, (hour) => hour);
  bool _isSaving = false;

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final userRepository = ref.read(userRepositoryProvider);
    final result = await userRepository.updateNotificationSettings(newSettings);

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (result) {
      case Ok():
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();

        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
        });
      case Error(:final error):
        setState(() {
          _isSaving = false;
        });

        final errorMessage = error is AppException
            ? error.message
            : '알림 설정 저장 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  List<ListTile> _buildNotificationList(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return [
      ListTile(
        title: Text('친구', style: textTheme.bodyLarge),
        subtitle: Text('친구 요청과 수락을 알려 줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: settings.friendNotification,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                friendNotification: !settings.friendNotification,
              ),
            );
          },
        ),
      ),
      ListTile(
        title: Text('응원과 댓글', style: textTheme.bodyLarge),
        subtitle: Text('내 기록에 친구가 반응하면 알려줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: settings.responseNotification,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                responseNotification: !settings.responseNotification,
              ),
            );
          },
        ),
      ),
      ListTile(
        title: Text('리마인더', style: textTheme.bodyLarge),
        subtitle: Text('정한 시각까지 안 움직였으면 알려줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: settings.reminderNotification,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                reminderNotification: !settings.reminderNotification,
              ),
            );
          },
        ),
      ),
    ];
  }

  Column _buildReminderSection(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      spacing: 20,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('요일', style: textTheme.labelLarge),
        ReminderWeekdaySelector(
          selectedSet: settings.reminderDays,
          onSelectionChanged: (newSelection) {
            _updateSettings(settings.copyWith(reminderDays: newSelection));
          },
        ),
        Text('시간', style: textTheme.labelLarge),
        ReminderTimePicker(
          selectedTime: settings.reminderHour,
          timeList: _availableHours,
          onChanged: (newValue) {
            if (newValue != null) {
              _updateSettings(settings.copyWith(reminderHour: newValue));
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final currentUser = ref.watch(currentUserProvider);
    final settings =
        currentUser?.notificationSettings ?? const NotificationSettings();

    return Scaffold(
      appBar: AppBar(title: Text('푸시 알림')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('알림 받기', style: textTheme.bodyLarge),
              trailing: SimpleBinaryToggle(
                toggle: settings.pushEnabled,
                onChanged: (value) {
                  _updateSettings(
                    settings.copyWith(pushEnabled: !settings.pushEnabled),
                  );
                },
              ),
            ),
            if (settings.pushEnabled) ...[
              ..._buildNotificationList(context, settings),
              if (settings.reminderNotification)
                _buildReminderSection(context, settings),
            ],
          ],
        ),
      ),
    );
  }
}
