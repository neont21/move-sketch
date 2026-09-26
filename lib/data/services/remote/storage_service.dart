import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../utils/exceptions.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = imageFile.path.split('.').last.toLowerCase();

    final (fileExt, contentType) = switch (ext) {
      'png' => ('png', 'image/png'),
      'webp' => ('webp', 'image/webp'),
      _ => ('jpg', 'image/jpeg'),
    };

    final Reference ref = _storage.ref().child(
      'profiles/$userId/avatar_$timestamp.$fileExt',
    );
    final TaskSnapshot snapshot = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: contentType),
    );

    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadSketchImage({
    required String userId,
    required String sessionId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('sketches/$userId/$sessionId.png');
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/png'),
    );

    return await snapshot.ref.getDownloadURL();
  }

  Future<Uint8List> downloadFileByUrl(
      String fileUrl, {
        int maxSizeBytes = 10 * 1024 * 1024,
      }) async {
    final ref = _storage.refFromURL(fileUrl);
    final bytes = await ref.getData(maxSizeBytes);
    if (bytes == null) {
      throw const NotFoundException('이미지 데이터를 찾을 수 없습니다.');
    }
    return bytes;
  }

  Future<void> deleteFileByUrl(String fileUrl) async {
    final ref = _storage.refFromURL(fileUrl);
    await ref.delete();
  }
}
