import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:move_sketch/domain/models/app_version_policy.dart';

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
}
