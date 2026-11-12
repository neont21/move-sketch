import 'package:drift/drift.dart';

class VisitedGeohashesTable extends Table {
  TextColumn get geohash => text()();
  TextColumn get userId => text()();

  DateTimeColumn get firstVisitedAt => dateTime()();
  DateTimeColumn get lastVisitedAt => dateTime()();

  IntColumn get visitCount => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {geohash, userId};
}