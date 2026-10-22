import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/enums/activity_type.dart';
import '../../../../domain/models/session/session_result.dart';
import '../../../../utils/date_time_utils.dart';

class SessionResultService {
  final FirebaseFirestore _firestore;

  SessionResultService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _resultsRef =>
      _firestore.collection('session_results');

  Future<SessionResult> saveResult(SessionResult result) async {
    final data = result.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    data.remove('updatedAt');

    final resultRef = _resultsRef.doc(result.id);
    await resultRef.set(data);

    final savedDoc = await resultRef.get();
    return SessionResult.fromMap(savedDoc.data()!);
  }

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

  Future<void> updateSecretMemo({
    required String resultId,
    required String secretMemo,
  }) async {
    await _resultsRef.doc(resultId).update({
      'secretMemo': secretMemo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateShareStatus({
    required String resultId,
    required bool isShared,
  }) async {
    await _resultsRef.doc(resultId).update({
      'isShared': isShared,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocationTags({
    required String resultId,
    required List<String> locationTags,
  }) async {
    await _resultsRef.doc(resultId).update({
      'locationTags': locationTags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteResult(String resultId) async {
    await _resultsRef.doc(resultId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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
