import 'package:drift/drift.dart';
import '../../../models/enums/mission_axis.dart';
import 'tracking_sessions_table.dart';

class MissionInstancesTable extends Table {
  TextColumn get id => text()();

  TextColumn get sessionId => text().references(
    TrackingSessionsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get missionTemplateId => text()();
  TextColumn get axis => textEnum<MissionAxis>()();
  RealColumn get baselineValue => real().nullable()();
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();
  IntColumn get achievedTier => integer().withDefault(const Constant(0))();
  TextColumn get partId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}