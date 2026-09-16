import 'package:drift/drift.dart';
import '../../../models/enums/activity_type.dart';
import '../../../models/enums/session_status.dart';

class TrackingSessionsTable extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();
  TextColumn get activityType => textEnum<ActivityType>()();
  TextColumn get status => textEnum<SessionStatus>()();

  DateTimeColumn get startedAt => dateTime()();
  IntColumn get elapsedDurationSeconds =>
      integer().withDefault(const Constant(0))();
  RealColumn get distanceInMeters => real().withDefault(const Constant(0.0))();
  IntColumn get caloriesBurned => integer().withDefault(const Constant(0))();
  IntColumn get averagePaceInSeconds => integer().nullable()();
  RealColumn get averageSpeedKmh => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
