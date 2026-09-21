abstract class AppException implements Exception {
  final String message;
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

class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

class SessionException extends AppException {
  const SessionException(super.message, {super.cause});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

class LocationException extends AppException {
  const LocationException(super.message, {super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

class ApiException extends AppException {
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