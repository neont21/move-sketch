import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/exceptions.dart';
import '../../core/widgets/user_avatar.dart';
import '../../../routing/routes.dart';
import '../view_models/my_profile_viewmodel.dart';
import 'profile_grid.dart';
import 'modify_profile_dialog.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final profileState = ref.watch(myProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.meSettings);
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error is AppException ? error.message : '프로필을 불러오지 못했습니다.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(myProfileViewModelProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.user.nickname, style: textTheme.bodyLarge),
                          Text('@${state.user.username}', style: textTheme.labelMedium),
                          const SizedBox(height: 4),
                          state.user.description != null && state.user.description!.isNotEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      state.user.description!,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                   UserAvatar(
                     username: state.user.username,
                     imageUrl: state.user.imageUrl,
                     radius: 40,
                   ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Dialog(child: ModifyProfileDialog(user: state.user)),
                          );
                        },
                        child: Text('프로필 편집', style: textTheme.bodyMedium),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.go(Routes.meFriends);
                        },
                        child: Text(
                          '친구 ${state.friendCount}명',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(),
                Expanded(
                  child: state.sketches.isEmpty
                      ? Center(
                    child: Text(
                      '아직 그린 스케치가 없습니다.\n러닝을 완료하고 첫 스케치를 공유해 보세요!',
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium,
                    ),
                  )
                      : ProfileGrid(
                    userId: state.user.uid,
                    sketches: state.sketches,
                    onTap: (index) {
                      context.go(
                        Routes.mePost(state.sketches[index].id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
