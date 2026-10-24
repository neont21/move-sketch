import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
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

  Future<String> copyRemoteImageToProfile({
    required String userId,
    required String remoteUrl,
  }) async {
    final http.Response response = await http.get(Uri.parse(remoteUrl));
    if (response.statusCode != 200) {
      throw const StorageException('외부 프로필 이미지를 다운로드하지 못했습니다.');
    }

    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final String contentType = response.headers['content-type'] ?? 'image/jpeg';
    final String extension = contentType.contains('png') ? 'png' : 'jpg';

    final Reference ref = _storage.ref().child(
      'profiles/$userId/avatar_$timestamp.$extension',
    );

    final TaskSnapshot snapshot = await ref.putData(
      response.bodyBytes,
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

  (String, String) _resolveImageFormat(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return ('png', 'image/png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return ('jpg', 'image/jpeg');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return ('webp', 'image/webp');
    }
    return ('jpg', 'image/jpeg');
  }

  Future<String> uploadInquiryImage({
    required String inquiryId,
    required int imageIndex,
    required Uint8List bytes,
  }) async {
    final (extension, contentType) = _resolveImageFormat(bytes);

    final ref = _storage.ref().child(
      'inquiries/$inquiryId/image_$imageIndex.$extension',
    );
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
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
