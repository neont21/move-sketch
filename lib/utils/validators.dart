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

  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해 주세요.';
    }
    if (value.trim().length > 10) {
      return '10자 이내로 입력해 주세요.';
    }
    return null;
  }

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

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    return null;
  }

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
}
