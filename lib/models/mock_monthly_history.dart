import 'mock_session_history.dart';

class MockMonthlyHistory {
  int year;
  int month;
  List<MockSessionHistory> history;
  Set<int> dayJogging;
  Set<int> dayRiding;

  MockMonthlyHistory({
    required this.year,
    required this.month,
    required this.history,
  }) : dayJogging = history
           .where((event) => event.isJogging == true)
           .map((event) => event.createdAt.day)
           .toSet(),
       dayRiding = history
           .where((event) => event.isJogging == false)
           .map((event) => event.createdAt.day)
           .toSet();
}
