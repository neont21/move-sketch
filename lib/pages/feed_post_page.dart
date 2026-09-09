import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/widgets/cheer_button.dart';
import 'package:move_sketch/widgets/user_comment.dart';
import '../models/mock_sketch.dart';
import '../models/mock_user.dart';
import '../widgets/feed_post.dart';

class FeedPostPage extends StatefulWidget {
  final String _sketchId;
  late final MockSketch _sketch;
  FeedPostPage({super.key, required this._sketchId}) {
    _sketch = MockSketch(
      sketchId: _sketchId,
      author: MockUser(id: '@user_id', name: '테스트'),
      createdAt: DateTime.now(),
      isJogging: true,
      location: '동대문구 휘경동',
      weather: '맑음',
      text: '기록을 남겨요',
      cheeredUser: [
        MockUser(id: '@peeeeeter_j', name: '피터'),
        MockUser(id: '@nyong_nyoi', name: '뇨이'),
      ],
    );
  }

  @override
  State<FeedPostPage> createState() => _FeedPostPageState();
}

class _FeedPostPageState extends State<FeedPostPage> {
  final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
  // final MockUser user = MockUser(id: '@user_id', name: '테스트');

  Column buildComments() {
    List<UserComment> comments = [
      UserComment(
        user: MockUser(id: '@peeeeeter_j', name: '피터'),
        createdAt: DateTime.now(),
        sketchId: 'test1',
        commentId: 'test1-1',
        text: '댓글 달고 갑니다~~ 댓글도 너무 길게 달진 않도록 할까 하는데 어떻게 생각하세요?',
      ),
      UserComment(
        user: MockUser(id: '@edenjint3927', name: '후이'),
        createdAt: DateTime.now(),
        sketchId: 'test1',
        commentId: 'test1-2',
        text: '어느 정도가 긴 거지...',
        parentCommentId: 'test1-1',
      ),
      UserComment(
        user: MockUser(id: '@daniil_a_np', name: '다닐루쉬카'),
        createdAt: DateTime.now(),
        sketchId: 'test1',
        commentId: 'test1-3',
        text: '이게 뭐람.',
      ),
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: comments);
  }

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
        // title: Text('뒤로'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              FeedPost(sketch: widget._sketch, isDetail: true),
              CheerButton(
                author: widget._sketch.author,
                user: user,
                cheeredUser: widget._sketch.cheeredUser,
              ),
              Divider(),
              buildComments(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
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
                // TODO: 댓글 추가
              },
              icon: Icon(Icons.arrow_upward),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
