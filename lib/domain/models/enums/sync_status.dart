enum SyncStatus {
  localOnly,
  syncing,
  synced,
  syncFailed;

  static SyncStatus fromString(String? value) {
    return SyncStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => SyncStatus.localOnly,
    );
  }
}
