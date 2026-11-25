import 'package:drift/drift.dart';

import '../../../../../domain/models/enums/sync_status.dart';

/// 네트워크 단절 등으로 원격 서버에 즉시 업로드되지 못한 완료 세션을 보관하는 오프라인 동기화 큐 테이블입니다.
class OfflineSessionQueueTable extends Table {
  /// 대기 작업 고유 식별자. (완료된 세션 ID와 동일, 기본키)
  TextColumn get id => text()();

  /// 세션을 소유한 사용자의 고유 식별자.
  TextColumn get userId => text()();

  /// 직렬화된 `SessionResult` JSON 문자열.
  TextColumn get sessionResultJson => text()();

  /// 로컬 파일 시스템에 임시 저장된 완성 스케치 이미지 파일 경로.
  TextColumn get sketchImagePath => text()();

  /// 대기 작업이 큐에 적재된 일시.
  DateTimeColumn get createdAt => dateTime()();

  /// 원격 동기화 진행 상태.
  TextColumn get syncStatus => textEnum<SyncStatus>()();

  /// 동기화 실패 후 재시도한 누적 횟수.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// 가장 최근에 동기화를 시도한 일시.
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();

  /// 최근 동기화 시도 실패 시 발생한 오류 메시지.
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
