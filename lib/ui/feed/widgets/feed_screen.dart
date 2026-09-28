import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../history/view_models/history_viewmodel.dart';
import '../../home/view_models/home_viewmodel.dart';
import '../view_models/feed_notifications_viewmodel.dart';
import '../view_models/feed_viewmodel.dart';
import 'feed_post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(feedViewModelProvider.notifier).fetchMore();
    }
  }

  Future<void> _onRefresh() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref.read(feedViewModelProvider.notifier).refreshFeed();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '피드를 불러올 수 없습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _deleteSketch(String sketchId) async {
    final colorScheme = Theme.of(context).colorScheme;
    final result = await ref
        .read(feedViewModelProvider.notifier)
        .deletePost(sketchId);
    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.invalidate(historyViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '게시물 삭제 중 오류가 발생했습니다.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('피드'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.feedNotifications);
            },
            icon: Badge(
              isLabelVisible:
                  ref.watch(hasUnreadNotificationsProvider).value ?? false,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: feedState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('피드를 불러올 수 없습니다.'),
              TextButton(
                onPressed: () => ref.invalidate(feedViewModelProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (state) => state.sketches.isEmpty
            ? const Center(
                child: Text(
                  '아직 피드에 표시할 게시물이 없습니다.\n친구를 추가하거나 세션을 진행해 보아요 :)',
                  textAlign: TextAlign.center,
                ),
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.sketches.length + (state.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.sketches.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return FeedPostCard(
                        sketch: state.sketches[index],
                        onDelete: () => _deleteSketch(state.sketches[index].id),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
