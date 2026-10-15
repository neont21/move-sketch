// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_session_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$OfflineSessionQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $OfflineSessionQueueTableTable get offlineSessionQueueTable =>
      attachedDatabase.offlineSessionQueueTable;
  OfflineSessionQueueDaoManager get managers =>
      OfflineSessionQueueDaoManager(this);
}

class OfflineSessionQueueDaoManager {
  final _$OfflineSessionQueueDaoMixin _db;
  OfflineSessionQueueDaoManager(this._db);
  $$OfflineSessionQueueTableTableTableManager get offlineSessionQueueTable =>
      $$OfflineSessionQueueTableTableTableManager(
        _db.attachedDatabase,
        _db.offlineSessionQueueTable,
      );
}
