import 'mock_mission_data.dart';
import 'mock_session_data.dart';

class MockSessionHistory {
  String sessionId;
  DateTime createdAt;
  String? imageURL;
  bool isJogging;
  MockSessionData sessionData;
  List<MockMissionData> missionData;
  bool shared;

  MockSessionHistory({
    required this.sessionId,
    required this.createdAt,
    required this.sessionData,
    required this.missionData,
    this.isJogging=true,
    this.imageURL,
    this.shared=false,
});
}