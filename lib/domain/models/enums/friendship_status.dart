enum FriendshipStatus {
  pending,
  accepted,
  declined;

  static FriendshipStatus fromString(String? value) {
    return FriendshipStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => FriendshipStatus.pending,
    );
  }
}
