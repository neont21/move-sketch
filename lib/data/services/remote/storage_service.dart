import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../../../utils/exceptions.dart';

/// Firebase Storage를 통해 프로필, 스케치, 문의 첨부 이미지의 업로드·다운로드·삭제를 처리하는 서비스 클래스입니다.
class StorageService {
  final FirebaseStorage _storage;
  final http.Client _httpClient;

  StorageService({FirebaseStorage? storage, http.Client? httpClient})
    : _storage = storage ?? FirebaseStorage.instance,
      _httpClient = httpClient ?? http.Client();

  /// 로컬 프로필 이미지 파일([imageFile])을 사용자 전용 스토리지 경로에 업로드하고 다운로드 URL을 반환합니다.
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

  /// 소셜 제공자의 외부 이미지([remoteUrl])를 내려받아 사용자 프로필 스토리지에 복사 업로드하고 URL을 반환합니다.
  Future<String> copyRemoteImageToProfile({
    required String userId,
    required String remoteUrl,
  }) async {
    final http.Response response = await _httpClient.get(Uri.parse(remoteUrl));
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

  /// 완성된 스케치 PNG 이미지 바이너리([bytes])를 스토리지에 업로드하고 다운로드 URL을 반환합니다.
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

  // 이미지 바이너리의 매직 바이트 시그니처를 검사하여 파일 확장자와 MIME 타입을 판별합니다.
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

  /// 인앱 문의에 첨부된 이미지 바이너리([bytes])를 스토리지에 업로드하고 다운로드 URL을 반환합니다.
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

  /// 스토리지 다운로드 URL([fileUrl])로부터 이미지 바이트 데이터를 내려받습니다. (최대 [maxSizeBytes] 제한, 미존재 시 [NotFoundException] 발생)
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

  /// 스토리지 다운로드 URL([fileUrl])에 해당하는 파일을 원격 저장소에서 삭제합니다.
  Future<void> deleteFileByUrl(String fileUrl) async {
    final ref = _storage.refFromURL(fileUrl);
    await ref.delete();
  }
}
