import 'package:flutter/material.dart';
import '../widgets/cheer_button.dart';
import '../widgets/user_comment.dart';
import '../models/mock_sketch.dart';
import '../models/mock_user.dart';
import '../widgets/feed_post.dart';

class FeedPostPage extends StatefulWidget {
  final String sketchId;
  late final MockSketch _sketch;
  FeedPostPage({super.key, required this.sketchId}) {
    _sketch = MockSketch(
      sketchId: sketchId,
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
      comments: [],
    );
  }

  @override
  State<FeedPostPage> createState() => _FeedPostPageState();
}

class _FeedPostPageState extends State<FeedPostPage> {
  final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
  // final MockUser user = MockUser(id: '@user_id', name: '테스트');
  String? _replyTargetId;

  void _onReply(String commentId) {
    setState(() {
      _replyTargetId = commentId;
    });
  }

  Column buildComments() {
    List<UserComment> comments = [
      UserComment(
        user: MockUser(id: '@peeeeeter_j', name: '피터'),
        createdAt: DateTime.now(),
        sketchId: 'test1',
        commentId: 'test1-1',
        text: '댓글 달고 갑니다~~ 댓글도 너무 길게 달진 않도록 할까 하는데 어떻게 생각하세요?',
        onReply: _onReply,
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
        onReply: _onReply,
      ),
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: comments);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyTargetId != null)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadiusGeometry.vertical(
                  top: const Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // FIXME: Comment.getById(_replyTargetId).user.name
                  Text('$_replyTargetId 에 답글 다는 중'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _replyTargetId = null;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      size: textTheme.labelLarge?.fontSize,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
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
        ],
      ),
    );
  }
}
