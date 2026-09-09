import 'mock_user.dart';

class MockSketch {
  String sketchId;
  MockUser author;
  DateTime createdAt;
  String? sketchURL;
  String? text;
  String location;
  String? weather;
  bool isJogging;
  List<MockUser>? cheeredUser = [];

  MockSketch({
    required this.sketchId,
    required this.author,
    required this.createdAt,
    required this.isJogging,
    required this.location,
    this.sketchURL,
    this.text,
    this.weather,
    this.cheeredUser,
  });
}