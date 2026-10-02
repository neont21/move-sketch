import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/error_retry_view.dart';
import '../../friends/widgets/friendship_action_handler.dart';
import '../../friends/widgets/user_card.dart';
import '../view_models/blocked_users_viewmodel.dart';

class BlockedUserScreen extends ConsumerWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('차단한 사용자 관리')),
      body: blockedUsersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorRetryView.fromError(
          error: error,
          defaultMessage: '차단 목록을 불러올 수 없습니다.',
          onRetry: () => ref.invalidate(blockedUsersViewModelProvider),
        ),
        data: (state) {
          if (state.isEmpty) {
            return Center(
              child: Text('차단한 사용자가 없습니다.', style: textTheme.bodyMedium),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(blockedUsersViewModelProvider);
              await ref.read(blockedUsersViewModelProvider.future);
            },
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: state.length,
              itemBuilder: (context, index) {
                return UserCard(
                  user: state[index],
                  isBlocked: true,
                  onUnblock: () {
                    FriendshipActionHandler.unblockUser(
                      ref,
                      context,
                      state[index],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
