import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/social/social_auth_result.dart';
import '../domain/models/social/social_onboarding_profile.dart';
import '../domain/models/social/user.dart';
import '../ui/admin/widgets/admin_gate.dart';
import '../ui/auth/view_models/auth_viewmodel.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/signup_complete_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/auth/widgets/social_onboarding_screen.dart';
import '../ui/feed/widgets/feed_notifications_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/feed/widgets/feed_post_screen.dart';
import '../ui/feed/widgets/notice_detail_screen.dart';
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
import '../ui/settings/widgets/inquiry_report_screen.dart';
import '../ui/settings/widgets/modify_password_screen.dart';
import '../ui/settings/widgets/oss_licenses_screen.dart';
import '../ui/settings/widgets/account_settings_screen.dart';
import '../ui/settings/widgets/blocked_user_screen.dart';
import '../ui/settings/widgets/notification_settings_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/shell/widgets/move_sketch_shell.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
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

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'scaffoldMessenger');

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

  final String defaultLocation = kIsWeb ? Routes.feed : Routes.home;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: defaultLocation,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);

      if (authState.isLoading) {
        return null;
      }

      final user = authState.value;
      final location = state.matchedLocation;

      final isPublicRoute =
          location.startsWith(Routes.auth) ||
          location == Routes.license ||
          location.startsWith(Routes.admin);

      if (user == null) {
        if (authState.hasError) {
          return null;
        }

        return isPublicRoute ? null : Routes.login;
      }

      final isAuthRoute =
          location == Routes.auth ||
          location == Routes.login ||
          location == Routes.resetPassword;

      if (isAuthRoute) {
        return defaultLocation;
      }

      if (kIsWeb) {
        final isSessionRestricted =
            location == Routes.home ||
            location == Routes.sessionStart ||
            location == Routes.sessionTracking ||
            location.startsWith('/session-result');
        if (isSessionRestricted) {
          return Routes.feed;
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => defaultLocation),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            MoveSketchShell(navigationShell: navigationShell),
        branches: [
          // tab: Home
          if (!kIsWeb)
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
          // tab: Feed
          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.feed,
                builder: (context, state) => const FeedScreen(),
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
                    builder: (context, state) => const FeedNotificationsScreen(),
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
                          final username = state.pathParameters['username']!;
                          return UserProfileScreen(username: username);
                        },
                        routes: [
                          GoRoute(
                            path: Routes.userProfilePostRelative,
                            builder: (context, state) {
                              final sketchId =
                                  state.pathParameters['sketch_id']!;
                              return FeedPostScreen(sketchId: sketchId);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.noticeRelative,
                        builder: (context, state) {
                          final noticeId = state.pathParameters['notice_id']!;
                          return NoticeDetailScreen(noticeId: noticeId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.profileRelative,
                    builder: (context, state) {
                      final username = state.pathParameters['username']!;
                      return UserProfileScreen(username: username);
                    },
                    routes: [
                      GoRoute(
                        path: Routes.userProfilePostRelative,
                        builder: (context, state) {
                          final sketchId = state.pathParameters['sketch_id']!;
                          return FeedPostScreen(sketchId: sketchId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // tab: History
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (context, state) => const HistoryScreen(),
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
          // tab: Me
          StatefulShellBranch(
            navigatorKey: _meNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.me,
                builder: (context, state) => const MyProfileScreen(),
                routes: [
                  GoRoute(
                    path: Routes.meFriendsRelative,
                    builder: (context, state) => const FriendsListScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.meFriendsSearchRelative,
                        builder: (context, state) => const UserSearchScreen(),
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
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.meSettingsAccountRelative,
                        builder: (context, state) => const AccountSettingsScreen(),
                        routes: [
                          GoRoute(
                            path: Routes.meSettingsPasswordRelative,
                            builder: (context, state) => const ModifyPasswordScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.meSettingsCharacterRelative,
                        builder: (context, state) => const ChangeCharacterScreen(),
                      ),
                      GoRoute(
                        path: Routes.meSettingsNotificationsRelative,
                        builder: (context, state) =>
                            const NotificationSettingsScreen(),
                      ),
                      GoRoute(
                        path: Routes.meSettingsBlockedRelative,
                        builder: (context, state) => const BlockedUserScreen(),
                      ),
                      GoRoute(
                        path: Routes.meSettingsInquiryRelative,
                        builder: (context, state) => const InquiryReportScreen(),
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
        builder: (context, state) => const SessionStartScreen(),
      ),
      GoRoute(
        path: Routes.sessionTracking,
        builder: (context, state) => const SessionTrackingScreen(),
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
        builder: (context, state) => const OSSLicensesScreen(),
      ),
      GoRoute(
        path: Routes.userProfilePath,
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return UserProfileScreen(username: username);
        },
        routes: [
          GoRoute(
            path: Routes.userProfilePostRelative,
            builder: (context, state) {
              final sketchId = state.pathParameters['sketch_id']!;
              return FeedPostScreen(sketchId: sketchId);
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.auth,
        redirect: (context, state) =>
            state.uri.path == Routes.auth ? Routes.login : null,
        routes: [
          GoRoute(
            path: Routes.loginRelative,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: Routes.signupRelative,
            builder: (context, state) => const SignupScreen(),
            routes: [
              GoRoute(
                path: Routes.signupCompleteRelative,
                builder: (context, state) => const SignupCompleteScreen(),
              ),
            ],
          ),
          GoRoute(
            path: Routes.resetPasswordRelative,
            builder: (context, state) => const ResetPasswordScreen(),
          ),
          GoRoute(
            path: Routes.socialOnboardingRelative,
            redirect: (context, state) {
              if (state.extra is! SocialAuthNeedsOnboarding) {
                return Routes.login;
              }
              return null;
            },
            builder: (context, state) => SocialOnboardingScreen(
              initialData: state.extra as SocialAuthNeedsOnboarding,
            ),
          ),
          GoRoute(
            path: Routes.onboardingCharacterRelative,
            redirect: (context, state) {
              if (state.extra is! SocialOnboardingProfile) {
                return Routes.login;
              }
              return null;
            },
            builder: (context, state) => ChangeCharacterScreen(
              onboardingProfile: state.extra as SocialOnboardingProfile,
            ),
          ),
        ],
      ),
      if (kIsWeb)
        GoRoute(
          path: Routes.admin,
          builder: (context, state) {
            return const AdminGate();
          },
        ),
    ],
  );
});
