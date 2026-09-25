import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/social/user.dart';
import '../ui/auth/view_models/auth_viewmodel.dart';
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

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    ref.listen<AsyncValue<User?>>(authViewModelProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: Routes.landing,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);

      if (authState.isLoading) {
        return null;
      }

      final user = authState.value;
      final location = state.matchedLocation;

      final isPublicRoute =
          location == Routes.landing ||
          location.startsWith(Routes.auth) ||
          location == Routes.privacy ||
          location == Routes.tos ||
          location == Routes.license;

      if (user == null) {
        return isPublicRoute ? null : Routes.login;
      }

      final isAuthRoute =
          location == Routes.landing ||
          location == Routes.auth ||
          location == Routes.login ||
          location == Routes.resetPassword;

      if (isAuthRoute) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(path: Routes.landing, builder: (context, state) => LandingScreen()),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            MoveSketchShell(navigationShell: navigationShell),
        branches: [
          // tap: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => HomeScreen(),
              ),
            ],
          ),
          // tap: Feed
          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.feed,
                builder: (context, state) => FeedScreen(),
                routes: [
                  GoRoute(
                    path: Routes.postRelative,
                    builder: (context, state) {
                      String sketchId = state.pathParameters['sketch_id']!;
                      return FeedPostScreen(sketchId: sketchId);
                    },
                  ),
                  GoRoute(
                    path: Routes.feedNotificationsRelative,
                    builder: (context, state) => FeedNotificationsScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.postRelative,
                        builder: (context, state) {
                          String sketchId = state.pathParameters['sketch_id']!;
                          return FeedPostScreen(sketchId: sketchId);
                        },
                      ),
                      GoRoute(
                        path: Routes.profileRelative,
                        builder: (context, state) {
                          String userId = state.pathParameters['user_id']!;
                          return UserProfileScreen(userId: userId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.profileRelative,
                    builder: (context, state) {
                      String userId = state.pathParameters['user_id']!;
                      return UserProfileScreen(userId: userId);
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
                builder: (context, state) => HistoryScreen(),
                routes: [
                  GoRoute(
                    path: Routes.historyDetailsRelative,
                    builder: (context, state) {
                      String sessionId = state.pathParameters['session_id']!;
                      return HistoryDetailsScreen(sessionId: sessionId);
                    },
                  ),
                  GoRoute(
                    path: Routes.postRelative,
                    builder: (context, state) {
                      String sketchId = state.pathParameters['sketch_id']!;
                      return FeedPostScreen(sketchId: sketchId);
                    },
                  ),
                  GoRoute(
                    path: Routes.historyShareRelative,
                    builder: (context, state) {
                      String sessionId = state.pathParameters['sketch_id']!;
                      return SessionShareScreen(sessionId: sessionId);
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
                builder: (context, state) => MyProfileScreen(),
                routes: [
                  GoRoute(
                    path: Routes.meFriendsRelative,
                    builder: (context, state) => FriendsListScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.meFriendsSearchRelative,
                        builder: (context, state) => UserSearchScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.postRelative,
                    builder: (context, state) {
                      String sketchId = state.pathParameters['sketch_id']!;
                      return FeedPostScreen(sketchId: sketchId);
                    },
                  ),
                  GoRoute(
                    path: Routes.meSettingsRelative,
                    builder: (context, state) => SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.meSettingsAccountRelative,
                        builder: (context, state) => AccountSettingsScreen(),
                        routes: [
                          GoRoute(
                            path: Routes.meSettingsPasswordRelative,
                            builder: (context, state) => ModifyPasswordScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.meSettingsCharacterRelative,
                        builder: (context, state) => ChangeCharacterScreen(),
                      ),
                      GoRoute(
                        path: Routes.meSettingsNotificationsRelative,
                        builder: (context, state) => NotificationSettingsScreen(),
                      ),
                      GoRoute(
                        path: Routes.meSettingsBlockedRelative,
                        builder: (context, state) => BlockedUserScreen(),
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
        builder: (context, state) => SessionStartScreen(),
      ),
      GoRoute(
        path: Routes.sessionTracking,
        builder: (context, state) => SessionTrackingScreen(),
      ),
      GoRoute(
        path: Routes.sessionResultPath,
        builder: (context, state) {
          String sessionId = state.pathParameters['session_id']!;
          return SessionResultScreen(sessionId: sessionId);
        },
        routes: [
          GoRoute(
            path: Routes.sessionResultShareRelative,
            builder: (context, state) {
              String sessionId = state.pathParameters['session_id']!;
              return SessionShareScreen(sessionId: sessionId);
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.sessionEditPath,
        builder: (context, state) {
          String sketchId = state.pathParameters['sketch_id']!;
          return SessionShareScreen(sessionId: sketchId);
        },
      ),
      GoRoute(
        path: Routes.license,
        builder: (context, state) => OSSLicensesScreen(),
      ),
      GoRoute(path: Routes.privacy, builder: (context, state) => PrivacyScreen()),
      GoRoute(
        path: Routes.tos,
        builder: (context, state) => TermsOfServiceScreen(),
      ),
      GoRoute(
        path: Routes.userProfilePath,
        builder: (context, state) {
          String userId = state.pathParameters['user_id']!;
          return UserProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: Routes.auth,
        redirect: (context, state) =>
            state.uri.path == Routes.auth ? Routes.login : null,
        routes: [
          GoRoute(
            path: Routes.loginRelative,
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: Routes.signupRelative,
            builder: (context, state) => SignupScreen(),
            routes: [
              GoRoute(
                path: Routes.signupCompleteRelative,
                builder: (context, state) => SignupCompleteScreen(),
              ),
            ],
          ),
          GoRoute(
            path: Routes.resetPasswordRelative,
            builder: (context, state) => ResetPasswordScreen(),
          ),
        ],
      ),
    ],
  );
});
