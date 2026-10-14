import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/error_retry_view.dart';
import '../../core/widgets/user_avatar.dart';
import '../../friends/widgets/mutual_friends_section.dart';
import '../view_models/user_profile_viewmodel.dart';
import 'profile_grid.dart';
import 'user_profile_action_button.dart';
import 'user_sheet_button.dart';

class UserProfileScreen extends ConsumerWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final profileState = ref.watch(userProfileViewModelProvider(username));

    return Scaffold(
      appBar: AppBar(
        actions: [
          profileState.maybeWhen(
            data: (state) {
              final targetUser = state.user.toSummary();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isFriend)
                    IconButton(
                      onPressed: () {
                        ref
                            .read(
                              userProfileViewModelProvider(username).notifier,
                            )
                            .toggleFavoriteFriend();
                      },
                      icon: Icon(
                        state.isFavorite
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: state.isFavorite
                            ? colorScheme.primary
                            : colorScheme.tertiaryContainer,
                      ),
                    ),
                  UserSheetButton(
                    targetUser: targetUser,
                    isFriend: state.isFriend,
                    isBlocked: state.isBlocked,
                  ),
                  const SizedBox(width: 12),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorRetryView.fromError(
          error: error,
          defaultMessage: '사용자 프로필을 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(userProfileViewModelProvider(username)),
        ),
        data: (state) {
          final targetUser = state.user;
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetUser.nickname,
                              style: textTheme.bodyLarge,
                            ),
                            Text(
                              '@${targetUser.username}',
                              style: textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            UserProfileActionButton(
                              targetUser: targetUser.toSummary(),
                              isFriend: state.isFriend,
                              isSentRequest: state.isSentRequest,
                              isReceivedRequest: state.isReceivedRequest,
                              isBlocked: state.isBlocked,
                              description: targetUser.description,
                            ),
                          ],
                        ),
                      ),
                      UserAvatar(
                        username: targetUser.username,
                        imageUrl: targetUser.imageUrl,
                        radius: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  state.isFriend
                      ? const SizedBox.shrink()
                      : MutualFriendsSection(
                          mutualFriends: state.mutualFriends,
                        ),
                  const Divider(),
                  Expanded(
                    child: state.isFriend
                        ? (state.sketches.isEmpty
                              ? Center(
                                  child: Text(
                                    '아직 공유된 스케치가 없습니다.',
                                    style: textTheme.labelMedium,
                                  ),
                                )
                              : ProfileGrid(
                                  userId: state.user.uid,
                                  sketches: state.sketches,
                                  onTap: (index) {
                                    final currentPath = GoRouterState.of(
                                      context,
                                    ).uri.path;
                                    context.go(
                                      '$currentPath/${state.sketches[index].id}',
                                    );
                                  },
                                ))
                        : Center(
                            child: Text(
                              '친구가 되면 기록을 볼 수 있어요',
                              style: textTheme.labelMedium,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
