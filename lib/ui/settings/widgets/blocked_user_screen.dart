import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/exceptions.dart';
import '../../friends/widgets/friendship_action_handler.dart';
import '../../friends/widgets/user_card.dart';
import '../view_models/blocked_users_viewmodel.dart';

class BlockedUserScreen extends ConsumerWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('차단한 사용자 관리')),
      body: blockedUsersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error is AppException ? error.message : '차단 목록을 불러오지 못했습니다.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(blockedUsersViewModelProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
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
