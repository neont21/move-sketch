import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/recommend_friend_list.dart';
import '../widgets/searched_friend_list.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  bool _isSearched = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('친구 찾기'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 20,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: SizedBox(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: textTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
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
                    ? SearchedFriendList()
                    : RecommendFriendList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
