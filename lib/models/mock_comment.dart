import 'package:move_sketch/models/mock_user.dart';

class MockComment {
  MockUser user;
  DateTime createdAt;
  String sketchId;
  String commentId;
  String? parentCommentId;
  String text;

  MockComment({
    required this.user,
    required this.createdAt,
    required this.sketchId,
    required this.commentId,
    required this.text,
    this.parentCommentId,
  });
}
