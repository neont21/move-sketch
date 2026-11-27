import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/exceptions.dart';

/// 일반 [FirebaseException]을 도메인 계층의 구조화된 [AppException]으로 변환하는 확장입니다.
extension FirebaseExceptionMapper on FirebaseException {
  /// Firebase 오류 코드(`code`)를 분석하여 적절한 [AppException] 하위 타입과 사용자 친화적 메시지로 매핑합니다.
  AppException toAppException({String? defaultMessage}) {
    return switch (code) {
      'unavailable' || 'deadline-exceeded' || 'retry-limit-exceeded' =>
        NetworkException('네트워크 연결이 불안정합니다. 인터넷 상태를 확인해 주세요.', cause: this),
      'permission-denied' ||
      'unauthorized' => AuthException('해당 작업에 대한 접근 권한이 없습니다.', cause: this),
      'unauthenticated' => AuthException(
        '인증 정보가 만료되었습니다. 다시 로그인해 주세요.',
        cause: this,
      ),
      'resource-exhausted' || 'quota-exceeded' => DatabaseException(
        '요청 한도를 초과했습니다. 잠시 후 다시 시도해 주세요.',
        cause: this,
      ),
      'not-found' || 'object-not-found' => NotFoundException(
        '요청한 데이터를 찾을 수 없습니다.',
        cause: this,
      ),
      _ => DatabaseException(
        defaultMessage != null
            ? '$defaultMessage (${message ?? code})'
            : (message ?? '데이터베이스 작업 중 오류가 발생했습니다.'),
        cause: this,
      ),
    };
  }
}

/// 인증 전용 [FirebaseAuthException]을 도메인 [AuthException]으로 변환하는 확장입니다.
extension FirebaseAuthExceptionMapper on FirebaseAuthException {
  /// Firebase Auth 오류 코드(`code`)에 대응하는 한국어 안내 메시지가 담긴 [AuthException]을 반환합니다.
  AuthException toAuthException({String? defaultMessage}) {
    return switch (code) {
      'no-current-user' => AuthException(
        message ?? '로그인된 사용자가 없습니다.',
        cause: this,
      ),
      'already-verified' => AuthException(
        message ?? '이미 이메일 인증이 완료된 계정입니다.',
        cause: this,
      ),
      'user-not-found' => AuthException('가입되지 않은 계정입니다.', cause: this),
      'user-mismatch' => AuthException(
        '현재 로그인된 계정과 일치하지 않는 소셜 계정입니다.',
        cause: this,
      ),
      'wrong-password' => AuthException('비밀번호가 올바르지 않습니다.', cause: this),
      'invalid-credential' => AuthException(
        defaultMessage != null
            ? '$defaultMessage (${message ?? code})'
            : (message ?? '인증 자격 증명이 올바르지 않습니다.'),
        cause: this,
      ),
      'email-already-in-use' => AuthException('이미 가입된 이메일입니다.', cause: this),
      'invalid-email' => AuthException('유효하지 않은 이메일 형식입니다.', cause: this),
      'weak-password' => AuthException('비밀번호는 6자리 이상이어야 합니다.', cause: this),
      'user-disabled' => AuthException('이용이 정지된 계정입니다.', cause: this),
      'too-many-requests' => AuthException(
        '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.',
        cause: this,
      ),
      'requires-recent-login' => AuthException(
        '보안을 위해 다시 로그인한 후 시도해 주세요.',
        cause: this,
      ),
      'network-request-failed' => AuthException(
        '네트워크 연결을 확인해 주세요.',
        cause: this,
      ),
      'operation-not-allowed' => AuthException(
        '현재 지원되지 않는 방식입니다.',
        cause: this,
      ),
      _ => AuthException(
        defaultMessage != null
            ? '$defaultMessage (${message ?? code})'
            : (message ?? '인증 처리 중 오류가 발생했습니다.'),
        cause: this,
      ),
    };
  }
}
