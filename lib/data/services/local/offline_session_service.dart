import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/session/session_result.dart';
import 'database/app_database.dart';
import 'database/daos/offline_session_queue_dao.dart';

class OfflineSessionService {
  final OfflineSessionQueueDao _queueDao;

  OfflineSessionService(this._queueDao);

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

  Future<String> saveSketchImage({
    required String sessionId,
    required Uint8List bytes,
  }) async {
    final directory = await _getSketchDirectory();
    final file = File('${directory.path}/$sessionId.png');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Uint8List?> readSketchImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    return null;
  }

  Future<void> deleteSketchImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

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

  Future<List<OfflineSessionQueueTableData>> getPendingSessions(String userId) {
    return _queueDao.getPendingSessions(userId);
  }

  Future<OfflineSessionQueueTableData?> getQueueItemById(String sessionId) {
    return _queueDao.getQueueItemById(sessionId);
  }

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

  Future<void> deleteSession(String sessionId) async {
    final item = await _queueDao.getQueueItemById(sessionId);
    if (item != null) {
      await deleteSketchImage(item.sketchImagePath);
    }

    await _queueDao.deleteQueueItem(sessionId);
  }

  Stream<int> watchPendingCount(String userId) {
    return _queueDao.watchPendingCount(userId);
  }
}
