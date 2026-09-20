import 'package:flutter/material.dart';
import '../../core/widgets/simple_binary_toggle.dart';
import 'reminder_time_picker.dart';
import 'reminder_weekday_selector.dart';

class SettingNotificationsPage extends StatefulWidget {
  const SettingNotificationsPage({super.key});

  @override
  State<SettingNotificationsPage> createState() =>
      _SettingNotificationsPageState();
}

class _SettingNotificationsPageState extends State<SettingNotificationsPage> {
  bool _toggleAll = true;
  bool _toggleFriendNotification = true;
  bool _toggleResponseNotification = true;
  bool _toggleReminder = false;

  Set<int> selectedSet = {};
  int selectedTime = 19;
  final List<int> times = List.generate(23, (index) => index + 1);

  List<ListTile>? _activateNotification(TextTheme textTheme) {
    if (!_toggleAll) {
      return null;
    }

    return [
      ListTile(
        title: Text('친구', style: textTheme.bodyLarge),
        subtitle: Text('친구 요청과 수락을 알려 줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: _toggleFriendNotification,
          onChanged: (value) {
            setState(() {
              _toggleFriendNotification = !_toggleFriendNotification;
            });
          },
        ),
      ),
      ListTile(
        title: Text('응원과 댓글', style: textTheme.bodyLarge),
        subtitle: Text('내 기록에 친구가 반응하면 알려줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: _toggleResponseNotification,
          onChanged: (value) {
            setState(() {
              _toggleResponseNotification = !_toggleResponseNotification;
            });
          },
        ),
      ),
      ListTile(
        title: Text('리마인더', style: textTheme.bodyLarge),
        subtitle: Text('정한 시각까지 안 움직였으면 알려줘요', style: textTheme.labelSmall),
        trailing: SimpleBinaryToggle(
          toggle: _toggleReminder,
          onChanged: (value) {
            setState(() {
              _toggleReminder = !_toggleReminder;
            });
          },
        ),
      ),
    ];
  }

  SingleChildScrollView? _activateReminder(TextTheme textTheme) {
    if (!_toggleAll || !_toggleReminder) {
      return null;
    }

    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text('요일', style: textTheme.labelLarge),
          ReminderWeekday(
            selectedSet: selectedSet,
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                selectedSet = newSelection;
              });
            },
          ),
          Text('시간', style: textTheme.labelLarge),
          ReminderTime(
            selectedTime: selectedTime,
            timeList: times,
            onChanged: (int? newValue) {
              setState(() {
                selectedTime = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('푸시 알림')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('알림 받기', style: textTheme.bodyLarge),
              trailing: SimpleBinaryToggle(
                toggle: _toggleAll,
                onChanged: (value) {
                  setState(() {
                    _toggleAll = !_toggleAll;
                  });
                },
              ),
            ),
            ...?_activateNotification(textTheme),
            ?_activateReminder(textTheme),
          ],
        ),
      ),
    );
  }
}
