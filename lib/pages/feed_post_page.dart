import 'package:flutter/material.dart';

class FeedPostPage extends StatelessWidget {
  final String sketchId;
  const FeedPostPage({super.key, required this.sketchId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Center(child: Text('Post: $sketchId')));
  }
}
