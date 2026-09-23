import 'package:flutter/material.dart';
import 'recommend_friend_list_view.dart';
import 'searched_friend_list_view.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  bool _isSearched = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    keyboardType: TextInputType.text,
                    style: textTheme.bodyMedium,
                    minLines: 1,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: 검색 (이하 테스트용)
                    setState(() {
                      _isSearched = !_isSearched;
                    });
                  },
                  icon: Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _isSearched
                    ? SearchedFriendListView()
                    : RecommendFriendListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
