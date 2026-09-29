import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/friends_viewmodel.dart';
import '../view_models/user_search_viewmodel.dart';
import 'recommend_friend_list_view.dart';
import 'searched_friend_list_view.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  Future<void> _onSearch() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final query = _searchController.text;
    final result = await ref
        .read(userSearchViewModelProvider.notifier)
        .search(query);

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '사용자 검색 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(userSearchViewModelProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final searchState = ref.watch(userSearchViewModelProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.invalidate(friendsViewModelProvider);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('친구 찾기')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 20,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      style: textTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: '아이디 또는 닉네임으로 검색',
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _onClearSearch,
                              )
                            : null,
                      ),
                      onSubmitted: (value) => _onSearch(),
                    ),
                  ),
                  IconButton(
                    onPressed: _onSearch,
                    icon: Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: searchState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) {
                    final errorMessage = error is AppException
                        ? error.message
                        : '데이터를 불러오는 중 오류가 발생했습니다.';
                    return Center(
                      child: Text(
                        errorMessage,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  },
                  data: (state) {
                    if (state.isSearching) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return SingleChildScrollView(
                      child: state.searchQuery.isNotEmpty
                          ? SearchedFriendListView(
                              searchedUsers: state.searchResults,
                              friendIds: state.friendIds,
                              sentRequestIds: state.sentRequestIds,
                              receivedRequestIds: state.receivedRequestIds,
                            )
                          : RecommendFriendListView(
                              recommends: state.recommendedUsers,
                              friendIds: state.friendIds,
                              sentRequestIds: state.sentRequestIds,
                              receivedRequestIds: state.receivedRequestIds,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
