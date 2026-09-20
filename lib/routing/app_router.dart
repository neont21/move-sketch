import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/auth/widgets/landing_screen.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/signup_complete_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/feed/widgets/feed_notifications_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/feed/widgets/feed_post_screen.dart';
import '../ui/friends/widgets/friends_list_screen.dart';
import '../ui/friends/widgets/user_search_screen.dart';
import '../ui/history/widgets/history_details_screen.dart';
import '../ui/history/widgets/history_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/profile/widgets/my_profile_screen.dart';
import '../ui/profile/widgets/user_profile_screen.dart';
import '../ui/session/widgets/session_result_screen.dart';
import '../ui/session/widgets/session_share_screen.dart';
import '../ui/session/widgets/session_start_screen.dart';
import '../ui/session/widgets/session_tracking_screen.dart';
import '../ui/settings/widgets/change_character_screen.dart';
import '../ui/settings/widgets/modify_password_screen.dart';
import '../ui/settings/widgets/oss_licenses_screen.dart';
import '../ui/settings/widgets/privacy_screen.dart';
import '../ui/settings/widgets/account_settings_screen.dart';
import '../ui/settings/widgets/blocked_user_screen.dart';
import '../ui/settings/widgets/notification_settings_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/settings/widgets/terms_of_service_screen.dart';
import '../ui/shell/widgets/move_sketch_shell.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _feedNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'feed',
);
final GlobalKey<NavigatorState> _historyNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'history');
final GlobalKey<NavigatorState> _meNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'me',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(path: Routes.landing, builder: (context, state) => LandingPage()),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          MoveSketchShell(navigationShell: navigationShell),
      branches: [
        // tap: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(path: Routes.home, builder: (context, state) => HomePage()),
          ],
        ),
        // tap: Feed
        StatefulShellBranch(
          navigatorKey: _feedNavigatorKey,
          routes: [
            GoRoute(
              path: Routes.feed,
              builder: (context, state) => FeedPage(),
              routes: [
                GoRoute(
                  path: Routes.postRelative,
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                ),
                GoRoute(
                  path: Routes.feedNotificationsRelative,
                  builder: (context, state) => FeedNotificationsPage(),
                  routes: [
                    GoRoute(
                      path: Routes.postRelative,
                      builder: (context, state) {
                        String sketchId = state.pathParameters['sketch_id']!;
                        return FeedPostPage(sketchId: sketchId);
                      },
                    ),
                    GoRoute(
                      path: Routes.profileRelative,
                      builder: (context, state) {
                        String userId = state.pathParameters['user_id']!;
                        return UserProfilePage(userId: userId);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: Routes.profileRelative,
                  builder: (context, state) {
                    String userId = state.pathParameters['user_id']!;
                    return UserProfilePage(userId: userId);
                  },
                ),
              ],
            ),
          ],
        ),
        // tap: History
        StatefulShellBranch(
          navigatorKey: _historyNavigatorKey,
          routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, state) => HistoryPage(),
              routes: [
                GoRoute(
                  path: Routes.historyDetailsRelative,
                  builder: (context, state) {
                    String sessionId = state.pathParameters['session_id']!;
                    return HistoryDetailsPage(sessionId: sessionId);
                  },
                ),
                GoRoute(
                  path: Routes.postRelative,
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                ),
                GoRoute(
                  path: Routes.historyShareRelative,
                  builder: (context, state) {
                    String sessionId = state.pathParameters['sketch_id']!;
                    return SessionSharePage(sessionId: sessionId);
                  },
                ),
              ],
            ),
          ],
        ),
        // tap: Me
        StatefulShellBranch(
          navigatorKey: _meNavigatorKey,
          routes: [
            GoRoute(
              path: Routes.me,
              builder: (context, state) => MyPage(),
              routes: [
                GoRoute(
                  path: Routes.meFriendsRelative,
                  builder: (context, state) => FriendsListPage(),
                  routes: [
                    GoRoute(
                      path: Routes.meFriendsSearchRelative,
                      builder: (context, state) => UserSearchPage(),
                    ),
                  ],
                ),
                GoRoute(
                  path: Routes.postRelative,
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                ),
                GoRoute(
                  path: Routes.meSettingsRelative,
                  builder: (context, state) => SettingsPage(),
                  routes: [
                    GoRoute(
                      path: Routes.meSettingsAccountRelative,
                      builder: (context, state) => SettingAccountPage(),
                      routes: [
                        GoRoute(
                          path: Routes.meSettingsPasswordRelative,
                          builder: (context, state) => ModifyPasswordPage(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: Routes.meSettingsCharacterRelative,
                      builder: (context, state) => ChangeCharacterPage(),
                    ),
                    GoRoute(
                      path: Routes.meSettingsNotificationsRelative,
                      builder: (context, state) => SettingNotificationsPage(),
                    ),
                    GoRoute(
                      path: Routes.meSettingsBlockedRelative,
                      builder: (context, state) => SettingBlockedUser(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.sessionStart,
      builder: (context, state) => SessionStartPage(),
    ),
    GoRoute(
      path: Routes.sessionTracking,
      builder: (context, state) => SessionTrackingPage(),
    ),
    GoRoute(
      path: Routes.sessionResultPath,
      builder: (context, state) {
        String sessionId = state.pathParameters['session_id']!;
        return SessionResultPage(sessionId: sessionId);
      },
      routes: [
        GoRoute(
          path: Routes.sessionResultShareRelative,
          builder: (context, state) {
            String sessionId = state.pathParameters['session_id']!;
            return SessionSharePage(sessionId: sessionId);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.sessionEditPath,
      builder: (context, state) {
        String sketchId = state.pathParameters['sketch_id']!;
        return SessionSharePage(sessionId: sketchId, edit: true);
      },
    ),
    GoRoute(path: Routes.license, builder: (context, state) => OSSLicensesPage()),
    GoRoute(path: Routes.privacy, builder: (context, state) => PrivacyPage()),
    GoRoute(path: Routes.tos, builder: (context, state) => TermsOfServicePage()),
    GoRoute(
      path: Routes.userProfilePath,
      builder: (context, state) {
        String userId = state.pathParameters['user_id']!;
        return UserProfilePage(userId: userId);
      },
    ),
    GoRoute(
      path: Routes.auth,
      redirect: (context, state) =>
          state.uri.path == '/auth' ? '/auth/login' : null,
      routes: [
        GoRoute(path: Routes.loginRelative, builder: (context, state) => LoginPage()),
        GoRoute(
          path: Routes.signupRelative,
          builder: (context, state) => SignupPage(),
          routes: [
            GoRoute(
              path: Routes.signupCompleteRelative,
              builder: (context, state) => SignupCompletePage(),
            ),
          ],
        ),
        GoRoute(
          path: Routes.resetPasswordRelative,
          builder: (context, state) => ResetPasswordPage(),
        ),
      ],
    ),
  ],
);
