import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/system/app_version_policy.dart';

class AppVersionService {
  final FirebaseFirestore _firestore;

  AppVersionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _versionDocRef =>
      _firestore.collection('app_config').doc('version');

  Future<AppVersionPolicy?> getVersionPolicy() async {
    final doc = await _versionDocRef.get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppVersionPolicy.fromMap(doc.data()!);
  }

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
