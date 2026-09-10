import 'package:flutter/material.dart';
import '../models/mock_mission_data.dart';
import '../models/mock_monthly_history.dart';
import '../models/mock_session_data.dart';
import '../models/mock_session_history.dart';
import '../widgets/session_calendar.dart';
import '../widgets/session_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  MockMonthlyHistory _monthlyHistory = MockMonthlyHistory(
    year: DateTime.now().year,
    month: DateTime.now().month,
    history: [
      // TODO: 서버로부터 가져와야 함
      MockSessionHistory(
        sessionId: 'test3',
        createdAt: DateTime(2026, 9, 7, 15, 52),
        isJogging: false,
        sessionData: MockSessionData(
          minutes: 22,
          seconds: 52,
          km: 1.2,
          kcal: 63,
          id: 'test3',
        ),
        missionData: [],
      ),
      MockSessionHistory(
        sessionId: 'test3',
        createdAt: DateTime(2026, 9, 7, 11, 23),
        isJogging: true,
        sessionData: MockSessionData(
          minutes: 32,
          seconds: 12,
          km: 3,
          kcal: 123,
          id: 'test3',
        ),
        missionData: [],
        shared: true,
      ),
      MockSessionHistory(
        sessionId: 'test2',
        createdAt: DateTime(2026, 9, 5, 15, 52),
        isJogging: false,
        sessionData: MockSessionData(
          minutes: 22,
          seconds: 52,
          km: 1.2,
          kcal: 63,
          id: 'test2',
        ),
        missionData: [
          MockMissionData(
            title: '페이스',
            data: '7\'23\'\'',
            unit: '/km',
            comment: '무난히 해냈어요',
          ),
        ],
      ),
      MockSessionHistory(
        sessionId: 'test1',
        createdAt: DateTime(2026, 9, 2, 11, 23),
        isJogging: true,
        sessionData: MockSessionData(
          minutes: 32,
          seconds: 12,
          km: 3,
          kcal: 123,
          id: 'test1',
        ),
        missionData: [
          MockMissionData(
            title: '거리',
            data: '4.3',
            unit: 'km',
            comment: '충분히 해냈어요',
          ),
          MockMissionData(
            title: '인터벌',
            data: '2',
            unit: '회',
            comment: '충분히 해냈어요',
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('기록')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SessionCalendar(
              focusedDay: _focusedDay,
              monthlyHistory: _monthlyHistory,
              onMonthChanged: (newMonth) {
                setState(() {
                  _focusedDay = newMonth;
                  // TODO: 서버에서 해당 월의 기록 가져오기
                  _monthlyHistory = MockMonthlyHistory(
                    year: _focusedDay.year,
                    month: _focusedDay.month,
                    history: [],
                  );
                });
              },
            ),
            _monthlyHistory.history.isEmpty ?
                Expanded(child: Center(child: Text('이 달엔 기록이 없어요.',style: textTheme.labelMedium),))
                :
            Expanded(
              child: ListView.builder(
                itemCount: _monthlyHistory.history.length,
                itemBuilder: (context, index) =>
                    SessionCard(history: _monthlyHistory.history[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
