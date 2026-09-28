import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../view_models/friends_viewmodel.dart';
import 'my_friend_list_view.dart';
import 'requested_friend_list_view.dart';

class FriendsListScreen extends ConsumerWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.meFriendsSearch);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: friendsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error is AppException ? error.message : '친구 목록을 불러오지 못했습니다.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(friendsViewModelProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendsViewModelProvider);
              await ref.read(friendsViewModelProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequestedFriendListView(requests: state.receivedRequests),
                  MyFriendListView(friends: state.friends),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
