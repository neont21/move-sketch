/// 애플리케이션 전역에서 도메인 및 데이터 계층의 오류를 구조화하여 전달하는 기본 예외 클래스입니다.
sealed class AppException implements Exception {
  /// 사용자 또는 로그에 노출할 예외 설명 메시지.
  final String message;

  /// 이 예외를 유발한 원시 예외 또는 에러 객체.
  final Object? cause;

  const AppException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return '$runtimeType: $message (원인: $cause)';
    }
    return '$runtimeType: $message';
  }
}

/// 사용자 입력값 또는 도메인 규칙 유효성 검증에 실패했을 때 발생하는 예외입니다.
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

/// 운동 세션의 시작, 추적, 종료 또는 저장 과정에서 발생하는 예외입니다.
final class SessionException extends AppException {
  const SessionException(super.message, {super.cause});
}

/// 사용자 인증, 회원가입, 토큰 검증 및 계정 권한 처리 중 발생하는 예외입니다.
final class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

/// GPS 위치 권한, 센서 수신 또는 지오코딩 처리 중 발생하는 예외입니다.
final class LocationException extends AppException {
  const LocationException(super.message, {super.cause});
}

/// 네트워크 연결 단절 또는 타임아웃 등 통신 환경 문제로 발생하는 예외입니다.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// 요청한 리소스나 문서를 로컬 또는 원격 저장소에서 찾을 수 없을 때 발생하는 예외입니다.
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

/// Drift 로컬 데이터베이스 읽기/쓰기 또는 마이그레이션 중 발생하는 예외입니다.
final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

/// 원격 파일 스토리지 업로드, 다운로드 또는 삭제 중 발생하는 예외입니다.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// 외부 브라우저, 스토어, 메일 앱 등 타사 애플리케이션 실행에 실패했을 때 발생하는 예외입니다.
final class ExternalAppException extends AppException {
  const ExternalAppException(super.message, {super.cause});
}

/// 외부 REST API 호출 시 비정상 HTTP 응답 또는 파싱 오류가 발생했을 때 던져지는 예외입니다.
final class ApiException extends AppException {
  /// 서버로부터 수신한 HTTP 상태 코드.
  final int? statusCode;

  const ApiException(super.message, {this.statusCode, super.cause});

  @override
  String toString() {
    final status = statusCode != null ? ' (HTTP $statusCode)' : '';
    if (cause != null) {
      return '$runtimeType: $message$status (원인: $cause)';
    }
    return '$runtimeType: $message$status';
  }
}
