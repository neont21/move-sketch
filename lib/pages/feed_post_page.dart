import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedPostPage extends StatelessWidget {
  final String sketchId;
  const FeedPostPage({super.key, required this.sketchId});

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
        title: Text('뒤로'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            children: [],
          ),
        ),
      ),
    );
  }
}
