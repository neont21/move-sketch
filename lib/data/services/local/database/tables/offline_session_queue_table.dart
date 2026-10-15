import 'package:drift/drift.dart';
import '../../../../../domain/models/enums/sync_status.dart';

class OfflineSessionQueueTable extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();
  TextColumn get sessionResultJson => text()();
  TextColumn get sketchImagePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get syncStatus => textEnum<SyncStatus>()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
