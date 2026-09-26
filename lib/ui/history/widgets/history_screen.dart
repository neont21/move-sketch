import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/exceptions.dart';
import '../view_models/history_viewmodel.dart';
import 'session_calendar.dart';
import 'session_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final historyState = ref.watch(historyViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('기록')),
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(20),
            child: Text(
              error is AppException ? error.message : '기록을 불러오는 중 오류가 발생했습니다.',
              style: textTheme.bodyMedium,
            ),
          ),
        ),
        data: (state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SessionCalendar(
                  focusedDay: state.focusedMonth,
                  dayJogging: state.dayJogging,
                  dayRiding: state.dayRiding,
                  onMonthChanged: (newMonth) {
                    ref
                        .read(historyViewModelProvider.notifier)
                        .changeMonth(newMonth);
                  },
                ),
                if (state.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.results.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        '이 달엔 기록이 없어요.',
                        style: textTheme.labelMedium,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) =>
                          SessionCard(result: state.results[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
