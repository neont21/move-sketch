// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrackingSessionsTableTable extends TrackingSessionsTable
    with TableInfo<$TrackingSessionsTableTable, TrackingSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
  activityType =
      GeneratedColumn<String>(
        'activity_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityType>(
        $TrackingSessionsTableTable.$converteractivityType,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>(
        $TrackingSessionsTableTable.$converterstatus,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDurationSecondsMeta =
      const VerificationMeta('elapsedDurationSeconds');
  @override
  late final GeneratedColumn<int> elapsedDurationSeconds = GeneratedColumn<int>(
    'elapsed_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceInMetersMeta = const VerificationMeta(
    'distanceInMeters',
  );
  @override
  late final GeneratedColumn<double> distanceInMeters = GeneratedColumn<double>(
    'distance_in_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<int> caloriesBurned = GeneratedColumn<int>(
    'calories_burned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _averagePaceInSecondsMeta =
      const VerificationMeta('averagePaceInSeconds');
  @override
  late final GeneratedColumn<int> averagePaceInSeconds = GeneratedColumn<int>(
    'average_pace_in_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageSpeedKmhMeta = const VerificationMeta(
    'averageSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> averageSpeedKmh = GeneratedColumn<double>(
    'average_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    activityType,
    status,
    startedAt,
    elapsedDurationSeconds,
    distanceInMeters,
    caloriesBurned,
    averagePaceInSeconds,
    averageSpeedKmh,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackingSessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('elapsed_duration_seconds')) {
      context.handle(
        _elapsedDurationSecondsMeta,
        elapsedDurationSeconds.isAcceptableOrUnknown(
          data['elapsed_duration_seconds']!,
          _elapsedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('distance_in_meters')) {
      context.handle(
        _distanceInMetersMeta,
        distanceInMeters.isAcceptableOrUnknown(
          data['distance_in_meters']!,
          _distanceInMetersMeta,
        ),
      );
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    }
    if (data.containsKey('average_pace_in_seconds')) {
      context.handle(
        _averagePaceInSecondsMeta,
        averagePaceInSeconds.isAcceptableOrUnknown(
          data['average_pace_in_seconds']!,
          _averagePaceInSecondsMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_kmh')) {
      context.handle(
        _averageSpeedKmhMeta,
        averageSpeedKmh.isAcceptableOrUnknown(
          data['average_speed_kmh']!,
          _averageSpeedKmhMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingSessionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingSessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      activityType: $TrackingSessionsTableTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        )!,
      ),
      status: $TrackingSessionsTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      elapsedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_duration_seconds'],
      )!,
      distanceInMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_in_meters'],
      )!,
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_burned'],
      )!,
      averagePaceInSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_pace_in_seconds'],
      ),
      averageSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_kmh'],
      ),
    );
  }

  @override
  $TrackingSessionsTableTable createAlias(String alias) {
    return $TrackingSessionsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityType, String, String>
  $converteractivityType = const EnumNameConverter<ActivityType>(
    ActivityType.values,
  );
  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class TrackingSessionsTableData extends DataClass
    implements Insertable<TrackingSessionsTableData> {
  final String id;
  final String userId;
  final ActivityType activityType;
  final SessionStatus status;
  final DateTime startedAt;
  final int elapsedDurationSeconds;
  final double distanceInMeters;
  final int caloriesBurned;
  final int? averagePaceInSeconds;
  final double? averageSpeedKmh;
  const TrackingSessionsTableData({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.status,
    required this.startedAt,
    required this.elapsedDurationSeconds,
    required this.distanceInMeters,
    required this.caloriesBurned,
    this.averagePaceInSeconds,
    this.averageSpeedKmh,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    {
      map['activity_type'] = Variable<String>(
        $TrackingSessionsTableTable.$converteractivityType.toSql(activityType),
      );
    }
    {
      map['status'] = Variable<String>(
        $TrackingSessionsTableTable.$converterstatus.toSql(status),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['elapsed_duration_seconds'] = Variable<int>(elapsedDurationSeconds);
    map['distance_in_meters'] = Variable<double>(distanceInMeters);
    map['calories_burned'] = Variable<int>(caloriesBurned);
    if (!nullToAbsent || averagePaceInSeconds != null) {
      map['average_pace_in_seconds'] = Variable<int>(averagePaceInSeconds);
    }
    if (!nullToAbsent || averageSpeedKmh != null) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh);
    }
    return map;
  }

  TrackingSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return TrackingSessionsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      activityType: Value(activityType),
      status: Value(status),
      startedAt: Value(startedAt),
      elapsedDurationSeconds: Value(elapsedDurationSeconds),
      distanceInMeters: Value(distanceInMeters),
      caloriesBurned: Value(caloriesBurned),
      averagePaceInSeconds: averagePaceInSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(averagePaceInSeconds),
      averageSpeedKmh: averageSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(averageSpeedKmh),
    );
  }

  factory TrackingSessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingSessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      activityType: $TrackingSessionsTableTable.$converteractivityType.fromJson(
        serializer.fromJson<String>(json['activityType']),
      ),
      status: $TrackingSessionsTableTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      elapsedDurationSeconds: serializer.fromJson<int>(
        json['elapsedDurationSeconds'],
      ),
      distanceInMeters: serializer.fromJson<double>(json['distanceInMeters']),
      caloriesBurned: serializer.fromJson<int>(json['caloriesBurned']),
      averagePaceInSeconds: serializer.fromJson<int?>(
        json['averagePaceInSeconds'],
      ),
      averageSpeedKmh: serializer.fromJson<double?>(json['averageSpeedKmh']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'activityType': serializer.toJson<String>(
        $TrackingSessionsTableTable.$converteractivityType.toJson(activityType),
      ),
      'status': serializer.toJson<String>(
        $TrackingSessionsTableTable.$converterstatus.toJson(status),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'elapsedDurationSeconds': serializer.toJson<int>(elapsedDurationSeconds),
      'distanceInMeters': serializer.toJson<double>(distanceInMeters),
      'caloriesBurned': serializer.toJson<int>(caloriesBurned),
      'averagePaceInSeconds': serializer.toJson<int?>(averagePaceInSeconds),
      'averageSpeedKmh': serializer.toJson<double?>(averageSpeedKmh),
    };
  }

  TrackingSessionsTableData copyWith({
    String? id,
    String? userId,
    ActivityType? activityType,
    SessionStatus? status,
    DateTime? startedAt,
    int? elapsedDurationSeconds,
    double? distanceInMeters,
    int? caloriesBurned,
    Value<int?> averagePaceInSeconds = const Value.absent(),
    Value<double?> averageSpeedKmh = const Value.absent(),
  }) => TrackingSessionsTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    activityType: activityType ?? this.activityType,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    elapsedDurationSeconds:
        elapsedDurationSeconds ?? this.elapsedDurationSeconds,
    distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    averagePaceInSeconds: averagePaceInSeconds.present
        ? averagePaceInSeconds.value
        : this.averagePaceInSeconds,
    averageSpeedKmh: averageSpeedKmh.present
        ? averageSpeedKmh.value
        : this.averageSpeedKmh,
  );
  TrackingSessionsTableData copyWithCompanion(
    TrackingSessionsTableCompanion data,
  ) {
    return TrackingSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      elapsedDurationSeconds: data.elapsedDurationSeconds.present
          ? data.elapsedDurationSeconds.value
          : this.elapsedDurationSeconds,
      distanceInMeters: data.distanceInMeters.present
          ? data.distanceInMeters.value
          : this.distanceInMeters,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      averagePaceInSeconds: data.averagePaceInSeconds.present
          ? data.averagePaceInSeconds.value
          : this.averagePaceInSeconds,
      averageSpeedKmh: data.averageSpeedKmh.present
          ? data.averageSpeedKmh.value
          : this.averageSpeedKmh,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingSessionsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activityType: $activityType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('elapsedDurationSeconds: $elapsedDurationSeconds, ')
          ..write('distanceInMeters: $distanceInMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('averagePaceInSeconds: $averagePaceInSeconds, ')
          ..write('averageSpeedKmh: $averageSpeedKmh')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    activityType,
    status,
    startedAt,
    elapsedDurationSeconds,
    distanceInMeters,
    caloriesBurned,
    averagePaceInSeconds,
    averageSpeedKmh,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingSessionsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.activityType == this.activityType &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.elapsedDurationSeconds == this.elapsedDurationSeconds &&
          other.distanceInMeters == this.distanceInMeters &&
          other.caloriesBurned == this.caloriesBurned &&
          other.averagePaceInSeconds == this.averagePaceInSeconds &&
          other.averageSpeedKmh == this.averageSpeedKmh);
}

class TrackingSessionsTableCompanion
    extends UpdateCompanion<TrackingSessionsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<ActivityType> activityType;
  final Value<SessionStatus> status;
  final Value<DateTime> startedAt;
  final Value<int> elapsedDurationSeconds;
  final Value<double> distanceInMeters;
  final Value<int> caloriesBurned;
  final Value<int?> averagePaceInSeconds;
  final Value<double?> averageSpeedKmh;
  final Value<int> rowid;
  const TrackingSessionsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.elapsedDurationSeconds = const Value.absent(),
    this.distanceInMeters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.averagePaceInSeconds = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingSessionsTableCompanion.insert({
    required String id,
    required String userId,
    required ActivityType activityType,
    required SessionStatus status,
    required DateTime startedAt,
    this.elapsedDurationSeconds = const Value.absent(),
    this.distanceInMeters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.averagePaceInSeconds = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       activityType = Value(activityType),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<TrackingSessionsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? activityType,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<int>? elapsedDurationSeconds,
    Expression<double>? distanceInMeters,
    Expression<int>? caloriesBurned,
    Expression<int>? averagePaceInSeconds,
    Expression<double>? averageSpeedKmh,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (activityType != null) 'activity_type': activityType,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (elapsedDurationSeconds != null)
        'elapsed_duration_seconds': elapsedDurationSeconds,
      if (distanceInMeters != null) 'distance_in_meters': distanceInMeters,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (averagePaceInSeconds != null)
        'average_pace_in_seconds': averagePaceInSeconds,
      if (averageSpeedKmh != null) 'average_speed_kmh': averageSpeedKmh,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingSessionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<ActivityType>? activityType,
    Value<SessionStatus>? status,
    Value<DateTime>? startedAt,
    Value<int>? elapsedDurationSeconds,
    Value<double>? distanceInMeters,
    Value<int>? caloriesBurned,
    Value<int?>? averagePaceInSeconds,
    Value<double?>? averageSpeedKmh,
    Value<int>? rowid,
  }) {
    return TrackingSessionsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      elapsedDurationSeconds:
          elapsedDurationSeconds ?? this.elapsedDurationSeconds,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      averagePaceInSeconds: averagePaceInSeconds ?? this.averagePaceInSeconds,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $TrackingSessionsTableTable.$converteractivityType.toSql(
          activityType.value,
        ),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TrackingSessionsTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (elapsedDurationSeconds.present) {
      map['elapsed_duration_seconds'] = Variable<int>(
        elapsedDurationSeconds.value,
      );
    }
    if (distanceInMeters.present) {
      map['distance_in_meters'] = Variable<double>(distanceInMeters.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<int>(caloriesBurned.value);
    }
    if (averagePaceInSeconds.present) {
      map['average_pace_in_seconds'] = Variable<int>(
        averagePaceInSeconds.value,
      );
    }
    if (averageSpeedKmh.present) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activityType: $activityType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('elapsedDurationSeconds: $elapsedDurationSeconds, ')
          ..write('distanceInMeters: $distanceInMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('averagePaceInSeconds: $averagePaceInSeconds, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationPointsTableTable extends LocationPointsTable
    with TableInfo<$LocationPointsTableTable, LocationPointsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationPointsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceIdMeta = const VerificationMeta(
    'sequenceId',
  );
  @override
  late final GeneratedColumn<int> sequenceId = GeneratedColumn<int>(
    'sequence_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequenceId,
    sessionId,
    latitude,
    longitude,
    timestamp,
    altitude,
    speed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_points_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationPointsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence_id')) {
      context.handle(
        _sequenceIdMeta,
        sequenceId.isAcceptableOrUnknown(data['sequence_id']!, _sequenceIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequenceId};
  @override
  LocationPointsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationPointsTableData(
      sequenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
    );
  }

  @override
  $LocationPointsTableTable createAlias(String alias) {
    return $LocationPointsTableTable(attachedDatabase, alias);
  }
}

class LocationPointsTableData extends DataClass
    implements Insertable<LocationPointsTableData> {
  final int sequenceId;
  final String sessionId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? speed;
  const LocationPointsTableData({
    required this.sequenceId,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence_id'] = Variable<int>(sequenceId);
    map['session_id'] = Variable<String>(sessionId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    return map;
  }

  LocationPointsTableCompanion toCompanion(bool nullToAbsent) {
    return LocationPointsTableCompanion(
      sequenceId: Value(sequenceId),
      sessionId: Value(sessionId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
    );
  }

  factory LocationPointsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationPointsTableData(
      sequenceId: serializer.fromJson<int>(json['sequenceId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      speed: serializer.fromJson<double?>(json['speed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequenceId': serializer.toJson<int>(sequenceId),
      'sessionId': serializer.toJson<String>(sessionId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'altitude': serializer.toJson<double?>(altitude),
      'speed': serializer.toJson<double?>(speed),
    };
  }

  LocationPointsTableData copyWith({
    int? sequenceId,
    String? sessionId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    Value<double?> altitude = const Value.absent(),
    Value<double?> speed = const Value.absent(),
  }) => LocationPointsTableData(
    sequenceId: sequenceId ?? this.sequenceId,
    sessionId: sessionId ?? this.sessionId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
    altitude: altitude.present ? altitude.value : this.altitude,
    speed: speed.present ? speed.value : this.speed,
  );
  LocationPointsTableData copyWithCompanion(LocationPointsTableCompanion data) {
    return LocationPointsTableData(
      sequenceId: data.sequenceId.present
          ? data.sequenceId.value
          : this.sequenceId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      speed: data.speed.present ? data.speed.value : this.speed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointsTableData(')
          ..write('sequenceId: $sequenceId, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequenceId,
    sessionId,
    latitude,
    longitude,
    timestamp,
    altitude,
    speed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPointsTableData &&
          other.sequenceId == this.sequenceId &&
          other.sessionId == this.sessionId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.altitude == this.altitude &&
          other.speed == this.speed);
}

class LocationPointsTableCompanion
    extends UpdateCompanion<LocationPointsTableData> {
  final Value<int> sequenceId;
  final Value<String> sessionId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  final Value<double?> altitude;
  final Value<double?> speed;
  const LocationPointsTableCompanion({
    this.sequenceId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
  });
  LocationPointsTableCompanion.insert({
    this.sequenceId = const Value.absent(),
    required String sessionId,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
  }) : sessionId = Value(sessionId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp);
  static Insertable<LocationPointsTableData> custom({
    Expression<int>? sequenceId,
    Expression<String>? sessionId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<double>? altitude,
    Expression<double>? speed,
  }) {
    return RawValuesInsertable({
      if (sequenceId != null) 'sequence_id': sequenceId,
      if (sessionId != null) 'session_id': sessionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
    });
  }

  LocationPointsTableCompanion copyWith({
    Value<int>? sequenceId,
    Value<String>? sessionId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? timestamp,
    Value<double?>? altitude,
    Value<double?>? speed,
  }) {
    return LocationPointsTableCompanion(
      sequenceId: sequenceId ?? this.sequenceId,
      sessionId: sessionId ?? this.sessionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequenceId.present) {
      map['sequence_id'] = Variable<int>(sequenceId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointsTableCompanion(')
          ..write('sequenceId: $sequenceId, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed')
          ..write(')'))
        .toString();
  }
}

class $MissionInstancesTableTable extends MissionInstancesTable
    with TableInfo<$MissionInstancesTableTable, MissionInstancesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionInstancesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _missionTemplateIdMeta = const VerificationMeta(
    'missionTemplateId',
  );
  @override
  late final GeneratedColumn<String> missionTemplateId =
      GeneratedColumn<String>(
        'mission_template_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MissionAxis, String> axis =
      GeneratedColumn<String>(
        'axis',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MissionAxis>($MissionInstancesTableTable.$converteraxis);
  static const VerificationMeta _baselineValueMeta = const VerificationMeta(
    'baselineValue',
  );
  @override
  late final GeneratedColumn<double> baselineValue = GeneratedColumn<double>(
    'baseline_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _achievedTierMeta = const VerificationMeta(
    'achievedTier',
  );
  @override
  late final GeneratedColumn<int> achievedTier = GeneratedColumn<int>(
    'achieved_tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    missionTemplateId,
    axis,
    baselineValue,
    currentValue,
    achievedTier,
    partId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mission_instances_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionInstancesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('mission_template_id')) {
      context.handle(
        _missionTemplateIdMeta,
        missionTemplateId.isAcceptableOrUnknown(
          data['mission_template_id']!,
          _missionTemplateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_missionTemplateIdMeta);
    }
    if (data.containsKey('baseline_value')) {
      context.handle(
        _baselineValueMeta,
        baselineValue.isAcceptableOrUnknown(
          data['baseline_value']!,
          _baselineValueMeta,
        ),
      );
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('achieved_tier')) {
      context.handle(
        _achievedTierMeta,
        achievedTier.isAcceptableOrUnknown(
          data['achieved_tier']!,
          _achievedTierMeta,
        ),
      );
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionInstancesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionInstancesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      missionTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_template_id'],
      )!,
      axis: $MissionInstancesTableTable.$converteraxis.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}axis'],
        )!,
      ),
      baselineValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_value'],
      ),
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      achievedTier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_tier'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      ),
    );
  }

  @override
  $MissionInstancesTableTable createAlias(String alias) {
    return $MissionInstancesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MissionAxis, String, String> $converteraxis =
      const EnumNameConverter<MissionAxis>(MissionAxis.values);
}

class MissionInstancesTableData extends DataClass
    implements Insertable<MissionInstancesTableData> {
  final String id;
  final String sessionId;
  final String missionTemplateId;
  final MissionAxis axis;
  final double? baselineValue;
  final double currentValue;
  final int achievedTier;
  final String? partId;
  const MissionInstancesTableData({
    required this.id,
    required this.sessionId,
    required this.missionTemplateId,
    required this.axis,
    this.baselineValue,
    required this.currentValue,
    required this.achievedTier,
    this.partId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['mission_template_id'] = Variable<String>(missionTemplateId);
    {
      map['axis'] = Variable<String>(
        $MissionInstancesTableTable.$converteraxis.toSql(axis),
      );
    }
    if (!nullToAbsent || baselineValue != null) {
      map['baseline_value'] = Variable<double>(baselineValue);
    }
    map['current_value'] = Variable<double>(currentValue);
    map['achieved_tier'] = Variable<int>(achievedTier);
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<String>(partId);
    }
    return map;
  }

  MissionInstancesTableCompanion toCompanion(bool nullToAbsent) {
    return MissionInstancesTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      missionTemplateId: Value(missionTemplateId),
      axis: Value(axis),
      baselineValue: baselineValue == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineValue),
      currentValue: Value(currentValue),
      achievedTier: Value(achievedTier),
      partId: partId == null && nullToAbsent
          ? const Value.absent()
          : Value(partId),
    );
  }

  factory MissionInstancesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionInstancesTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      missionTemplateId: serializer.fromJson<String>(json['missionTemplateId']),
      axis: $MissionInstancesTableTable.$converteraxis.fromJson(
        serializer.fromJson<String>(json['axis']),
      ),
      baselineValue: serializer.fromJson<double?>(json['baselineValue']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      achievedTier: serializer.fromJson<int>(json['achievedTier']),
      partId: serializer.fromJson<String?>(json['partId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'missionTemplateId': serializer.toJson<String>(missionTemplateId),
      'axis': serializer.toJson<String>(
        $MissionInstancesTableTable.$converteraxis.toJson(axis),
      ),
      'baselineValue': serializer.toJson<double?>(baselineValue),
      'currentValue': serializer.toJson<double>(currentValue),
      'achievedTier': serializer.toJson<int>(achievedTier),
      'partId': serializer.toJson<String?>(partId),
    };
  }

  MissionInstancesTableData copyWith({
    String? id,
    String? sessionId,
    String? missionTemplateId,
    MissionAxis? axis,
    Value<double?> baselineValue = const Value.absent(),
    double? currentValue,
    int? achievedTier,
    Value<String?> partId = const Value.absent(),
  }) => MissionInstancesTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    missionTemplateId: missionTemplateId ?? this.missionTemplateId,
    axis: axis ?? this.axis,
    baselineValue: baselineValue.present
        ? baselineValue.value
        : this.baselineValue,
    currentValue: currentValue ?? this.currentValue,
    achievedTier: achievedTier ?? this.achievedTier,
    partId: partId.present ? partId.value : this.partId,
  );
  MissionInstancesTableData copyWithCompanion(
    MissionInstancesTableCompanion data,
  ) {
    return MissionInstancesTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      missionTemplateId: data.missionTemplateId.present
          ? data.missionTemplateId.value
          : this.missionTemplateId,
      axis: data.axis.present ? data.axis.value : this.axis,
      baselineValue: data.baselineValue.present
          ? data.baselineValue.value
          : this.baselineValue,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      achievedTier: data.achievedTier.present
          ? data.achievedTier.value
          : this.achievedTier,
      partId: data.partId.present ? data.partId.value : this.partId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionInstancesTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('missionTemplateId: $missionTemplateId, ')
          ..write('axis: $axis, ')
          ..write('baselineValue: $baselineValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('achievedTier: $achievedTier, ')
          ..write('partId: $partId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    missionTemplateId,
    axis,
    baselineValue,
    currentValue,
    achievedTier,
    partId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionInstancesTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.missionTemplateId == this.missionTemplateId &&
          other.axis == this.axis &&
          other.baselineValue == this.baselineValue &&
          other.currentValue == this.currentValue &&
          other.achievedTier == this.achievedTier &&
          other.partId == this.partId);
}

class MissionInstancesTableCompanion
    extends UpdateCompanion<MissionInstancesTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> missionTemplateId;
  final Value<MissionAxis> axis;
  final Value<double?> baselineValue;
  final Value<double> currentValue;
  final Value<int> achievedTier;
  final Value<String?> partId;
  final Value<int> rowid;
  const MissionInstancesTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.missionTemplateId = const Value.absent(),
    this.axis = const Value.absent(),
    this.baselineValue = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.achievedTier = const Value.absent(),
    this.partId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionInstancesTableCompanion.insert({
    required String id,
    required String sessionId,
    required String missionTemplateId,
    required MissionAxis axis,
    this.baselineValue = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.achievedTier = const Value.absent(),
    this.partId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       missionTemplateId = Value(missionTemplateId),
       axis = Value(axis);
  static Insertable<MissionInstancesTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? missionTemplateId,
    Expression<String>? axis,
    Expression<double>? baselineValue,
    Expression<double>? currentValue,
    Expression<int>? achievedTier,
    Expression<String>? partId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (missionTemplateId != null) 'mission_template_id': missionTemplateId,
      if (axis != null) 'axis': axis,
      if (baselineValue != null) 'baseline_value': baselineValue,
      if (currentValue != null) 'current_value': currentValue,
      if (achievedTier != null) 'achieved_tier': achievedTier,
      if (partId != null) 'part_id': partId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionInstancesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? missionTemplateId,
    Value<MissionAxis>? axis,
    Value<double?>? baselineValue,
    Value<double>? currentValue,
    Value<int>? achievedTier,
    Value<String?>? partId,
    Value<int>? rowid,
  }) {
    return MissionInstancesTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      missionTemplateId: missionTemplateId ?? this.missionTemplateId,
      axis: axis ?? this.axis,
      baselineValue: baselineValue ?? this.baselineValue,
      currentValue: currentValue ?? this.currentValue,
      achievedTier: achievedTier ?? this.achievedTier,
      partId: partId ?? this.partId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (missionTemplateId.present) {
      map['mission_template_id'] = Variable<String>(missionTemplateId.value);
    }
    if (axis.present) {
      map['axis'] = Variable<String>(
        $MissionInstancesTableTable.$converteraxis.toSql(axis.value),
      );
    }
    if (baselineValue.present) {
      map['baseline_value'] = Variable<double>(baselineValue.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (achievedTier.present) {
      map['achieved_tier'] = Variable<int>(achievedTier.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionInstancesTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('missionTemplateId: $missionTemplateId, ')
          ..write('axis: $axis, ')
          ..write('baselineValue: $baselineValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('achievedTier: $achievedTier, ')
          ..write('partId: $partId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackingSessionsTableTable trackingSessionsTable =
      $TrackingSessionsTableTable(this);
  late final $LocationPointsTableTable locationPointsTable =
      $LocationPointsTableTable(this);
  late final $MissionInstancesTableTable missionInstancesTable =
      $MissionInstancesTableTable(this);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trackingSessionsTable,
    locationPointsTable,
    missionInstancesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracking_sessions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('location_points_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracking_sessions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mission_instances_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TrackingSessionsTableTableCreateCompanionBuilder =
    TrackingSessionsTableCompanion Function({
      required String id,
      required String userId,
      required ActivityType activityType,
      required SessionStatus status,
      required DateTime startedAt,
      Value<int> elapsedDurationSeconds,
      Value<double> distanceInMeters,
      Value<int> caloriesBurned,
      Value<int?> averagePaceInSeconds,
      Value<double?> averageSpeedKmh,
      Value<int> rowid,
    });
typedef $$TrackingSessionsTableTableUpdateCompanionBuilder =
    TrackingSessionsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<ActivityType> activityType,
      Value<SessionStatus> status,
      Value<DateTime> startedAt,
      Value<int> elapsedDurationSeconds,
      Value<double> distanceInMeters,
      Value<int> caloriesBurned,
      Value<int?> averagePaceInSeconds,
      Value<double?> averageSpeedKmh,
      Value<int> rowid,
    });

final class $$TrackingSessionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackingSessionsTableTable,
          TrackingSessionsTableData
        > {
  $$TrackingSessionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $LocationPointsTableTable,
    List<LocationPointsTableData>
  >
  _locationPointsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.locationPointsTable,
        aliasName:
            'tracking_sessions_table__id__location_points_table__session_id',
      );

  $$LocationPointsTableTableProcessedTableManager get locationPointsTableRefs {
    final manager = $$LocationPointsTableTableTableManager(
      $_db,
      $_db.locationPointsTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _locationPointsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MissionInstancesTableTable,
    List<MissionInstancesTableData>
  >
  _missionInstancesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.missionInstancesTable,
        aliasName:
            'tracking_sessions_table__id__mission_instances_table__session_id',
      );

  $$MissionInstancesTableTableProcessedTableManager
  get missionInstancesTableRefs {
    final manager = $$MissionInstancesTableTableTableManager(
      $_db,
      $_db.missionInstancesTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _missionInstancesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackingSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTableTable> {
  $$TrackingSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceInMeters => $composableBuilder(
    column: $table.distanceInMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get averagePaceInSeconds => $composableBuilder(
    column: $table.averagePaceInSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> locationPointsTableRefs(
    Expression<bool> Function($$LocationPointsTableTableFilterComposer f) f,
  ) {
    final $$LocationPointsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.locationPointsTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationPointsTableTableFilterComposer(
            $db: $db,
            $table: $db.locationPointsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> missionInstancesTableRefs(
    Expression<bool> Function($$MissionInstancesTableTableFilterComposer f) f,
  ) {
    final $$MissionInstancesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.missionInstancesTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MissionInstancesTableTableFilterComposer(
                $db: $db,
                $table: $db.missionInstancesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackingSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTableTable> {
  $$TrackingSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceInMeters => $composableBuilder(
    column: $table.distanceInMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averagePaceInSeconds => $composableBuilder(
    column: $table.averagePaceInSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackingSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTableTable> {
  $$TrackingSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceInMeters => $composableBuilder(
    column: $table.distanceInMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get averagePaceInSeconds => $composableBuilder(
    column: $table.averagePaceInSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => column,
  );

  Expression<T> locationPointsTableRefs<T extends Object>(
    Expression<T> Function($$LocationPointsTableTableAnnotationComposer a) f,
  ) {
    final $$LocationPointsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.locationPointsTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocationPointsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.locationPointsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> missionInstancesTableRefs<T extends Object>(
    Expression<T> Function($$MissionInstancesTableTableAnnotationComposer a) f,
  ) {
    final $$MissionInstancesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.missionInstancesTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MissionInstancesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.missionInstancesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackingSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackingSessionsTableTable,
          TrackingSessionsTableData,
          $$TrackingSessionsTableTableFilterComposer,
          $$TrackingSessionsTableTableOrderingComposer,
          $$TrackingSessionsTableTableAnnotationComposer,
          $$TrackingSessionsTableTableCreateCompanionBuilder,
          $$TrackingSessionsTableTableUpdateCompanionBuilder,
          (TrackingSessionsTableData, $$TrackingSessionsTableTableReferences),
          TrackingSessionsTableData,
          PrefetchHooks Function({
            bool locationPointsTableRefs,
            bool missionInstancesTableRefs,
          })
        > {
  $$TrackingSessionsTableTableTableManager(
    _$AppDatabase db,
    $TrackingSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingSessionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrackingSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackingSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<ActivityType> activityType = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> elapsedDurationSeconds = const Value.absent(),
                Value<double> distanceInMeters = const Value.absent(),
                Value<int> caloriesBurned = const Value.absent(),
                Value<int?> averagePaceInSeconds = const Value.absent(),
                Value<double?> averageSpeedKmh = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackingSessionsTableCompanion(
                id: id,
                userId: userId,
                activityType: activityType,
                status: status,
                startedAt: startedAt,
                elapsedDurationSeconds: elapsedDurationSeconds,
                distanceInMeters: distanceInMeters,
                caloriesBurned: caloriesBurned,
                averagePaceInSeconds: averagePaceInSeconds,
                averageSpeedKmh: averageSpeedKmh,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required ActivityType activityType,
                required SessionStatus status,
                required DateTime startedAt,
                Value<int> elapsedDurationSeconds = const Value.absent(),
                Value<double> distanceInMeters = const Value.absent(),
                Value<int> caloriesBurned = const Value.absent(),
                Value<int?> averagePaceInSeconds = const Value.absent(),
                Value<double?> averageSpeedKmh = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackingSessionsTableCompanion.insert(
                id: id,
                userId: userId,
                activityType: activityType,
                status: status,
                startedAt: startedAt,
                elapsedDurationSeconds: elapsedDurationSeconds,
                distanceInMeters: distanceInMeters,
                caloriesBurned: caloriesBurned,
                averagePaceInSeconds: averagePaceInSeconds,
                averageSpeedKmh: averageSpeedKmh,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TrackingSessionsTableTable,
                    TrackingSessionsTableData
                  >(table),
                  $$TrackingSessionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                locationPointsTableRefs = false,
                missionInstancesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (locationPointsTableRefs) db.locationPointsTable,
                    if (missionInstancesTableRefs) db.missionInstancesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (locationPointsTableRefs)
                        await $_getPrefetchedData<
                          TrackingSessionsTableData,
                          $TrackingSessionsTableTable,
                          LocationPointsTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$TrackingSessionsTableTableReferences
                                  ._locationPointsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).locationPointsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (missionInstancesTableRefs)
                        await $_getPrefetchedData<
                          TrackingSessionsTableData,
                          $TrackingSessionsTableTable,
                          MissionInstancesTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$TrackingSessionsTableTableReferences
                                  ._missionInstancesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).missionInstancesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TrackingSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackingSessionsTableTable,
      TrackingSessionsTableData,
      $$TrackingSessionsTableTableFilterComposer,
      $$TrackingSessionsTableTableOrderingComposer,
      $$TrackingSessionsTableTableAnnotationComposer,
      $$TrackingSessionsTableTableCreateCompanionBuilder,
      $$TrackingSessionsTableTableUpdateCompanionBuilder,
      (TrackingSessionsTableData, $$TrackingSessionsTableTableReferences),
      TrackingSessionsTableData,
      PrefetchHooks Function({
        bool locationPointsTableRefs,
        bool missionInstancesTableRefs,
      })
    >;
typedef $$LocationPointsTableTableCreateCompanionBuilder =
    LocationPointsTableCompanion Function({
      Value<int> sequenceId,
      required String sessionId,
      required double latitude,
      required double longitude,
      required DateTime timestamp,
      Value<double?> altitude,
      Value<double?> speed,
    });
typedef $$LocationPointsTableTableUpdateCompanionBuilder =
    LocationPointsTableCompanion Function({
      Value<int> sequenceId,
      Value<String> sessionId,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> timestamp,
      Value<double?> altitude,
      Value<double?> speed,
    });

final class $$LocationPointsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocationPointsTableTable,
          LocationPointsTableData
        > {
  $$LocationPointsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackingSessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessionsTable.createAlias(
        'location_points_table__session_id__tracking_sessions_table__id',
      );

  $$TrackingSessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$TrackingSessionsTableTableTableManager(
      $_db,
      $_db.trackingSessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocationPointsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocationPointsTableTable> {
  $$LocationPointsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableTableFilterComposer get sessionId {
    final $$TrackingSessionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableFilterComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocationPointsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationPointsTableTable> {
  $$LocationPointsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableOrderingComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocationPointsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationPointsTableTable> {
  $$LocationPointsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  $$TrackingSessionsTableTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocationPointsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationPointsTableTable,
          LocationPointsTableData,
          $$LocationPointsTableTableFilterComposer,
          $$LocationPointsTableTableOrderingComposer,
          $$LocationPointsTableTableAnnotationComposer,
          $$LocationPointsTableTableCreateCompanionBuilder,
          $$LocationPointsTableTableUpdateCompanionBuilder,
          (LocationPointsTableData, $$LocationPointsTableTableReferences),
          LocationPointsTableData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$LocationPointsTableTableTableManager(
    _$AppDatabase db,
    $LocationPointsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationPointsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationPointsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocationPointsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sequenceId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
              }) => LocationPointsTableCompanion(
                sequenceId: sequenceId,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                altitude: altitude,
                speed: speed,
              ),
          createCompanionCallback:
              ({
                Value<int> sequenceId = const Value.absent(),
                required String sessionId,
                required double latitude,
                required double longitude,
                required DateTime timestamp,
                Value<double?> altitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
              }) => LocationPointsTableCompanion.insert(
                sequenceId: sequenceId,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                altitude: altitude,
                speed: speed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocationPointsTableTable,
                    LocationPointsTableData
                  >(table),
                  $$LocationPointsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$LocationPointsTableTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$LocationPointsTableTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocationPointsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationPointsTableTable,
      LocationPointsTableData,
      $$LocationPointsTableTableFilterComposer,
      $$LocationPointsTableTableOrderingComposer,
      $$LocationPointsTableTableAnnotationComposer,
      $$LocationPointsTableTableCreateCompanionBuilder,
      $$LocationPointsTableTableUpdateCompanionBuilder,
      (LocationPointsTableData, $$LocationPointsTableTableReferences),
      LocationPointsTableData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MissionInstancesTableTableCreateCompanionBuilder =
    MissionInstancesTableCompanion Function({
      required String id,
      required String sessionId,
      required String missionTemplateId,
      required MissionAxis axis,
      Value<double?> baselineValue,
      Value<double> currentValue,
      Value<int> achievedTier,
      Value<String?> partId,
      Value<int> rowid,
    });
typedef $$MissionInstancesTableTableUpdateCompanionBuilder =
    MissionInstancesTableCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> missionTemplateId,
      Value<MissionAxis> axis,
      Value<double?> baselineValue,
      Value<double> currentValue,
      Value<int> achievedTier,
      Value<String?> partId,
      Value<int> rowid,
    });

final class $$MissionInstancesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MissionInstancesTableTable,
          MissionInstancesTableData
        > {
  $$MissionInstancesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackingSessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessionsTable.createAlias(
        'mission_instances_table__session_id__tracking_sessions_table__id',
      );

  $$TrackingSessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$TrackingSessionsTableTableTableManager(
      $_db,
      $_db.trackingSessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MissionInstancesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MissionInstancesTableTable> {
  $$MissionInstancesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missionTemplateId => $composableBuilder(
    column: $table.missionTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MissionAxis, MissionAxis, String> get axis =>
      $composableBuilder(
        column: $table.axis,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get baselineValue => $composableBuilder(
    column: $table.baselineValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedTier => $composableBuilder(
    column: $table.achievedTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableTableFilterComposer get sessionId {
    final $$TrackingSessionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableFilterComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MissionInstancesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionInstancesTableTable> {
  $$MissionInstancesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missionTemplateId => $composableBuilder(
    column: $table.missionTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get axis => $composableBuilder(
    column: $table.axis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineValue => $composableBuilder(
    column: $table.baselineValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedTier => $composableBuilder(
    column: $table.achievedTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableOrderingComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MissionInstancesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionInstancesTableTable> {
  $$MissionInstancesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get missionTemplateId => $composableBuilder(
    column: $table.missionTemplateId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MissionAxis, String> get axis =>
      $composableBuilder(column: $table.axis, builder: (column) => column);

  GeneratedColumn<double> get baselineValue => $composableBuilder(
    column: $table.baselineValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedTier => $composableBuilder(
    column: $table.achievedTier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  $$TrackingSessionsTableTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.trackingSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackingSessionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackingSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MissionInstancesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionInstancesTableTable,
          MissionInstancesTableData,
          $$MissionInstancesTableTableFilterComposer,
          $$MissionInstancesTableTableOrderingComposer,
          $$MissionInstancesTableTableAnnotationComposer,
          $$MissionInstancesTableTableCreateCompanionBuilder,
          $$MissionInstancesTableTableUpdateCompanionBuilder,
          (MissionInstancesTableData, $$MissionInstancesTableTableReferences),
          MissionInstancesTableData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$MissionInstancesTableTableTableManager(
    _$AppDatabase db,
    $MissionInstancesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionInstancesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MissionInstancesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MissionInstancesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> missionTemplateId = const Value.absent(),
                Value<MissionAxis> axis = const Value.absent(),
                Value<double?> baselineValue = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<int> achievedTier = const Value.absent(),
                Value<String?> partId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionInstancesTableCompanion(
                id: id,
                sessionId: sessionId,
                missionTemplateId: missionTemplateId,
                axis: axis,
                baselineValue: baselineValue,
                currentValue: currentValue,
                achievedTier: achievedTier,
                partId: partId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String missionTemplateId,
                required MissionAxis axis,
                Value<double?> baselineValue = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<int> achievedTier = const Value.absent(),
                Value<String?> partId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionInstancesTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                missionTemplateId: missionTemplateId,
                axis: axis,
                baselineValue: baselineValue,
                currentValue: currentValue,
                achievedTier: achievedTier,
                partId: partId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $MissionInstancesTableTable,
                    MissionInstancesTableData
                  >(table),
                  $$MissionInstancesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$MissionInstancesTableTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$MissionInstancesTableTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MissionInstancesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionInstancesTableTable,
      MissionInstancesTableData,
      $$MissionInstancesTableTableFilterComposer,
      $$MissionInstancesTableTableOrderingComposer,
      $$MissionInstancesTableTableAnnotationComposer,
      $$MissionInstancesTableTableCreateCompanionBuilder,
      $$MissionInstancesTableTableUpdateCompanionBuilder,
      (MissionInstancesTableData, $$MissionInstancesTableTableReferences),
      MissionInstancesTableData,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackingSessionsTableTableTableManager get trackingSessionsTable =>
      $$TrackingSessionsTableTableTableManager(_db, _db.trackingSessionsTable);
  $$LocationPointsTableTableTableManager get locationPointsTable =>
      $$LocationPointsTableTableTableManager(_db, _db.locationPointsTable);
  $$MissionInstancesTableTableTableManager get missionInstancesTable =>
      $$MissionInstancesTableTableTableManager(_db, _db.missionInstancesTable);
}
