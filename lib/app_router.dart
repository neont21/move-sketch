import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/move_sketch_shell.dart';
import 'pages/landing_page.dart';
import 'pages/home_page.dart';
import 'pages/session_start_page.dart';
import 'pages/session_tracking_page.dart';
import 'pages/session_result_page.dart';
import 'pages/session_share_page.dart';
import 'pages/feed_page.dart';
import 'pages/feed_post_page.dart';
import 'pages/feed_notifications_page.dart';
import 'pages/history_page.dart';
import 'pages/history_details_page.dart';
import 'pages/my_page.dart';
import 'pages/friends_list_page.dart';
import 'pages/user_search_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/setting_account_page.dart';
import 'pages/modify_password_page.dart';
import 'pages/change_character_page.dart';
import 'pages/setting_notifications_page.dart';
import 'pages/oss_licenses_page.dart';
import 'pages/privacy_page.dart';
import 'pages/term_of_service_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/signup_complete_page.dart';
import 'pages/reset_password_page.dart';

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
    GoRoute(path: '/', builder: (context, state) => LandingPage()),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          MoveSketchShell(navigationShell: navigationShell),
      branches: [
        // tap: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(path: '/home', builder: (context, state) => HomePage()),
          ],
        ),
        // tap: Feed
        StatefulShellBranch(
          navigatorKey: _feedNavigatorKey,
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => FeedPage(),
              routes: [
                GoRoute(
                  path: 'post/:sketch_id',
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        String sketchId = state.pathParameters['sketch_id']!;
                        return SessionSharePage(
                          sessionId: sketchId,
                          edit: true,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => FeedNotificationsPage(),
                  routes: [
                    GoRoute(
                      path: 'post/:sketch_id',
                      builder: (context, state) {
                        String sketchId = state.pathParameters['sketch_id']!;
                        return FeedPostPage(sketchId: sketchId);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: '/profile/:user_id',
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
              path: '/history',
              builder: (context, state) => HistoryPage(),
              routes: [
                GoRoute(
                  path: 'details/:session_id',
                  builder: (context, state) {
                    String sessionId = state.pathParameters['session_id']!;
                    return HistoryDetailsPage(sessionId: sessionId);
                  },
                ),
                GoRoute(
                  path: 'feed/:sketch_id',
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                ),
                GoRoute(
                  path: 'share/:sketch_id',
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
              path: '/me',
              builder: (context, state) => MyPage(),
              routes: [
                GoRoute(
                  path: 'friends',
                  builder: (context, state) => FriendsListPage(),
                  routes: [
                    GoRoute(
                      path: 'search',
                      builder: (context, state) => UserSearchPage(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'post/:sketch_id',
                  builder: (context, state) {
                    String sketchId = state.pathParameters['sketch_id']!;
                    return FeedPostPage(sketchId: sketchId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        String sketchId = state.pathParameters['sketch_id']!;
                        return SessionSharePage(
                          sessionId: sketchId,
                          edit: true,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => SettingsPage(),
                  routes: [
                    GoRoute(
                      path: 'account',
                      builder: (context, state) => SettingAccountPage(),
                      routes: [
                        GoRoute(
                          path: 'password',
                          builder: (context, state) => ModifyPasswordPage(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'character',
                      builder: (context, state) => ChangeCharacterPage(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      builder: (context, state) => SettingNotificationsPage(),
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
      path: '/session-start',
      builder: (context, state) => SessionStartPage(),
    ),
    GoRoute(
      path: '/session-tracking',
      builder: (context, state) => SessionTrackingPage(),
    ),
    GoRoute(
      path: '/session-result/:session_id',
      builder: (context, state) {
        String sessionId = state.pathParameters['session_id']!;
        return SessionResultPage(sessionId: sessionId);
      },
      routes: [
        GoRoute(
          path: 'share',
          builder: (context, state) {
            String sessionId = state.pathParameters['session_id']!;
            return SessionSharePage(sessionId: sessionId);
          },
        ),
      ],
    ),
    GoRoute(path: '/license', builder: (context, state) => OSSLicensesPage()),
    GoRoute(path: '/privacy', builder: (context, state) => PrivacyPage()),
    GoRoute(path: '/tos', builder: (context, state) => TermOfServicePage()),
    GoRoute(
      path: '/profile/:user_id',
      builder: (context, state) {
        String userId = state.pathParameters['user_id']!;
        return UserProfilePage(userId: userId);
      },
    ),
    GoRoute(
      path: '/auth',
      redirect: (context, state) =>
          state.uri.path == '/auth' ? '/auth/login' : null,
      routes: [
        GoRoute(path: 'login', builder: (context, state) => LoginPage()),
        GoRoute(
          path: 'signup',
          builder: (context, state) => SignupPage(),
          routes: [
            GoRoute(
              path: 'complete',
              builder: (context, state) => SignupCompletePage(),
            ),
          ],
        ),
        GoRoute(
          path: 'password',
          builder: (context, state) => ResetPasswordPage(),
        ),
      ],
    ),
  ],
);
