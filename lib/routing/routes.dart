/// 앱 내 모든 라우트 경로 상수 및 동적 경로 생성 헬퍼를 정의하는 유틸리티 클래스입니다.
abstract final class Routes {
  static const auth = '/auth';

  static const loginRelative = 'login';
  static const login = '$auth/$loginRelative';

  static const signupRelative = 'signup';
  static const signup = '$auth/$signupRelative';

  static const signupCompleteRelative = 'complete';
  static const signupComplete = '$signup/$signupCompleteRelative';

  static const resetPasswordRelative = 'password';
  static const resetPassword = '$auth/$resetPasswordRelative';

  static const socialOnboardingRelative = 'onboarding';
  static const socialOnboarding = '$auth/$socialOnboardingRelative';

  static const onboardingCharacterRelative = 'character';
  static const onboardingCharacter = '$auth/$onboardingCharacterRelative';

  static const home = '/home';

  static const postRelative = 'post/:sketch_id';
  static const profileRelative = 'profile/:username';

  static const feed = '/feed';
  /// 피드 탭 내 게시물 상세 화면([sketchId]) 경로를 반환합니다.
  static String feedPost(String sketchId) => '$feed/post/$sketchId';

  static const feedNotificationsRelative = 'notifications';
  static const feedNotifications = '$feed/$feedNotificationsRelative';

  static const noticeRelative = 'notice/:notice_id';
  /// 알림 목록 내 공지사항 상세 화면([noticeId]) 경로를 반환합니다.
  static String feedNotificationNotice(String noticeId) =>
      '$feedNotifications/notice/$noticeId';

  /// 알림 목록 내 게시물 상세 화면([sketchId]) 경로를 반환합니다.
  static String feedNotificationPost(String sketchId) =>
      '$feedNotifications/post/$sketchId';
  /// 알림 목록 내 사용자 프로필 화면([username]) 경로를 반환합니다.
  static String feedNotificationProfile(String username) =>
      '$feedNotifications/profile/$username';

  /// 피드 탭 내 사용자 프로필 화면([username]) 경로를 반환합니다.
  static String feedProfile(String username) => '$feed/profile/$username';

  static const history = '/history';
  static const historyDetailsRelative = 'details/:session_id';
  /// 기록 탭 내 세션 상세 화면([sessionId]) 경로를 반환합니다.
  static String historyDetails(String sessionId) =>
      '$history/details/$sessionId';

  /// 기록 탭 내 게시물 상세 화면([sketchId]) 경로를 반환합니다.
  static String historyPost(String sketchId) => '$history/post/$sketchId';
  static const historyShareRelative = 'share/:sketch_id';

  /// 기록 탭 내 세션 공유 화면([sketchId]) 경로를 반환합니다.
  static String historyShare(String sketchId) => '$history/share/$sketchId';

  static const me = '/me';
  /// 나 탭 내 게시물 상세 화면([sketchId]) 경로를 반환합니다.
  static String mePost(String sketchId) => '$me/post/$sketchId';

  static const meFriendsRelative = 'friends';
  static const meFriends = '$me/$meFriendsRelative';

  static const meFriendsSearchRelative = 'search';
  static const meFriendsSearch = '$meFriends/$meFriendsSearchRelative';

  static const meSettingsRelative = 'settings';
  static const meSettings = '$me/$meSettingsRelative';

  static const meSettingsAccountRelative = 'account';
  static const meSettingsAccount = '$meSettings/$meSettingsAccountRelative';

  static const meSettingsPasswordRelative = 'password';
  static const meSettingsPassword =
      '$meSettingsAccount/$meSettingsPasswordRelative';

  static const meSettingsCharacterRelative = 'character';
  static const meSettingsCharacter = '$meSettings/$meSettingsCharacterRelative';

  static const meSettingsNotificationsRelative = 'notifications';
  static const meSettingsNotifications =
      '$meSettings/$meSettingsNotificationsRelative';

  static const meSettingsBlockedRelative = 'blocked';
  static const meSettingsBlocked = '$meSettings/$meSettingsBlockedRelative';

  static const meSettingsInquiryRelative = 'inquiry';
  static const meSettingsInquiry = '$meSettings/$meSettingsInquiryRelative';

  static const sessionStart = '/session-start';
  static const sessionTracking = '/session-tracking';

  static const sessionResultPath = '/session-result/:session_id';
  /// 운동 세션 결과 화면([sessionId]) 경로를 반환합니다.
  static String sessionResult(String sessionId) => '/session-result/$sessionId';

  static const sessionResultShareRelative = 'share';
  /// 운동 세션 결과에서 이어지는 피드 공유 화면([sessionId]) 경로를 반환합니다.
  static String sessionResultShare(String sessionId) =>
      '/session-result/$sessionId/share';

  static const sessionEditPath = '/edit/:sketch_id';
  /// 기존 공유 게시물 수정 화면([sketchId]) 경로를 반환합니다.
  static String sessionEdit(String sketchId) => '/edit/$sketchId';

  static const license = '/license';

  static const userProfilePath = '/profile/:username';
  /// 루트 레벨 사용자 프로필 화면([username]) 경로를 반환합니다.
  static String userProfile(String username) => '/profile/$username';
  static const userProfilePostRelative = ':sketch_id';

  static const String admin = '/admin';
}
