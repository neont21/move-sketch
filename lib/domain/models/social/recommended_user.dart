import 'package:flutter/foundation.dart';
import 'user.dart';

@immutable
class RecommendedUser {
  final UserSummary user;
  final List<UserSummary> mutualFriends;

  const RecommendedUser({required this.user, required this.mutualFriends});

  String get subtitle {
    if (mutualFriends.isEmpty) {
      return '알 수도 있는 친구';
    }
    if (mutualFriends.length == 1) {
      return '${mutualFriends.first.nickname} 님과 아는 사이';
    }
    return '${mutualFriends.first.nickname} 님 외 ${mutualFriends.length - 1}명과 아는 사이';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedUser &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          listEquals(mutualFriends, other.mutualFriends);

  @override
  int get hashCode => Object.hash(user, Object.hashAll(mutualFriends));
}
