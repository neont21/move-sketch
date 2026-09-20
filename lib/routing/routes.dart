abstract final class Routes {
  static const landing = '/';
  static const auth = '/auth';

  static const loginRelative = 'login';
  static const login = '$auth/$loginRelative';

  static const signupRelative = 'signup';
  static const signup = '$auth/$signupRelative';

  static const signupCompleteRelative = 'complete';
  static const signupComplete = '$signup/$signupCompleteRelative';

  static const resetPasswordRelative = 'password';
  static const resetPassword = '$auth/$resetPasswordRelative';

  static const home = '/home';

  static const postRelative = 'post/:sketch_id';
  static const profileRelative = 'profile/:user_id';

  static const feed = '/feed';
  static String feedPost(String sketchId) => '$feed/post/$sketchId';

  static const feedNotificationsRelative = 'notifications';
  static const feedNotifications = '$feed/$feedNotificationsRelative';

  static String feedNotificationPost(String sketchId) =>
      '$feedNotifications/post/$sketchId';
  static String feedNotificationProfile(String userId) =>
      '$feedNotifications/profile/$userId';

  static String feedProfile(String userId) => '$feed/profile/$userId';

  static const history = '/history';
  static const historyDetailsRelative = 'details/:session_id';
  static String historyDetails(String sessionId) =>
      '$history/details/$sessionId';

  static String historyPost(String sketchId) => '$history/post/$sketchId';
  static const historyShareRelative = 'share/:sketch_id';

  static String historyShare(String sketchId) => '$history/share/$sketchId';

  static const me = '/me';
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

  static const sessionStart = '/session-start';
  static const sessionTracking = '/session-tracking';

  static const sessionResultPath = '/session-result/:session_id';
  static String sessionResult(String sessionId) => '/session-result/$sessionId';

  static const sessionResultShareRelative = 'share';
  static String sessionResultShare(String sessionId) =>
      '/session-result/$sessionId/share';

  static const sessionEditPath = '/edit/:sketch_id';
  static String sessionEdit(String sketchId) => '/edit/$sketchId';

  static const license = '/license';
  static const privacy = '/privacy';
  static const tos = '/tos';

  static const userProfilePath = '/profile/:user_id';
  static String userProfile(String userId) => '/profile/$userId';
}
