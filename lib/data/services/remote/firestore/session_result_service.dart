import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/enums/activity_type.dart';
import '../../../../domain/models/session/session_result.dart';
import '../../../../utils/date_time_utils.dart';

/// Firestore `session_results` 컬렉션에 완료된 운동 세션 결과를 저장·조회·수정·논리 삭제하는 서비스 클래스입니다.
class SessionResultService {
  final FirebaseFirestore _firestore;

  SessionResultService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _resultsRef =>
      _firestore.collection('session_results');

  /// 완료된 운동 세션 결과([result])를 서버 타임스탬프와 함께 저장하고, 서버가 확정한 최신 문서를 반환합니다.
  Future<SessionResult> saveResult(SessionResult result) async {
    final data = result.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    data.remove('updatedAt');

    final resultRef = _resultsRef.doc(result.id);
    await resultRef.set(data);

    final savedDoc = await resultRef.get();
    return SessionResult.fromMap(savedDoc.data()!);
  }

  /// 결과 고유 식별자([resultId])에 해당하는 단건 세션 결과를 조회합니다.
  Future<SessionResult?> getResultById(String resultId) async {
    final doc = await _resultsRef.doc(resultId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final result = SessionResult.fromMap(doc.data()!, id: doc.id);
    if (result.isDeleted) {
      return null;
    }
    return result;
  }

  /// 지정된 사용자([userId])의 삭제되지 않은 가장 최근 완료 세션 결과를 조회합니다.
  Future<SessionResult?> getLatestResult(String userId) async {
    final querySnapshot = await _resultsRef
        .where('userId', isEqualTo: userId)
        .where('deletedAt', isNull: true)
        .orderBy('endedAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    return SessionResult.fromMap(doc.data(), id: doc.id);
  }

  /// 지정된 기준 시각([since]) 이후 사용자([userId])가 완료한 세션의 시작 일시 목록을 조회합니다.
  ///
  /// 과거 ISO-8601 문자열 포맷으로 저장된 레거시 문서를 누락 없이 포함하기 위해
  /// [Timestamp] 쿼리와 문자열 범위 쿼리를 병렬 실행한 뒤 문서 ID 기준으로 중복을 제거합니다.
  Future<List<DateTime>> getCompletedDatesSince({
    required String userId,
    required DateTime since,
  }) async {
    final timestampQuery = _resultsRef
        .where('userId', isEqualTo: userId)
        .where('endedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('endedAt', descending: true)
        .get();

    final stringQuery = _resultsRef
        .where('userId', isEqualTo: userId)
        .where(
          'endedAt',
          isGreaterThanOrEqualTo: since.toUtc().toIso8601String(),
        )
        .orderBy('endedAt', descending: true)
        .get();

    final snapshots = await Future.wait([timestampQuery, stringQuery]);

    final documentMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final snapshot in snapshots) {
      for (final document in snapshot.docs) {
        documentMap[document.id] = document;
      }
    }

    return documentMap.values
        .where((document) => document.data()['deletedAt'] == null)
        .map(
          (document) => parseDateTime(document.data()['startedAt']).toLocal(),
        )
        .toList();
  }

  /// 특정 연도([year]) 및 월([month])에 사용자([userId])가 완료한 세션 결과 목록을 최신순으로 조회합니다.
  ///
  /// 레거시 문자열 날짜 문서 호환을 위해 [Timestamp] 쿼리와 문자열 쿼리를 병렬 조회하여 병합합니다.
  Future<List<SessionResult>> getResultsByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final startOfMonth = DateTime(year, month, 1).toUtc();
    final nextMonth = month % 12 + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final startOfNextMonth = DateTime(nextYear, nextMonth, 1).toUtc();

    final timestampQuery = _resultsRef
        .where('userId', isEqualTo: userId)
        .where(
          'endedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('endedAt', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .orderBy('endedAt', descending: true)
        .get();

    final stringQuery = _resultsRef
        .where('userId', isEqualTo: userId)
        .where(
          'endedAt',
          isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
        )
        .where('endedAt', isLessThan: startOfNextMonth.toIso8601String())
        .orderBy('endedAt', descending: true)
        .get();

    final snapshots = await Future.wait([timestampQuery, stringQuery]);

    final documentMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final snapshot in snapshots) {
      for (final document in snapshot.docs) {
        documentMap[document.id] = document;
      }
    }

    final parsedResults = documentMap.values
        .map(
          (document) => SessionResult.fromMap(document.data(), id: document.id),
        )
        .where((result) => !result.isDeleted)
        .toList();

    parsedResults.sort(
      (firstResult, secondResult) =>
          secondResult.endedAt.compareTo(firstResult.endedAt),
    );

    return parsedResults;
  }

  /// 지정된 세션 결과([resultId])의 비공개 운동 메모([secretMemo])를 갱신합니다.
  Future<void> updateSecretMemo({
    required String resultId,
    required String secretMemo,
  }) async {
    await _resultsRef.doc(resultId).update({
      'secretMemo': secretMemo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 지정된 세션 결과([resultId])의 소셜 피드 공유 여부([isShared])를 갱신합니다.
  Future<void> updateShareStatus({
    required String resultId,
    required bool isShared,
  }) async {
    await _resultsRef.doc(resultId).update({
      'isShared': isShared,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 지정된 세션 결과([resultId])의 행정구역 위치 태그 목록([locationTags])을 갱신합니다.
  Future<void> updateLocationTags({
    required String resultId,
    required List<String> locationTags,
  }) async {
    await _resultsRef.doc(resultId).update({
      'locationTags': locationTags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 지정된 세션 결과([resultId])에 삭제 시각(`deletedAt`)을 기록하여 소프트 딜리트 처리합니다.
  Future<void> deleteResult(String resultId) async {
    await _resultsRef.doc(resultId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 미션 기준치 산정을 위해 사용자([userId])의 특정 종목([activityType]) 최근 완료 결과를 조회합니다.
  Future<List<SessionResult>> getRecentResults({
    required String userId,
    required ActivityType activityType,
    int limit = 5,
  }) async {
    final querySnapshot = await _resultsRef
        .where('userId', isEqualTo: userId)
        .where('activityType', isEqualTo: activityType.name)
        .orderBy('endedAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => SessionResult.fromMap(doc.data(), id: doc.id))
        .where((result) => !result.isDeleted)
        .toList();
  }
}
