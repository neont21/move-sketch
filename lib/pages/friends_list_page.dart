import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/my_friend_list.dart';
import '../widgets/requested_friend_list.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('친구'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/me/friends/search');
            },
            icon: Icon(Icons.search),
            color: colorScheme.tertiary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RequestedFriendList(),
              MyFriendList(),
            ],
          ),
        ),
      ),
    );
  }
}
