/// 두 사용자 간의 친구 요청 및 관계 상태를 정의하는 열거형입니다.
enum FriendshipStatus {
  /// 친구 요청 후 수락 대기 중인 상태.
  pending,
  /// 친구 요청이 수락되어 친구 관계가 성립된 상태.
  accepted,
  /// 친구 요청이 거절된 상태.
  declined;

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [FriendshipStatus]로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [FriendshipStatus.pending]을 반환합니다.
  static FriendshipStatus fromString(String? value) {
    return FriendshipStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => FriendshipStatus.pending,
    );
  }
}
