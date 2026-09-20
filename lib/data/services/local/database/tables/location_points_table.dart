import 'package:drift/drift.dart';
import 'tracking_sessions_table.dart';

class LocationPointsTable extends Table {
  IntColumn get sequenceId => integer().autoIncrement()();

  TextColumn get sessionId => text().references(
    TrackingSessionsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().nullable()();
}
