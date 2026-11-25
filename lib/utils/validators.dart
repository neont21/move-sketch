/// 사용자 입력 폼 필드의 유효성 검증 규칙을 제공하는 유틸리티입니다.
abstract final class Validators {
  static final RegExp _letterRegex = RegExp(r'[A-Za-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static const Set<String> _reservedUsernames = {
    'admin',
    'administrator',
    'root',
    'system',
    'manager',
    'moderator',
    'mod',
    'staff',
    'official',
    'support',
    'help',
    'security',

    'movesketch',
    'move_sketch',
    'app',

    'api',
    'auth',
    'login',
    'logout',
    'signup',
    'signin',
    'signout',
    'register',
    'profile',
    'settings',
    'feed',
    'search',
    'home',
    'null',
    'undefined',
    'guest',
    'anonymous',
    'unknown',
    'deleted',
  };

  static const List<String> _reservedPrefixes = [
    'deleted_',
    'admin_',
    'system_',
  ];

  /// 닉네임 입력값([value])의 공백 여부 및 최대 길이(10자)를 검증합니다.
  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해 주세요.';
    }
    if (value.trim().length > 10) {
      return '10자 이내로 입력해 주세요.';
    }
    return null;
  }

  /// 계정 아이디([value])의 길이(3~20자), 허용 문자, 시스템 예약어 포함 여부를 검증합니다.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '아이디를 입력해 주세요.';
    }
    final String trimmedUsername = value.trim();
    if (trimmedUsername.length < 3 || trimmedUsername.length > 20) {
      return '3자 이상 20자 이하로 입력해 주세요.';
    }
    if (!_usernameRegex.hasMatch(trimmedUsername)) {
      return '영문, 숫자, 밑줄(_)만 사용할 수 있습니다.';
    }
    final String lowercased = trimmedUsername.toLowerCase();
    for (final prefix in _reservedPrefixes) {
      if (lowercased.startsWith(prefix)) {
        return "'$prefix'로 시작하는 아이디는 사용할 수 없습니다.";
      }
    }
    if (_reservedUsernames.contains(lowercased)) {
      return '시스템 예약어는 아이디로 사용할 수 없습니다.';
    }
    return null;
  }

  /// 이메일 주소([value])의 공백 여부 및 표준 이메일 형식을 검증합니다.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    return null;
  }

  /// 비밀번호([value])의 최소 길이(8자)와 영문·숫자 조합 포함 여부를 검증합니다.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    final bool hasLetter = _letterRegex.hasMatch(value);
    final bool hasDigit = _digitRegex.hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return '영문과 숫자를 모두 포함해야 합니다.';
    }
    return null;
  }

  /// 확인용 비밀번호([confirmValue])가 원본 비밀번호([originalPassword])와 일치하는지 검증합니다.
  static String? validateConfirmPassword(
    String? confirmValue,
    String originalPassword,
  ) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return '비밀번호를 다시 입력해 주세요.';
    }
    if (confirmValue != originalPassword) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  /// 필수 URL 입력값([value])이 유효한 HTTP/HTTPS 스킴과 호스트를 포함하는지 검증합니다.
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL을 입력해 주세요.';
    }
    final String trimmedUrl = value.trim();
    final Uri? parsedUri = Uri.tryParse(trimmedUrl);
    if (parsedUri == null ||
        (parsedUri.scheme != 'http' && parsedUri.scheme != 'https') ||
        !parsedUri.hasAuthority) {
      return 'http:// 또는 https:// 로 시작하는 올바른 URL을 입력해 주세요.';
    }
    return null;
  }

  /// 선택 입력 URL([value])에 값이 존재하는 경우에만 [validateUrl] 규칙을 검증합니다.
  static String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateUrl(value);
  }

  /// 인앱 문의 본문([value])의 최소 길이(10자) 및 최대 길이(1,000자)를 검증합니다.
  static String? validateInquiryContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '문의 및 제보 내용을 입력해 주세요.';
    }
    final String trimmed = value.trim();
    if (trimmed.length < 10) {
      return '최소 10자 이상 구체적으로 작성해 주세요.';
    }
    if (trimmed.length > 1000) {
      return '최대 1,000자까지 입력할 수 있습니다.';
    }
    return null;
  }
}
