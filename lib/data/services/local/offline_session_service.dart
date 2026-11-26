import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/session/session_result.dart';
import 'database/app_database.dart';
import 'database/daos/offline_session_queue_dao.dart';

/// 미동기화 세션의 스케치 이미지 파일과 [OfflineSessionQueueDao] 대기 큐를 함께 관리하는 로컬 서비스 클래스입니다.
class OfflineSessionService {
  final OfflineSessionQueueDao _queueDao;

  OfflineSessionService(this._queueDao);

  // 앱 지원 디렉터리 하위의 오프라인 스케치 임시 저장 폴더를 확보하여 반환합니다.
  Future<Directory> _getSketchDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final sketchDirectory = Directory(
      '${supportDirectory.path}/offline_sketches',
    );

    if (!await sketchDirectory.exists()) {
      await sketchDirectory.create(recursive: true);
    }

    return sketchDirectory;
  }

  /// 완성된 스케치 이미지 바이너리([bytes])를 로컬 파일로 저장하고 생성된 파일 경로를 반환합니다.
  Future<String> saveSketchImage({
    required String sessionId,
    required Uint8List bytes,
  }) async {
    final directory = await _getSketchDirectory();
    final file = File('${directory.path}/$sessionId.png');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// 지정된 경로([imagePath])에 저장된 스케치 이미지 파일을 읽어 바이너리 데이터로 반환합니다.
  Future<Uint8List?> readSketchImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    return null;
  }

  /// 지정된 경로([imagePath])의 로컬 스케치 이미지 파일이 존재하는 경우 삭제합니다.
  Future<void> deleteSketchImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 완료된 세션 결과([sessionResult])를 JSON으로 직렬화하여 오프라인 동기화 큐에 적재합니다.
  Future<void> enqueueSession({
    required SessionResult sessionResult,
    required String sketchImagePath,
    SyncStatus syncStatus = SyncStatus.syncFailed,
  }) {
    final jsonString = jsonEncode(sessionResult.toMap());
    final companion = OfflineSessionQueueTableCompanion.insert(
      id: sessionResult.id,
      userId: sessionResult.userId,
      sessionResultJson: jsonString,
      sketchImagePath: sketchImagePath,
      syncStatus: syncStatus,
      createdAt: DateTime.now(),
    );

    return _queueDao.enqueueSession(companion);
  }

  /// 지정된 사용자([userId])의 미동기화 대기 항목 목록을 조회하여 반환합니다.
  Future<List<OfflineSessionQueueTableData>> getPendingSessions(String userId) {
    return _queueDao.getPendingSessions(userId);
  }

  /// 세션 식별자([sessionId])에 해당하는 단일 대기 항목을 조회합니다.
  Future<OfflineSessionQueueTableData?> getQueueItemById(String sessionId) {
    return _queueDao.getQueueItemById(sessionId);
  }

  /// 지정된 대기 항목([sessionId])의 동기화 상태([status]), 시도 일시 및 오류 메시지를 갱신합니다.
  Future<void> updateSyncStatus({
    required String sessionId,
    required SyncStatus status,
    DateTime? lastAttemptedAt,
    String? errorMessage,
    bool incrementRetry = false,
  }) {
    return _queueDao.updateSyncStatus(
      sessionId: sessionId,
      status: status,
      lastAttemptedAt: lastAttemptedAt,
      errorMessage: errorMessage,
      incrementRetry: incrementRetry,
    );
  }

  /// 지정된 세션([sessionId])의 로컬 스케치 이미지 파일과 대기 큐 레코드를 함께 삭제합니다.
  Future<void> deleteSession(String sessionId) async {
    final item = await _queueDao.getQueueItemById(sessionId);
    if (item != null) {
      await deleteSketchImage(item.sketchImagePath);
    }

    await _queueDao.deleteQueueItem(sessionId);
  }

  /// 지정된 사용자([userId])의 미동기화 대기 작업 개수를 실시간 스트림으로 감시합니다.
  Stream<int> watchPendingCount(String userId) {
    return _queueDao.watchPendingCount(userId);
  }
}
