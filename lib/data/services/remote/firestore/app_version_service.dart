import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/system/app_version_policy.dart';

/// Firestore `app_config/version` 문서에서 앱 버전 업데이트 정책을 조회하고 갱신하는 서비스 클래스입니다.
class AppVersionService {
  final FirebaseFirestore _firestore;

  AppVersionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _versionDocRef =>
      _firestore.collection('app_config').doc('version');

  /// 원격 저장소에 등록된 최신 앱 버전 정책을 조회하여 [AppVersionPolicy]로 반환합니다.
  Future<AppVersionPolicy?> getVersionPolicy() async {
    final doc = await _versionDocRef.get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppVersionPolicy.fromMap(doc.data()!);
  }

  /// 관리자 콘솔에서 수정한 앱 버전 정책([policy])을 서버 타임스탬프와 함께 병합 저장합니다.
  Future<void> updateVersionPolicy(AppVersionPolicy policy) async {
    await _versionDocRef.set({
      'latestVersion': policy.latestVersion,
      'latestBuildNumber': policy.latestBuildNumber,
      'minRequiredVersion': policy.minRequiredVersion,
      'minRequiredBuildNumber': policy.minRequiredBuildNumber,
      'title': policy.title,
      'releaseNotes': policy.releaseNotes,
      'androidStoreUrl': policy.androidStoreUrl,
      'iosStoreUrl': policy.iosStoreUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
