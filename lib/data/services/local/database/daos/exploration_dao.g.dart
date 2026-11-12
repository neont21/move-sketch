// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exploration_dao.dart';

// ignore_for_file: type=lint
mixin _$ExplorationDaoMixin on DatabaseAccessor<AppDatabase> {
  $VisitedGeohashesTableTable get visitedGeohashesTable =>
      attachedDatabase.visitedGeohashesTable;
  ExplorationDaoManager get managers => ExplorationDaoManager(this);
}

class ExplorationDaoManager {
  final _$ExplorationDaoMixin _db;
  ExplorationDaoManager(this._db);
  $$VisitedGeohashesTableTableTableManager get visitedGeohashesTable =>
      $$VisitedGeohashesTableTableTableManager(
        _db.attachedDatabase,
        _db.visitedGeohashesTable,
      );
}
