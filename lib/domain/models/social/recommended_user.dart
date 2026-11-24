import 'package:flutter/foundation.dart';
import 'user.dart';

/// 함께 아는 친구 정보를 포함하여 추천되는 사용자 후보를 나타내는 불변 모델입니다.
@immutable
final class RecommendedUser {
  /// 추천 대상 사용자의 요약 정보.
  final UserSummary user;

  /// 추천 사용자와 나 사이에 공통으로 연결된 함께 아는 친구 목록.
  final List<UserSummary> mutualFriends;

  const RecommendedUser({required this.user, required this.mutualFriends});

  /// 함께 아는 친구 수에 따라 UI 카드에 표시할 추천 사유 보조 문구.
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
